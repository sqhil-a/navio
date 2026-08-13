import React, { useEffect, useMemo, useState } from "react";
import { pageContent, programPath, workbookPath } from "./page-content.js";

const email = "hello@naviopathways.com";
const instagram = "https://www.instagram.com/naviopathways/";
const linkedin = "https://www.linkedin.com/company/navio-pathways/";
const primaryNav = [
  ["Program", programPath],
  ["Workbook", workbookPath],
  ["Resources", "/resources/"],
  ["About", "/about/"],
];
const exploreLinks = [
  ["Career Clarity Program", programPath],
  ["Program workbook", workbookPath],
  ["Resources", "/resources/"],
  ["About", "/about/"],
  ["Contact", "/contact/"],
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
  const activeHref = primaryNav
    .filter(([, href]) => path.startsWith(href))
    .sort(([, left], [, right]) => right.length - left.length)[0]?.[1];
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
          <p>Home of the free Navio Career Clarity Program for Ontario secondary students.</p>
          <p className="legal-name"><strong>Navio Pathways</strong><br />Ontario incorporated not-for-profit organization<br />Corporation Number 1001662092</p>
        </div>
        <div><h2>Explore</h2><LinkList links={exploreLinks} /></div>
        <div><h2>Contact</h2><ul className="footer-contact-links"><li><a href={`mailto:${email}`}>{email}</a></li><li><a href={instagram} target="_blank" rel="noopener noreferrer">Instagram <span aria-hidden="true">↗</span></a></li><li><a href={linkedin} target="_blank" rel="noopener noreferrer">LinkedIn <span aria-hidden="true">↗</span></a></li></ul><address className="footer-address"><span>Address</span>3140 Polo Place<br />Mississauga, Ontario</address></div>
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
        <h1>Navio Pathways links</h1>
        <p className="links-intro">The Career Clarity Program, workbook, resources, and ways to connect.</p>
        <a className="button button-primary links-button" href={programPath}>
          <span>Career Clarity Program</span>
          <span aria-hidden="true">→</span>
        </a>
        <a className="button button-secondary links-button" href={workbookPath}>
          <span>Program workbook</span>
          <span aria-hidden="true">→</span>
        </a>
        <a className="button button-secondary links-button" href="/resources/">
          <span>Career resources</span>
          <span aria-hidden="true">→</span>
        </a>
        <a className="button button-secondary links-button" href="/contact/">
          <span>Contact Navio</span>
          <span aria-hidden="true">→</span>
        </a>
        <a className="button button-secondary links-button" href="https://www.instagram.com/naviopathways/" target="_blank" rel="noopener noreferrer">
          <span>Instagram</span>
          <span aria-hidden="true">↗</span>
        </a>
        <p className="links-note">Official links from Navio Pathways.</p>
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

function LegacyProgramRedirect() {
  useEffect(() => {
    window.location.replace(programPath);
  }, []);
  return (
    <main className="standalone-state" id="main-content">
      <div className="container narrow">
        <p className="eyebrow">Program moved</p>
        <h1>The career toolkit is now the Career Clarity Program.</h1>
        <p className="lead">Continue to the named five-stage program and workbook.</p>
        <a className="button button-primary" href={programPath}>Open the Career Clarity Program</a>
      </div>
    </main>
  );
}

export function App({ path = "/" }) {
  const normalizedPath = normalizePath(path);
  const page = getPage(normalizedPath);
  useAnalytics();
  if (normalizedPath === "/links/") return <LinkPage />;
  if (normalizedPath === "/journal/") return <JournalRedirect />;
  if (normalizedPath === "/career-workshops/") return <LegacyProgramRedirect />;
  return <><Header path={normalizedPath} /><PageContent page={page} /><Footer /></>;
}
