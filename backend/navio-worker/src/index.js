const ALLOWED_APP_TOKEN = "navio-pathways-v1";

const DEFAULT_MODEL = "openai/gpt-oss-20b";
const DEFAULT_SYSTEM_PROMPT =
  "You are Navio Pathways, a helpful career planning assistant for students. Give clear, encouraging, age-appropriate guidance.";
const MAX_RESUME_TEXT_LENGTH = 12000;
const PROVIDER_ERROR_FALLBACK =
  "AI is temporarily unavailable. Please try again in a moment.";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return corsResponse(null, 204);
    }

    if (url.pathname === "/") {
      return jsonResponse({
        status: "ok",
        message: "Navio Pathways backend is running",
      });
    }

    if (url.pathname !== "/api/chat" && url.pathname !== "/api/resume-grade") {
      return jsonResponse({ error: "Not found" }, 404);
    }

    if (request.method !== "POST") {
      return jsonResponse({ error: "Method not allowed" }, 405);
    }

    const appToken = request.headers.get("X-Navio-App");

    if (appToken !== ALLOWED_APP_TOKEN) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    // Rate limit: 30 calls/minute based on wrangler.jsonc.
    // Prefer a stable app user/device ID. Fall back to IP if missing.
    const userId =
      request.headers.get("X-Navio-User") ||
      request.headers.get("CF-Connecting-IP") ||
      "anonymous";

    const rateLimitKey = `chat:${userId}`;

    const rateLimitResult = await env.USER_RATE_LIMITER.limit({
      key: rateLimitKey,
    });

    if (!rateLimitResult.success) {
      return jsonResponse(
        {
          error: "Rate limit exceeded",
          message: "Please wait a minute before trying again.",
        },
        429,
      );
    }

    if (!env.GROQ_API_KEY) {
      return jsonResponse({ error: "Server API key is missing" }, 500);
    }

    try {
      if (url.pathname === "/api/resume-grade") {
        return await handleResumeGrade(request, env);
      }

      const body = await request.json();

      const model =
        typeof body.model === "string" && body.model.trim().length > 0
          ? body.model.trim()
          : DEFAULT_MODEL;

      const temperature =
        typeof body.temperature === "number" ? body.temperature : 0.7;

      const maxTokens =
        typeof body.maxTokens === "number"
          ? Math.min(Math.max(body.maxTokens, 50), 1200)
          : 700;

      let messages = body.messages;

      // Supports Flutter format:
      // {
      //   model,
      //   temperature,
      //   maxTokens,
      //   messages: [{ role: "system", content: "..." }, ...]
      // }
      if (Array.isArray(messages)) {
        messages = sanitizeMessages(messages);
      }

      // Also supports simple format:
      // {
      //   prompt: "...",
      //   system: "..."
      // }
      if (!Array.isArray(messages) || messages.length === 0) {
        const prompt = body.prompt;
        const system = body.system;

        if (typeof prompt !== "string" || prompt.trim().length === 0) {
          return jsonResponse({ error: "Prompt is required" }, 400);
        }

        messages = [
          {
            role: "system",
            content:
              typeof system === "string" && system.trim().length > 0
                ? system.trim()
                : DEFAULT_SYSTEM_PROMPT,
          },
          {
            role: "user",
            content: prompt.trim(),
          },
        ];
      }

      const totalTextLength = messages
        .map((message) => message.content || "")
        .join(" ")
        .length;

      if (totalTextLength > 8000) {
        return jsonResponse({ error: "Prompt is too long" }, 400);
      }

      const groqResponse = await fetch(
        "https://api.groq.com/openai/v1/chat/completions",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${env.GROQ_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(
            providerChatPayload({
              model,
              temperature,
              maxTokens,
              messages,
            }),
          ),
        },
      );

      const data = await groqResponse.json();

      if (!groqResponse.ok) {
        return jsonResponse(
          {
            error: "AI provider request failed",
            message: providerErrorMessage(data),
            details: data,
          },
          groqResponse.status,
        );
      }

      return jsonResponse({
        message: providerMessageContent(data),
      });
    } catch (error) {
      return jsonResponse(
        {
          error: "Internal server error",
          message: error.message,
        },
        500,
      );
    }
  },
};

async function handleResumeGrade(request, env) {
  const body = await request.json();
  const validation = validateResumeGradeRequest(body);

  if (!validation.ok) {
    return jsonResponse({ error: validation.error }, 400);
  }

  const { resumeText, fileName } = validation.value;

  const messages = [
    {
      role: "system",
      content: [
        "You are Navio Pathways, a career coach for students and early-career users.",
        "Grade resumes with specific, practical, encouraging feedback.",
        "Return JSON only. No markdown, no commentary outside the JSON object.",
        "Use this exact shape: {\"overallScore\":number,\"jobFitScore\":number|null,\"summary\":string,\"strengths\":string[],\"issues\":string[],\"improvements\":string[],\"rewriteSuggestions\":[{\"before\":string,\"after\":string,\"reason\":string}],\"breakdown\":[{\"label\":string,\"score\":number,\"note\":string}],\"atsNotes\":string[]}.",
        "Scores must be integers from 0 to 100.",
        "This is a general resume review, so jobFitScore must be null.",
        "Assume the resume text may come from PDF extraction, so ignore casing, line breaks, missing spaces, pipes, punctuation, odd separators, and contact-format artifacts unless they clearly affect the actual resume content.",
        "Rewrite suggestions must focus on content quality: stronger impact bullets, quantified outcomes, clearer summary, more specific skills, and stronger project or experience descriptions.",
        "Do not suggest capitalization, punctuation, comma, spacing, separator, or contact-format fixes.",
        "Give 4 to 6 breakdown items, 3 to 5 strengths, 3 to 5 issues, 4 to 6 improvements, 0 to 3 useful content rewrite suggestions, and 2 to 4 ATS notes.",
      ].join(" "),
    },
    {
      role: "user",
      content: [
        `File name: ${fileName}`,
        "Analyze mode: general resume quality only",
        "Resume text:",
        resumeText,
      ].join("\n\n"),
    },
  ];

  const groqResponse = await fetch(
    "https://api.groq.com/openai/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(
        providerChatPayload({
          model: DEFAULT_MODEL,
          temperature: 0.2,
          maxTokens: 1200,
          messages,
          responseFormat: { type: "json_object" },
        }),
      ),
    },
  );

  const data = await groqResponse.json();

  if (!groqResponse.ok) {
    return jsonResponse(
      {
        error: "AI provider request failed",
        message: providerErrorMessage(data),
        details: data,
      },
      groqResponse.status,
    );
  }

  const content = providerMessageContent(data);
  const report = normalizeResumeGradeReport(content);

  if (!report) {
    return jsonResponse({ error: "AI response was not valid JSON" }, 502);
  }

  return jsonResponse({ report });
}

