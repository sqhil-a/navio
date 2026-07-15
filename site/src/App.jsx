import React, { useEffect, useMemo, useState } from "react";
import { pageContent } from "./page-content.js";

const email = "hello@naviopathways.com";
const instagram = "https://www.instagram.com/naviopathways/";
const primaryNav = [
  ["About", "/about/"],
  ["Opportunities", "/opportunities/"],
  ["Volunteer", "/volunteer/"],
  ["Resources", "/resources/"],
  ["Updates", "/updates/"],
];
const exploreLinks = [
  ["About", "/about/"], ["Opportunities", "/opportunities/"],
  ["Get involved", "/get-involved/"], ["Partner with us", "/partner/"],
];
const connectLinks = [
  ["Volunteer", "/volunteer/"], ["Resources", "/resources/"],
  ["Updates", "/updates/"], ["Contact", "/contact/"],
];
const policyLinks = [
  ["Privacy", "/privacy/"], ["Terms", "/terms/"],
  ["Accessibility", "/accessibility/"], ["Youth safety", "/youth-safety/"],
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
  useEffect(() => {
    const close = (event) => event.key === "Escape" && setOpen(false);
    document.addEventListener("keydown", close);
    return () => document.removeEventListener("keydown", close);
  }, []);
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
            <a className="button button-small button-primary desktop-cta" href="/get-involved/">Get involved</a>
            <button className="menu-toggle" type="button" aria-expanded={open} aria-controls="mobile-menu" onClick={() => setOpen((value) => !value)}>
              <span className="sr-only">{open ? "Close" : "Open"} navigation menu</span>
              <span aria-hidden="true" /><span aria-hidden="true" /><span aria-hidden="true" />
            </button>
          </div>
        </div>
        <div className="mobile-menu" id="mobile-menu" hidden={!open}>
          <nav aria-label="Mobile navigation">
            {[...primaryNav, ["Get involved", "/get-involved/"], ["Partner with us", "/partner/"], ["Contact", "/contact/"]].map(([label, href]) => (
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
          <p>Helping young people explore careers, build practical skills, connect with community, and take their next step with greater direction.</p>
          <p className="legal-name"><strong>Navio Pathways</strong><br />Ontario incorporated not-for-profit organization</p>
        </div>
        <div><h2>Explore</h2><LinkList links={exploreLinks} /></div>
        <div><h2>Connect</h2><LinkList links={connectLinks} /><ul className="footer-contact-links"><li><a href={instagram} target="_blank" rel="noopener noreferrer">Instagram <span aria-hidden="true">↗</span></a></li><li><a href={`mailto:${email}`}>{email}</a></li></ul></div>
        <div><h2>Policies</h2><LinkList links={policyLinks} /></div>
      </div>
      <div className="footer-bottom">
        <p>© {new Date().getFullYear()} Navio Pathways. All rights reserved.</p>
        <p>Navio Pathways is not presented as a registered charity and does not currently advertise tax-deductible donations or charitable receipts.</p>
      </div>
    </footer>
  );
}

function sendAnalyticsEvent(name, details = {}) {
  if (!name) return;
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({ event: name, ...details });
  window.dispatchEvent(new CustomEvent("navio:analytics", { detail: { name, ...details } }));
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

function useForms() {
  useEffect(() => {
    const controllers = [];
    const forms = [...document.querySelectorAll("[data-async-form]")];
    for (const form of forms) {
      const controller = new AbortController();
      controllers.push(controller);
      form.addEventListener("submit", async (event) => {
        event.preventDefault();
        if (form.dataset.submitting === "true") return;
        const status = form.querySelector("[data-form-status]");
        const button = form.querySelector("[data-submit-button]");
        status.className = "form-status";
        if (!form.checkValidity()) {
          form.reportValidity();
          status.textContent = "Please complete the required fields before sending.";
          status.classList.add("is-error");
          form.querySelector(":invalid")?.focus();
          return;
        }
        const formData = new FormData(form);
        if (formData.get("website")) return;
        const kind = form.dataset.formKind || "contact";
        const endpoint = window.NAVIO_CONFIG?.formEndpoints?.[kind]?.trim();
        if (!endpoint) {
          status.textContent = `Online submission is not configured yet. Please email ${email}.`;
          status.classList.add("is-error");
          return;
        }
        form.dataset.submitting = "true";
        button.disabled = true;
        status.textContent = "Sending…";
        try {
          const response = await fetch(endpoint, { method: "POST", body: formData, headers: { Accept: "application/json" } });
          if (!response.ok) throw new Error(`Submission failed with status ${response.status}`);
          const events = {
            contact: "contact_form_submit", volunteer: "volunteer_application_submit",
            partner: "partner_inquiry_submit", newsletter: "newsletter_signup",
          };
          sendAnalyticsEvent(events[kind], { form_kind: kind });
          window.location.assign(form.dataset.thankYou || "/thank-you/contact/");
        } catch (error) {
          console.error("Navio Pathways form submission failed", error);
          status.textContent = `We could not send this form. Your entries are still here; please try again or email ${email}.`;
          status.classList.add("is-error");
        } finally {
          delete form.dataset.submitting;
          button.disabled = false;
        }
      }, { signal: controller.signal });
    }
    return () => controllers.forEach((controller) => controller.abort());
  }, []);
}

function usePageMotion() {
  useEffect(() => {
    const targets = [...document.querySelectorAll(".section-heading, .split-intro, .two-up > *, .info-card, .audience-link, .steps li, .pathway-stack article, .status-panel, .form-panel, .page-hero .container")];
    if (!targets.length) return undefined;

    const showAll = () => targets.forEach((target) => target.classList.add("is-visible"));
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches || !("IntersectionObserver" in window)) {
      showAll();
      return undefined;
    }

    targets.forEach((target) => target.classList.add("reveal"));
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -4%" });
    targets.forEach((target) => observer.observe(target));
    return () => observer.disconnect();
  }, []);
}

function PageContent({ page }) {
  const html = useMemo(() => ({ __html: page.html }), [page.html]);
  return <main id="main-content" tabIndex="-1" dangerouslySetInnerHTML={html} />;
}

export function App({ path = "/" }) {
  const normalizedPath = normalizePath(path);
  const page = getPage(normalizedPath);
  useAnalytics();
  useForms();
  usePageMotion();
  return <><Header path={normalizedPath} /><PageContent page={page} /><Footer /></>;
}
