import React from "react";
import { pageContent, preparePath, programPath, registerPath, rulesPath } from "./page-content.js";

const email = "hello@naviopathways.com";
const instagram = "https://www.instagram.com/naviopathways/";
const linkedin = "https://www.linkedin.com/company/navio-pathways/";
const primaryNav = [
  ["NPCC 2026", programPath],
  ["Rules", rulesPath],
  ["Prepare", preparePath],
  ["About", "/about/"],
  ["Contact", "/contact/"],
];
const exploreLinks = [
  ["NPCC 2026", programPath],
  ["Register a team", registerPath],
  ["Official rules", rulesPath],
  ["Preparation guide", preparePath],
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
  const activeHref = primaryNav
    .filter(([, href]) => path.startsWith(href))
    .sort(([, left], [, right]) => right.length - left.length)[0]?.[1];
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
            <a className="button button-small button-primary desktop-cta" href={registerPath}>Register team</a>
            <button className="menu-toggle" type="button" aria-expanded="false" aria-controls="mobile-menu">
              <span className="sr-only">Open navigation menu</span>
              <span aria-hidden="true" /><span aria-hidden="true" /><span aria-hidden="true" />
            </button>
          </div>
        </div>
        <div className="mobile-menu" id="mobile-menu" aria-hidden="true">
          <nav aria-label="Mobile navigation">
            {primaryNav.map(([label, href]) => (
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
          <p>Home of the annual Navio Pathways Case Competition for Ontario secondary students.</p>
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

function PageContent({ page }) {
  return <main id="main-content" tabIndex="-1" dangerouslySetInnerHTML={{ __html: page.html }} />;
}

export function App({ path = "/" }) {
  const normalizedPath = normalizePath(path);
  const page = getPage(normalizedPath);
  return <><Header path={normalizedPath} /><PageContent page={page} /><Footer /></>;
}