function providerChatPayload({
  model,
  temperature,
  maxTokens,
  messages,
  responseFormat,
}) {
  const payload = {
    model,
    temperature,
    max_tokens: maxTokens,
    messages,
  };

  if (responseFormat) {
    payload.response_format = responseFormat;
  }

  if (isGptOssModel(model)) {
    payload.include_reasoning = false;
    payload.reasoning_effort = "low";
  }

  return payload;
}

function isGptOssModel(model) {
  return typeof model === "string" && model.startsWith("openai/gpt-oss-");
}

function providerMessageContent(data) {
  const message = data?.choices?.[0]?.message;
  return typeof message?.content === "string" ? message.content.trim() : "";
}

function providerErrorMessage(data) {
  const message = data?.error?.message || data?.message;
  return typeof message === "string" && message.trim().length > 0
    ? message.trim()
    : PROVIDER_ERROR_FALLBACK;
}

function validateResumeGradeRequest(body) {
  if (!body || typeof body !== "object") {
    return { ok: false, error: "Request body must be a JSON object" };
  }

  const resumeText =
    typeof body.resumeText === "string" ? body.resumeText.trim() : "";
  const fileName = typeof body.fileName === "string" ? body.fileName.trim() : "";

  if (resumeText.length < 250) {
    return {
      ok: false,
      error: "Resume text is too short to grade. Please upload a text-based PDF.",
    };
  }

  if (resumeText.length > MAX_RESUME_TEXT_LENGTH) {
    return { ok: false, error: "Resume text is too long" };
  }

  return {
    ok: true,
    value: {
      resumeText,
      fileName: fileName || "resume.pdf",
    },
  };
}

function normalizeResumeGradeReport(content) {
  try {
    const parsed = JSON.parse(content);
    return {
      overallScore: clampScore(parsed.overallScore),
      jobFitScore: null,
      summary: stringValue(parsed.summary, "Resume review is ready."),
      strengths: stringList(parsed.strengths, 5),
      issues: stringList(parsed.issues, 5),
      improvements: stringList(parsed.improvements, 6),
      rewriteSuggestions: rewriteList(parsed.rewriteSuggestions, 3),
      breakdown: breakdownList(parsed.breakdown, 6),
      atsNotes: stringList(parsed.atsNotes, 4),
    };
  } catch (_) {
    return null;
  }
}

function clampScore(value) {
  const score = Number.parseInt(value, 10);
  if (!Number.isFinite(score)) return 0;
  return Math.min(Math.max(score, 0), 100);
}

function stringValue(value, fallback = "") {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : fallback;
}

function stringList(value, maxItems) {
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => stringValue(item))
    .filter((item) => item.length > 0)
    .slice(0, maxItems);
}

function rewriteList(value, maxItems) {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item) => item && typeof item === "object")
    .map((item) => ({
      before: stringValue(item.before, "Current wording"),
      after: stringValue(item.after, "Stronger revised wording"),
      reason: stringValue(item.reason, "This makes the impact clearer."),
    }))
    .filter((item) => !isExtractionArtifactRewrite(item))
    .slice(0, maxItems);
}

function isExtractionArtifactRewrite(item) {
  const text = `${item.before} ${item.after} ${item.reason}`.toLowerCase();
  return [
    "capitalization",
    "proper capitalization",
    "punctuation",
    "comma",
    "commas",
    "spacing",
    "space",
    "separator",
    "separators",
    "format",
    "formatting",
    "standardize contact",
    "contact information format",
    "consistent use of",
  ].some((pattern) => text.includes(pattern));
}

function breakdownList(value, maxItems) {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item) => item && typeof item === "object")
    .map((item) => ({
      label: stringValue(item.label, "Resume quality"),
      score: clampScore(item.score),
      note: stringValue(item.note, "Review this area for clarity."),
    }))
    .slice(0, maxItems);
}

function sanitizeMessages(messages) {
  return messages
    .filter((message) => {
      return (
        message &&
        typeof message.role === "string" &&
        typeof message.content === "string" &&
        message.content.trim().length > 0
      );
    })
    .map((message) => {
      const role = ["system", "user", "assistant"].includes(message.role)
        ? message.role
        : "user";

      return {
        role,
        content: message.content.trim(),
      };
    });
}

function jsonResponse(data, status = 200) {
  return corsResponse(JSON.stringify(data), status, {
    "Content-Type": "application/json",
  });
}

function corsResponse(body, status = 200, extraHeaders = {}) {
  return new Response(body, {
    status,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers":
        "Content-Type, X-Navio-App, X-Navio-User",
      ...extraHeaders,
    },
  });
}
