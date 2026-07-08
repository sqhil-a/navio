const prefersReducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)",
).matches;

const phone = document.querySelector(".phone");
const cursorGlow = document.querySelector(".cursor-glow");
const scrollProgress = document.querySelector(".scroll-progress");
const scorePanel = document.querySelector(".score-panel");

/* ── Hamburger menu ── */
const hamburger = document.querySelector(".hamburger");
const mobileNav = document.querySelector(".mobile-nav");
const mobileNavOverlay = document.querySelector(".mobile-nav-overlay");

function openNav() {
  hamburger?.classList.add("open");
  hamburger?.setAttribute("aria-expanded", "true");
  mobileNav?.classList.add("open");
  mobileNav?.setAttribute("aria-hidden", "false");
  mobileNavOverlay?.classList.add("open");
  mobileNavOverlay?.setAttribute("aria-hidden", "false");
  document.body.classList.add("nav-open");
}

function closeNav() {
  hamburger?.classList.remove("open");
  hamburger?.setAttribute("aria-expanded", "false");
  mobileNav?.classList.remove("open");
  mobileNav?.setAttribute("aria-hidden", "true");
  mobileNavOverlay?.classList.remove("open");
  mobileNavOverlay?.setAttribute("aria-hidden", "true");
  document.body.classList.remove("nav-open");
}

hamburger?.addEventListener("click", () => {
  const isOpen = hamburger.classList.contains("open");
  isOpen ? closeNav() : openNav();
});

mobileNavOverlay?.addEventListener("click", closeNav);

mobileNav?.querySelectorAll("a").forEach((link) => {
  link.addEventListener("click", closeNav);
});

if (!prefersReducedMotion) {
  let targetX = 0;
  let targetY = 0;
  let currentX = 0;
  let currentY = 0;

  let glowX = window.innerWidth / 2;
  let glowY = window.innerHeight / 2;
  let currentGlowX = glowX;
  let currentGlowY = glowY;

  function animate() {
    currentX += (targetX - currentX) * 0.075;
    currentY += (targetY - currentY) * 0.075;

    currentGlowX += (glowX - currentGlowX) * 0.08;
    currentGlowY += (glowY - currentGlowY) * 0.08;

    if (phone && window.innerWidth >= 900) {
      phone.style.transform = `
        rotateX(${3 - currentY * 5.5}deg)
        rotateY(${-7 + currentX * 7.5}deg)
        translateY(${currentY * 8}px)
        scale(${1 + Math.abs(currentX) * 0.012})
      `;
    }

    if (cursorGlow) {
      cursorGlow.style.transform = `translate3d(${currentGlowX - 230}px, ${
        currentGlowY - 230
      }px, 0)`;
    }

    requestAnimationFrame(animate);
  }

  window.addEventListener(
    "pointermove",
    (event) => {
      targetX = event.clientX / window.innerWidth - 0.5;
      targetY = event.clientY / window.innerHeight - 0.5;

      glowX = event.clientX;
      glowY = event.clientY;
    },
    { passive: true },
  );

  window.addEventListener(
    "pointerleave",
    () => {
      targetX = 0;
      targetY = 0;
      if (cursorGlow) cursorGlow.style.opacity = "0";
    },
    { passive: true },
  );

  window.addEventListener(
    "pointerenter",
    () => {
      if (cursorGlow) cursorGlow.style.opacity = "0.8";
    },
    { passive: true },
  );

  window.addEventListener(
    "scroll",
    () => {
      const scrollTop = window.scrollY;
      const pageHeight = document.documentElement.scrollHeight - window.innerHeight;
      const progress = pageHeight <= 0 ? 0 : scrollTop / pageHeight;

      if (scrollProgress) {
        scrollProgress.style.transform = `scaleX(${progress})`;
      }
    },
    { passive: true },
  );

  if (scorePanel) {
    scorePanel.addEventListener(
      "pointermove",
      (event) => {
        const rect = scorePanel.getBoundingClientRect();
        const x = ((event.clientX - rect.left) / rect.width) * 100;
        const y = ((event.clientY - rect.top) / rect.height) * 100;

        scorePanel.style.setProperty("--mx", `${x}%`);
        scorePanel.style.setProperty("--my", `${y}%`);
      },
      { passive: true },
    );
  }

  animate();

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry, index) => {
        if (!entry.isIntersecting) return;

        entry.target.style.transitionDelay = `${index * 70}ms`;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    },
    {
      threshold: 0.16,
      rootMargin: "0px 0px -70px 0px",
    },
  );

  document
    .querySelectorAll(
      ".feature, .founder-card, .program-list article, .app-showcase, .score-panel, .contact, .contact-card-grid article, .section-head",
    )
    .forEach((el) => {
      el.classList.add("reveal");
      observer.observe(el);
    });
}
