import React, { useEffect, useMemo, useState } from "react";
import { pageContent } from "./page-content.js";

const email = "hello@naviopathways.com";
const instagram = "https://www.instagram.com/naviopathways/";
const linkedin = "https://www.linkedin.com/company/navio-pathways/";
const primaryNav = [
  ["About", "/about/"],
  ["Opportunities", "/opportunities/"],
  ["Resources", "/resources/"],
  ["Get involved", "/get-involved/"],
];
const exploreLinks = [
  ["About", "/about/"],
  ["Opportunities", "/opportunities/"],
  ["Resources", "/resources/"],
  ["Navio Journal", "https://journal.naviopathways.com/"],
  ["Get involved", "/get-involved/"],
];
const policyLinks = [
  ["Privacy", "/privacy/"],
  ["Terms", "/terms/"],
  ["Accessibility", "/accessibility/"],
  ["Youth safety", "/youth-safety/"],
];

const normalizePath = (path) => {
  if (!path) return "/";
  if (path === "/404.html") return path;
  return path === "/" || path.endsWith("/") ? path : `${path}/`;
};

const getPage = (path) => pageContent[normalizePath(path)] || pageContent["/404.html"];

function Brand({ footer = false }) {
  return (
    <a className={`brand${footer ? " brand-footer" : ""}`} href="/" aria-label="Navio Pathways home">
      <span className="brand-wordmark" aria-hidden="true" />
    </a>
  );
}

function Header({ path }) {
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  useEffect(() => {
    const close = (event) => event.key === "Escape" && setOpen(false);
    document.addEventListener("keydown", close);
    return () => document.removeEventListener("keydown", close);
  }, []);
  useEffect(() => {
    document.body.classList.toggle("menu-open", open);
    return () => document.body.classList.remove("menu-open");
  }, [open]);
  useEffect(() => {
    const update = () => setScrolled(window.scrollY > 16);
    update();
    window.addEventListener("scroll", update, { passive: true });
    return () => window.removeEventListener("scroll", update);
  }, []);
  const activeHref = primaryNav.find(([, href]) => path.startsWith(href))?.[1];
  return (
    <>
      <a className="skip-link" href="#main-content">Skip to main content</a>
      <header className={`site-header${scrolled ? " is-scrolled" : ""}`}>
        <div className="header-inner">
          <Brand />
          <nav className="desktop-nav" aria-label="Primary navigation">
            {primaryNav.map(([label, href]) => <a key={href} href={href} aria-current={activeHref === href ? "page" : undefined}>{label}</a>)}
          </nav>
          <div className="header-actions">
            <a className="button button-small button-primary desktop-cta" href="/contact/">Contact us</a>
            <button className={`menu-toggle${open ? " is-open" : ""}`} type="button" aria-expanded={open} aria-controls="mobile-menu" onClick={() => setOpen((value) => !value)}>
              <span className="sr-only">{open ? "Close" : "Open"} navigation menu</span>
              <span aria-hidden="true" /><span aria-hidden="true" /><span aria-hidden="true" />
            </button>
          </div>
        </div>
        <div className={`mobile-menu${open ? " is-open" : ""}`} id="mobile-menu" aria-hidden={!open}>
          <nav aria-label="Mobile navigation">
            {[...primaryNav, ["Contact", "/contact/"]].map(([label, href]) => (
              <a key={`${label}-${href}`} href={href} onClick={() => setOpen(false)}>{label}</a>
            ))}
          </nav>
        </div>
      </header>
    </>
  );
}

function LinkList({ links }) {
  return <ul>{links.map(([label, href]) => <li key={href}><a href={href}>{label}</a></li>)}</ul>;
}

function Footer() {
  return (
    <footer className="site-footer">
      <div className="footer-grid">
        <div className="footer-intro">
          <Brand footer />
          <p>Practical career, volunteer, and leadership guidance for young people in Ontario.</p>
          <p className="legal-name"><strong>Navio Pathways</strong><br />Ontario incorporated not-for-profit organization<br />Corporation Number 1001662092</p>
        </div>
        <div><h2>Explore</h2><LinkList links={exploreLinks} /></div>
        <div><h2>Contact</h2><ul className="footer-contact-links"><li><a href={`mailto:${email}`}>{email}</a></li><li><a href={instagram} target="_blank" rel="noopener noreferrer">Instagram <span aria-hidden="true">↗</span></a></li><li><a href={linkedin} target="_blank" rel="noopener noreferrer">LinkedIn <span aria-hidden="true">↗</span></a></li></ul></div>
        <div><h2>Policies</h2><LinkList links={policyLinks} /></div>
      </div>
      <div className="footer-bottom">
        <p>© {new Date().getFullYear()} Navio Pathways. All rights reserved.</p>
        <p>Navio Pathways is not presented as a registered charity and does not advertise tax-deductible donations or charitable receipts.</p>
      </div>
    </footer>
  );
}

function useAnalytics() {
  useEffect(() => {
    const id = window.NAVIO_CONFIG?.analyticsMeasurementId?.trim();
    if (!/^G-[A-Z0-9]+$/.test(id || "")) return;
    window.dataLayer = window.dataLayer || [];
    window.gtag = (...args) => window.dataLayer.push(args);
    window.gtag("js", new Date());
    window.gtag("config", id, { anonymize_ip: true });
    const script = document.createElement("script");
    script.async = true;
    script.src = `https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(id)}`;
    document.head.append(script);
    return () => script.remove();
  }, []);
}

