import "./styles.css";

if (window.location.pathname === "/journal/") {
  window.location.replace("https://journal.naviopathways.com/");
}

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
  ".signal-sequence li",
  ".identity-strip p",
  ".section-heading",
  ".direction-card",
  ".reason-grid > *",
  ".journal-panel > *",
  ".organization-grid > *",
  ".story-grid > *",
  ".founder-grid > *",
  ".principle-list article",
  ".route-list > a",
  ".involvement-grid > a",
  ".resource-card",
  ".contact-route",
  ".policy-copy > *",
  ".contact-details-grid > *",
  ".contact-cta-grid > *",
].join(",");

const revealItems = [...document.querySelectorAll(revealSelector)];
const revealAll = () => revealItems.forEach((item) => item.classList.add("is-visible"));

revealItems.forEach((item, index) => {
  item.classList.add("reveal-item");
  item.style.setProperty("--reveal-delay", `${Math.min(index % 3, 2) * 70}ms`);
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

const futureSignal = document.querySelector(".future-signal");
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
if (futureSignal && !reducedMotion.matches) {
  futureSignal.addEventListener("pointermove", (event) => {
    const bounds = futureSignal.getBoundingClientRect();
    const x = ((event.clientX - bounds.left) / bounds.width) * 100;
    const y = ((event.clientY - bounds.top) / bounds.height) * 100;
    futureSignal.style.setProperty("--signal-x", `${Math.max(0, Math.min(100, x))}%`);
    futureSignal.style.setProperty("--signal-y", `${Math.max(0, Math.min(100, y))}%`);
  });
  futureSignal.addEventListener("pointerleave", () => {
    futureSignal.style.setProperty("--signal-x", "75%");
    futureSignal.style.setProperty("--signal-y", "25%");
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
