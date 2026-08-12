import React, { useEffect, useMemo, useState } from "react";
import { pageContent } from "./page-content.js";

const email = "hello@naviopathways.com";
const instagram = "https://www.instagram.com/naviopathways/";
const linkedin = "https://www.linkedin.com/company/navio-pathways/";
const primaryNav = [
  ["About", "/about/"],
  ["Career workshops", "/career-workshops/"],
  ["Resources", "/resources/"],
  ["Updates", "/updates/"],
  ["Get involved", "/get-involved/"],
];
const exploreLinks = [
  ["About", "/about/"],
  ["Career workshops", "/career-workshops/"],
  ["Opportunities", "/opportunities/"],
  ["Resources", "/resources/"],
  ["Updates", "/updates/"],
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
          <p>Online career-awareness workshops and practical guidance for Ontario secondary students.</p>
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

function RegistrationPage() {
  const [program, setProgram] = useState({ registrationOpen: false, registrationEndpoint: "", sessions: [] });
  const [status, setStatus] = useState("idle");
  const [message, setMessage] = useState("");

  useEffect(() => {
    const configured = window.NAVIO_CONFIG?.workshop || {};
    setProgram({
      registrationOpen: configured.registrationOpen === true,
      registrationEndpoint: typeof configured.registrationEndpoint === "string" ? configured.registrationEndpoint.trim() : "",
      sessions: Array.isArray(configured.sessions) ? configured.sessions.filter((session) => session?.id && session?.label) : [],
    });
  }, []);

  const ready = program.registrationOpen && program.registrationEndpoint.startsWith("https://") && program.sessions.length > 0;

  const submit = async (event) => {
    event.preventDefault();
    if (!ready || status === "submitting") return;
    const form = event.currentTarget;
    const data = Object.fromEntries(new FormData(form));
    if (data.website) return;
    setStatus("submitting");
    setMessage("");
    try {
      const response = await fetch(program.registrationEndpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...data, source: "naviopathways.com/career-workshops/register" }),
      });
      if (!response.ok) throw new Error(`Registration endpoint returned ${response.status}`);
      form.reset();
      setStatus("success");
      setMessage("Your registration was received. Navio Pathways will send session details to the contact email provided.");
    } catch {
      setStatus("error");
      setMessage("We could not submit your registration. Your entries remain on this page. Please try again or email hello@naviopathways.com.");
    }
  };

  return (
    <main id="main-content" tabIndex="-1">
      <nav className="breadcrumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><a href="/career-workshops/">Career workshops</a></li><li><span aria-current="page">Register</span></li></ol></nav>
      <section className="page-hero page-hero-compact"><div className="container narrow"><p className="eyebrow">Workshop registration</p><h1>Reserve a place in a career-awareness workshop.</h1><p className="lead">For Ontario secondary students. Sessions are online and offered at no cost.</p></div></section>
      <section className="section"><div className="container narrow">
        {ready ? <>
          <div className="notice notice-neutral"><strong>Before you register:</strong> Choose a published session and provide only the information requested below. If you need an accommodation, you may describe the support you need without sharing a diagnosis.</div>
          {status === "success" ? <div className="registration-success" role="status" tabIndex="-1"><p className="eyebrow">Registration received</p><h2>Thank you for registering.</h2><p>{message}</p><a className="button button-secondary" href="/resources/">Explore career resources</a></div> :
          <form className="registration-form" onSubmit={submit}>
            <div className="field"><label htmlFor="participantName">Student name</label><input id="participantName" name="participantName" autoComplete="name" required maxLength="100" /></div>
            <div className="field"><label htmlFor="contactEmail">Contact email</label><input id="contactEmail" name="contactEmail" type="email" autoComplete="email" required maxLength="254" /><small>We use this address to confirm the session and share access details.</small></div>
            <div className="field"><label htmlFor="grade">Current grade</label><select id="grade" name="grade" required defaultValue=""><option value="" disabled>Select a grade</option><option>Grade 9</option><option>Grade 10</option><option>Grade 11</option><option>Grade 12</option></select></div>
            <div className="field"><label htmlFor="sessionId">Workshop session</label><select id="sessionId" name="sessionId" required defaultValue=""><option value="" disabled>Select a session</option>{program.sessions.map((session) => <option key={session.id} value={session.id}>{session.label}</option>)}</select></div>
            <div className="field field-full"><label htmlFor="accessibilityNeeds">Accessibility request <span>(optional)</span></label><textarea id="accessibilityNeeds" name="accessibilityNeeds" rows="3" maxLength="500" /><small>Describe the support that would help; do not include medical records or a diagnosis.</small></div>
            <div className="field consent-field field-full"><label><input name="acknowledgement" type="checkbox" value="accepted" required /> <span>I confirm the information is accurate and I have reviewed the <a href="/privacy/">privacy notice</a> and <a href="/youth-safety/">youth-safety approach</a>. If required, I have permission from my parent or guardian to register.</span></label></div>
            <div className="honeypot" aria-hidden="true"><label htmlFor="website">Website</label><input id="website" name="website" tabIndex="-1" autoComplete="off" /></div>
            <div className="field-full"><button className="button button-primary" type="submit" disabled={status === "submitting"}>{status === "submitting" ? "Submitting…" : "Submit registration"}</button></div>
            <p className={`form-status${status === "error" ? " is-error" : ""}`} role="status" aria-live="polite">{message}</p>
          </form>}
        </> : <div className="registration-pending"><p className="eyebrow">Registration schedule</p><h2>Registration is not open on this page yet.</h2><p>Navio Pathways will publish confirmed session dates here before accepting registrations. We do not collect student information until a session and its privacy-reviewed registration process are ready.</p><p>Before a session opens, review the <a href="/privacy/">privacy notice</a> and <a href="/youth-safety/">youth-safety approach</a>. For workshop questions, email <a href="mailto:hello@naviopathways.com?subject=Career%20workshop%20question">hello@naviopathways.com</a>.</p><a className="button button-secondary" href="/career-workshops/">Review the workshop</a></div>}
      </div></section>
    </main>
  );
}

function LinkPage() {
  return (
    <main className="links-page" id="main-content">
      <div className="links-shell">
        <a className="links-brand" href="/" aria-label="Navio Pathways home">
          <span className="brand-wordmark" aria-hidden="true" />
        </a>
        <h1>Navio Pathways links</h1>
        <p className="links-intro">Workshops, resources, updates, and ways to connect.</p>
        <a className="button button-primary links-button" href="/career-workshops/">
          <span>Career-awareness workshops</span>
          <span aria-hidden="true">→</span>
        </a>
        <a className="button button-secondary links-button" href="/resources/">
          <span>Career resources</span>
          <span aria-hidden="true">→</span>
        </a>
        <a className="button button-secondary links-button" href="/updates/">
          <span>Latest updates</span>
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

export function App({ path = "/" }) {
  const normalizedPath = normalizePath(path);
  const page = getPage(normalizedPath);
  useAnalytics();
  if (normalizedPath === "/links/") return <LinkPage />;
  if (normalizedPath === "/journal/") return <JournalRedirect />;
  if (normalizedPath === "/career-workshops/register/") return <><Header path={normalizedPath} /><RegistrationPage /><Footer /></>;
  return <><Header path={normalizedPath} /><PageContent page={page} /><Footer /></>;
}
