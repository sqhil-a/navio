import { describe, it, expect, vi, afterEach } from "vitest";
import worker from "../src";

const env = {
  GROQ_API_KEY: "test-key",
  USER_RATE_LIMITER: {
    limit: vi.fn(async () => ({ success: true })),
  },
};

function authedRequest(path, body) {
  return new Request(`http://example.com${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Navio-App": "navio-pathways-v1",
      "X-Navio-User": "test-user",
    },
    body: JSON.stringify(body),
  });
}

afterEach(() => {
  vi.unstubAllGlobals();
  env.USER_RATE_LIMITER.limit.mockClear();
});

describe("navio worker", () => {
  it("returns health status at root", async () => {
    const response = await worker.fetch(new Request("http://example.com"), env);
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body.status).toBe("ok");
  });

  it("rejects unauthorized resume grading requests", async () => {
    const response = await worker.fetch(
      new Request("http://example.com/api/resume-grade", { method: "POST" }),
      env,
    );
    const body = await response.json();

    expect(response.status).toBe(401);
    expect(body.error).toBe("Unauthorized");
  });

  it("validates resume grading request body", async () => {
    const response = await worker.fetch(
      authedRequest("/api/resume-grade", {
        resumeText: "too short",
        fileName: "resume.pdf",
      }),
      env,
    );
    const body = await response.json();

    expect(response.status).toBe(400);
    expect(body.error).toMatch(/too short/i);
  });

  it("returns a normalized structured resume grade report", async () => {
    const providerReport = {
      overallScore: 82,
      jobFitScore: 76,
      summary: "Strong foundation with room to quantify impact.",
      strengths: ["Clear education section"],
      issues: ["Experience bullets need stronger outcomes"],
      improvements: ["Add metrics to project bullets"],
      rewriteSuggestions: [
        {
          before: "Worked on a club website",
          after: "Built a club website used by 120 students",
          reason: "Adds scope and impact",
        },
        {
          before: "SAHIL AMBEGAONKAR",
          after: "Sahil Ambegaonkar",
          reason: "Proper capitalization and punctuation",
        },
      ],
      breakdown: [
        {
          label: "Impact",
          score: 72,
          note: "More measurable results would help.",
        },
      ],
      atsNotes: ["Use standard section headings"],
    };

    vi.stubGlobal(
      "fetch",
      vi.fn(async () => {
        return new Response(
          JSON.stringify({
            choices: [{ message: { content: JSON.stringify(providerReport) } }],
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }),
    );

    const longResume = Array(40)
      .fill("Built student projects, volunteered, learned Flutter, and shipped useful tools.")
      .join(" ");

    const response = await worker.fetch(
      authedRequest("/api/resume-grade", {
        resumeText: longResume,
        fileName: "resume.pdf",
      }),
      env,
    );
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body.report.overallScore).toBe(82);
    expect(body.report.jobFitScore).toBe(null);
    expect(body.report.breakdown[0].label).toBe("Impact");
    expect(body.report.rewriteSuggestions).toHaveLength(1);
    expect(body.report.rewriteSuggestions[0].reason).toBe("Adds scope and impact");
  });
});
