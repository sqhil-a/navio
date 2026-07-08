const prefersReducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)",
).matches;

const appPreview = document.querySelector(".app-preview img");
const cursorGlow = document.querySelector(".cursor-glow");
const scrollProgress = document.querySelector(".scroll-progress");

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

    if (appPreview && window.innerWidth >= 900) {
      appPreview.style.transform = `
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

  document.querySelectorAll(".download-card").forEach((el) => {
    el.classList.add("reveal");
    observer.observe(el);
  });
}
