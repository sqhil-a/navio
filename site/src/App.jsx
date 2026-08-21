import React, { useMemo } from "react";
import { pageContent } from "./page-content.js";

const email = "hello@naviopathways.com";
const instagram = "https://www.instagram.com/naviopathways/";
const linkedin = "https://www.linkedin.com/company/navio-pathways/";
const primaryNav = [
  ["About", "/about/"],
  ["Explore", "/opportunities/"],
  ["Resources", "/resources/"],
  ["Get involved", "/get-involved/"],
];
const exploreLinks = [
  ["About", "/about/"],
  ["Ways to explore", "/opportunities/"],
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
  const activeHref = primaryNav.find(([, href]) => path.startsWith(href))?.[1];
  return (
    <>
      <a className="skip-link" href="#main-content">Skip to main content</a>
      <header className="site-header">
        <div className="header-inner">
          <Brand />
          <nav className="desktop-nav" aria-label="Primary navigation">
            {primaryNav.map(([label, href]) => <a key={href} href={href} aria-current={activeHref === href ? "page" : undefined}>{label}</a>)}
          </nav>
          <div className="header-actions">
            <a className="header-contact desktop-cta" href="/contact/">Contact <span aria-hidden="true">↗</span></a>
            <button className="menu-toggle" type="button" aria-expanded="false" aria-controls="mobile-menu">
              <span className="sr-only">Open navigation menu</span>
              <span aria-hidden="true" /><span aria-hidden="true" /><span aria-hidden="true" />
            </button>
          </div>
        </div>
        <div className="mobile-menu" id="mobile-menu" aria-hidden="true">
          <nav aria-label="Mobile navigation">
            {[...primaryNav, ["Contact", "/contact/"]].map(([label, href]) => (
              <a key={`${label}-${href}`} href={href} aria-current={activeHref === href ? "page" : undefined}>{label}</a>
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
          <p>Helping young people explore direction, contribution, and leadership with more context and less guesswork.</p>
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
        <h1>Official Navio Pathways links</h1>
        <p className="links-intro">Learn about the organization and contact us directly.</p>
        <a className="button button-secondary links-button" href="https://naviopathways.com/">
          <span>Main site</span>
          <span aria-hidden="true">↗</span>
        </a>
        <a className="button button-primary links-button" href="mailto:hello@naviopathways.com">
          <span>Contact Navio Pathways</span>
          <span aria-hidden="true">→</span>
        </a>
        <a className="button button-secondary links-button" href="https://www.instagram.com/naviopathways/" target="_blank" rel="noopener noreferrer">
          <span>Instagram</span>
          <span aria-hidden="true">↗</span>
        </a>
        <p className="links-note">Official organization contact: hello@naviopathways.com</p>
      </div>
    </main>
  );
}

function JournalRedirect() {
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
  if (normalizedPath === "/links/") return <LinkPage />;
  if (normalizedPath === "/journal/") return <JournalRedirect />;
  return <><Header path={normalizedPath} /><PageContent page={page} /><Footer /></>;
}