function usePageMotion() {
  useEffect(() => {
    const selector = [
      ".breadcrumbs",
      ".hero-copy > *",
      ".page-hero .container > *",
      ".section-heading",
      ".split-intro > *",
      ".benefit-card",
      ".info-card",
      ".contact-card",
      ".trust-panel",
      ".feature-panel",
      ".resource-card",
      ".notice",
      ".contact-note > *",
      ".policy-copy > *",
      ".final-cta .container > *",
      ".standalone-state .container > *",
      "main h1",
      "main h2",
      ".footer-grid > *",
      ".footer-bottom > *",
      ".links-shell > *",
    ].join(", ");
    const targets = [...document.querySelectorAll(selector)];
    if (!targets.length) return undefined;
    document.documentElement.classList.add("motion-enabled");
    const siblingOrder = new Map();
    targets.forEach((target) => {
      const parent = target.parentElement;
      const order = siblingOrder.get(parent) || 0;
      target.style.setProperty("--motion-delay", `${Math.min(order, 5) * 55}ms`);
      target.classList.add("motion-item");
      siblingOrder.set(parent, order + 1);
    });
    document.querySelectorAll("main h1, main h2").forEach((heading) => {
      if (heading.dataset.wordRiseReady === "true") return;
      const title = heading.textContent.trim();
      const originalLink = heading.querySelector(":scope > a");
      if (!title) return;
      heading.dataset.wordRiseReady = "true";
      heading.classList.add("word-rise");
      heading.setAttribute("aria-label", title);
      heading.replaceChildren();
      const wordTarget = originalLink ? originalLink.cloneNode(false) : heading;
      if (originalLink) wordTarget.setAttribute("aria-label", title);
      title.split(/\s+/).forEach((word, index) => {
        const clip = document.createElement("span");
        const wordElement = document.createElement("span");
        clip.className = "word-rise-clip";
        wordElement.className = "word-rise-word";
        wordElement.style.setProperty("--word-delay", `${Math.min(index, 14) * 32}ms`);
        wordElement.setAttribute("aria-hidden", "true");
        wordElement.textContent = word;
        clip.append(wordElement);
        wordTarget.append(clip, document.createTextNode(" "));
      });
      if (originalLink) heading.append(wordTarget);
    });
    const showAll = () => targets.forEach((target) => target.classList.add("is-visible"));
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches || !("IntersectionObserver" in window)) {
      showAll();
      return undefined;
    }
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.08, rootMargin: "0px 0px -5%" });
    let frame = window.requestAnimationFrame(() => {
      frame = window.requestAnimationFrame(() => targets.forEach((target) => observer.observe(target)));
    });
    return () => {
      window.cancelAnimationFrame(frame);
      observer.disconnect();
    };
  }, []);
}

function PageContent({ page }) {
  const html = useMemo(() => ({ __html: page.html }), [page.html]);
  return <main id="main-content" tabIndex="-1" dangerouslySetInnerHTML={html} />;
}

function LinkPage() {
  return (
    <main className="links-page" id="main-content">
      <div className="links-shell">
        <a className="links-brand" href="/" aria-label="Navio Pathways home">
          <span className="brand-wordmark" aria-hidden="true" />
        </a>
        <h1>Links and applications</h1>
        <p className="links-intro">Everything you need in one place.</p>
        <a className="button button-secondary links-button" href="https://naviopathways.com/">
          <span>Main site</span>
          <span aria-hidden="true">↗</span>
        </a>
        <a className="button button-primary links-button" href="https://docs.google.com/forms/d/e/1FAIpQLSeKA47m7zWXEM9rh-PJ7cWIdcP07C_sehbzSaaVUtRSE3LwkQ/viewform" target="_blank" rel="noopener noreferrer">
          <span>Join the executive team</span>
          <span aria-hidden="true">↗</span>
        </a>
        <a className="button button-secondary links-button" href="https://docs.google.com/document/d/1tscdBlxL6c1SGuCGV-u_8i-U0jk-Zx34XOODXZoyqYk/edit?usp=sharing" target="_blank" rel="noopener noreferrer">
          <span>Executive positions information</span>
          <span aria-hidden="true">↗</span>
        </a>
        <a className="button button-secondary links-button" href="https://www.instagram.com/naviopathways/" target="_blank" rel="noopener noreferrer">
          <span>Instagram</span>
          <span aria-hidden="true">↗</span>
        </a>
        <p className="links-note">Applications open in Google Forms.</p>
      </div>
    </main>
  );
}

function JournalRedirect() {
  useEffect(() => {
    window.location.replace("https://journal.naviopathways.com/");
  }, []);
  return (
    <main className="standalone-state" id="main-content">
      <div className="container narrow">
        <p className="eyebrow">Navio Journal</p>
        <h1>Continue to the Journal.</h1>
        <p className="lead">Practical career exploration for students, families, and educators.</p>
        <a className="button button-primary" href="https://journal.naviopathways.com/">Open Navio Journal</a>
      </div>
    </main>
  );
}

export function App({ path = "/" }) {
  const normalizedPath = normalizePath(path);
  const page = getPage(normalizedPath);
  useAnalytics();
  usePageMotion();
  if (normalizedPath === "/links/") return <LinkPage />;
  if (normalizedPath === "/journal/") return <JournalRedirect />;
  return <><Header path={normalizedPath} /><PageContent page={page} /><Footer /></>;
}
