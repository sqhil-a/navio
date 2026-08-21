import "./styles.css";

document.documentElement.classList.add("js");

const header = document.querySelector(".site-header");
const toggle = document.querySelector(".menu-toggle");
const menu = document.getElementById("mobile-menu");

const setMenuOpen = (open) => {
  if (!toggle || !menu) return;
  toggle.classList.toggle("is-open", open);
  toggle.setAttribute("aria-expanded", String(open));
  toggle.querySelector(".sr-only").textContent = `${open ? "Close" : "Open"} navigation menu`;
  menu.classList.toggle("is-open", open);
  menu.setAttribute("aria-hidden", String(!open));
  document.body.classList.toggle("menu-open", open);
};

toggle?.addEventListener("click", () => {
  setMenuOpen(toggle.getAttribute("aria-expanded") !== "true");
});

menu?.addEventListener("click", (event) => {
  if (event.target.closest("a")) setMenuOpen(false);
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") setMenuOpen(false);
});

let headerFrame = 0;
const updateHeader = () => {
  headerFrame = 0;
  if (!header) return;
  header.classList.toggle("is-scrolled", window.scrollY > 16);
  const scrollRange = Math.max(1, document.documentElement.scrollHeight - window.innerHeight);
  const progress = Math.min(100, Math.max(0, (window.scrollY / scrollRange) * 100));
  header.style.setProperty("--scroll-progress", `${progress}%`);
};
const requestHeaderUpdate = () => {
  if (headerFrame) return;
  headerFrame = window.requestAnimationFrame(updateHeader);
};
updateHeader();
window.addEventListener("scroll", requestHeaderUpdate, { passive: true });
window.addEventListener("resize", requestHeaderUpdate, { passive: true });

const revealSelector = [
  ".mission-route li",
  ".identity-strip p",
  ".section-heading",
  ".program-feature > *",
  ".outcome-grid article",
  ".support-grid > *",
  ".operating-model article",
  ".organization-grid > *",
  ".story-grid > *",
  ".founder-grid > *",
  ".program-definition > .container > *",
  ".format-path > li",
  ".business-lenses article",
  ".skills-layout > *",
  ".prize-grid > *",
  ".involvement-card",
  ".collaboration-grid > *",
  ".boundary-grid > *",
  ".resource-tool",
  ".resource-next-grid > *",
  ".contact-primary",
  ".contact-topic-grid > a",
  ".social-layout > *",
  ".policy-copy > *",
  ".contact-cta-grid > *",
].join(",");

const revealItems = [...document.querySelectorAll(revealSelector)];
const revealAll = () => revealItems.forEach((item) => item.classList.add("is-visible"));

revealItems.forEach((item, index) => {
  item.classList.add("reveal-item");
  item.style.setProperty("--reveal-delay", `${Math.min(index % 4, 3) * 85}ms`);
});

if (window.matchMedia("(prefers-reduced-motion: reduce)").matches || !("IntersectionObserver" in window)) {
  revealAll();
} else {
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.classList.add("is-visible");
      revealObserver.unobserve(entry.target);
    });
  }, { threshold: 0.1, rootMargin: "0px 0px -7%" });
  revealItems.forEach((item) => revealObserver.observe(item));
}

const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
const caseVisual = document.querySelector(".case-visual");
if (caseVisual && !reducedMotion.matches) {
  let targetX = 0;
  let targetY = 0;
  let currentX = 0;
  let currentY = 0;
  let animationFrame = 0;

  const renderCaseMotion = () => {
    currentX += (targetX - currentX) * 0.075;
    currentY += (targetY - currentY) * 0.075;
    caseVisual.style.setProperty("--tilt-x", `${currentX * 3.2}deg`);
    caseVisual.style.setProperty("--tilt-y", `${currentY * -2.6}deg`);
    caseVisual.style.setProperty("--glow-x", `${68 + currentX * 19}%`);
    caseVisual.style.setProperty("--glow-y", `${28 + currentY * 17}%`);

    if (Math.abs(targetX - currentX) > 0.002 || Math.abs(targetY - currentY) > 0.002) {
      animationFrame = window.requestAnimationFrame(renderCaseMotion);
    } else {
      animationFrame = 0;
    }
  };

  const requestCaseMotion = () => {
    if (!animationFrame) animationFrame = window.requestAnimationFrame(renderCaseMotion);
  };

  caseVisual.addEventListener("pointermove", (event) => {
    const bounds = caseVisual.getBoundingClientRect();
    targetX = Math.max(-1, Math.min(1, ((event.clientX - bounds.left) / bounds.width - 0.5) * 2));
    targetY = Math.max(-1, Math.min(1, ((event.clientY - bounds.top) / bounds.height - 0.5) * 2));
    requestCaseMotion();
  });

  caseVisual.addEventListener("pointerleave", () => {
    targetX = 0;
    targetY = 0;
    requestCaseMotion();
  });
}

const measurementId = window.NAVIO_CONFIG?.analyticsMeasurementId?.trim();
if (/^G-[A-Z0-9]+$/.test(measurementId || "")) {
  window.dataLayer = window.dataLayer || [];
  window.gtag = (...args) => window.dataLayer.push(args);
  window.gtag("js", new Date());
  window.gtag("config", measurementId, { anonymize_ip: true });
  const analyticsScript = document.createElement("script");
  analyticsScript.async = true;
  analyticsScript.src = `https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(measurementId)}`;
  document.head.append(analyticsScript);
}
