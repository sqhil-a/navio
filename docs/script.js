const prefersReducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)",
).matches;

if (!prefersReducedMotion) {
  const phone = document.querySelector(".phone");

  window.addEventListener("pointermove", (event) => {
    if (!phone || window.innerWidth < 900) return;

    const x = event.clientX / window.innerWidth - 0.5;
    const y = event.clientY / window.innerHeight - 0.5;

    phone.style.transform = `rotateX(${3 - y * 4}deg) rotateY(${
      -7 + x * 6
    }deg) translateY(${y * 6}px)`;
  });

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) entry.target.classList.add("is-visible");
      });
    },
    { threshold: 0.18 },
  );

  document.querySelectorAll(".feature, .score-panel, .download").forEach((el) => {
    el.classList.add("reveal");
    observer.observe(el);
  });
}
