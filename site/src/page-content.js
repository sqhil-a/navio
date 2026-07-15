const email = "hello@naviopathways.com";
const instagram = "https://www.instagram.com/naviopathways/";
const linkedin = "https://www.linkedin.com/company/navio-pathways/";
const executiveForm = "https://docs.google.com/forms/d/e/1FAIpQLSeKA47m7zWXEM9rh-PJ7cWIdcP07C_sehbzSaaVUtRSE3LwkQ/viewform";

const breadcrumb = (label) => `<nav class="breadcrumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><span aria-current="page">${label}</span></li></ol></nav>`;
const internalHero = (eyebrow, title, description, actions = "") => `<section class="page-hero page-hero-compact"><div class="container narrow"><p class="eyebrow">${eyebrow}</p><h1>${title}</h1><p class="lead">${description}</p>${actions}</div></section>`;
const photoPlaceholder = (description, dimensions = "1600 × 1200") => `<figure class="photo-placeholder" role="img" aria-label="${description}"><span class="photo-star" aria-hidden="true">✦</span><figcaption><strong>Real community photo reserved</strong><span>${description}</span><small>Recommended source size: ${dimensions}</small></figcaption></figure>`;
const contactCta = (title = "Have a question?") => `<section class="section final-cta compact-cta"><div class="container"><p class="eyebrow">Contact</p><h2>${title}</h2><p>Email our team or connect with us online.</p><div class="button-row centered"><a class="button button-light" href="mailto:${email}">Email Navio</a><a class="button button-outline-light" href="${instagram}" target="_blank" rel="noopener noreferrer">Instagram <span class="sr-only">(opens in a new tab)</span></a><a class="button button-outline-light" href="${linkedin}" target="_blank" rel="noopener noreferrer">LinkedIn <span class="sr-only">(opens in a new tab)</span></a></div></div></section>`;

export const pageContent = {
  "/": {
    path: "/",
    title: "Navio Pathways | Career, volunteer, and leadership guidance for youth",
    description: "Navio Pathways helps Ontario youth explore careers, find meaningful volunteer opportunities, build leadership skills, and prepare for what comes next.",
    noindex: false,
    html: `<section class="hero human-hero"><div class="container hero-grid"><div class="hero-copy"><p class="eyebrow">Youth development in Ontario</p><h1>Helping young people find direction and build their future.</h1><p class="lead">Navio Pathways connects Ontario youth with career exploration, volunteer opportunities, leadership experiences, and practical guidance for the future.</p><div class="button-row"><a class="button button-primary" href="/opportunities/">Explore opportunities</a><a class="button button-secondary" href="/about/">Learn about Navio</a></div></div><div class="hero-photo-wrap">${photoPlaceholder("A real photograph of Ontario students collaborating at a Navio Pathways activity")}</div></div></section>
    <section class="section benefits-section"><div class="container"><div class="section-heading concise-heading"><p class="eyebrow">What you can do</p><h2>Explore, contribute, and build experience.</h2></div><div class="benefit-grid"><a class="benefit-card" href="/opportunities/#careers"><span aria-hidden="true">01</span><h3>Explore careers</h3><p>Discover possible education and career paths.</p></a><a class="benefit-card" href="/opportunities/#volunteering"><span aria-hidden="true">02</span><h3>Earn volunteer hours</h3><p>Find meaningful ways to serve your community.</p></a><a class="benefit-card" href="/opportunities/#leadership"><span aria-hidden="true">03</span><h3>Build leadership</h3><p>Gain experience through projects and youth-led work.</p></a><a class="benefit-card" href="/resources/"><span aria-hidden="true">04</span><h3>Prepare for the future</h3><p>Build confidence, practical skills, and direction.</p></a></div></div></section>
    <section class="section section-tint"><div class="container split-intro human-split"><div><p class="eyebrow">Why Navio</p><h2>Big decisions should not start with guesswork.</h2></div><div><p>Students are often asked to choose a direction before they have seen enough real options. Navio Pathways creates room to ask better questions, learn from community, and try practical next steps.</p><a class="text-link" href="/about/">Read our story <span aria-hidden="true">→</span></a></div></div></section>
    <section class="section"><div class="container trust-panel"><div><p class="eyebrow">Built for youth. Supported by community.</p><h2>Clear about where we are today.</h2><p>Navio Pathways is an Ontario incorporated not-for-profit. We publish opportunities only when the details are confirmed, and we do not claim impact numbers that have not been verified.</p></div><dl class="trust-facts"><div><dt>Organization</dt><dd>Ontario not-for-profit</dd></div><div><dt>Focus</dt><dd>Youth career and community development</dd></div><div><dt>Current status</dt><dd>Programs and partnerships in development</dd></div></dl></div></section>
    <section class="section section-dark"><div class="container photo-story"><div>${photoPlaceholder("A real photograph of a youth workshop, student presentation, or volunteer project", "1800 × 1200")}</div><div><p class="eyebrow">Real people, real experience</p><h2>Community photos will be added with consent.</h2><p>We will use real Navio Pathways photography once programs are documented and participants have provided the right permissions. We will not use fake event photos or AI-generated people.</p><a class="button button-secondary" href="/get-involved/">See ways to help</a></div></div></section>
    ${contactCta("Want to help create useful opportunities for youth?")}`,
  },

  "/about/": {
    path: "/about/",
    title: "About Navio Pathways | A youth-focused Ontario nonprofit",
    description: "Learn why Navio Pathways was created, how it supports young people, and what guides its work as an Ontario not-for-profit.",
    noindex: false,
    html: `${breadcrumb("About")}${internalHero("About Navio", "More clarity. More real-world exposure. Less pressure to have it all figured out.", "Navio Pathways helps young people explore careers, build practical skills, and connect with community before making major decisions.")}
    <section class="section"><div class="container split-intro"><div><p class="eyebrow">Our mission</p><h2>Make the future easier to explore.</h2></div><div><p>We create practical guidance and community-connected experiences that help youth understand their options, contribute meaningfully, and choose informed next steps.</p><p>Navio is not a school, placement agency, or promise of a particular outcome. It is a place to explore, learn, and build experience.</p></div></div></section>
    <section class="section section-tint"><div class="container two-up"><div>${photoPlaceholder("A real portrait of the Navio Pathways founder or leadership team")}</div><div><p class="eyebrow">Leadership</p><h2>Sahil Ambegaonkar</h2><p>Sahil founded Navio Pathways after seeing how often students are expected to make major career decisions without enough context, structure, or encouragement.</p><p>Additional executive and board biographies will be published only after roles, names, and consent are confirmed.</p><a class="text-link" href="/get-involved/#executive-team">Join the executive team <span aria-hidden="true">→</span></a></div></div></section>
    <section class="section"><div class="container"><div class="section-heading concise-heading"><p class="eyebrow">How we work</p><h2>Practical, honest, and youth-centred.</h2></div><div class="benefit-grid three"><article class="benefit-card"><span aria-hidden="true">01</span><h3>Start with real questions</h3><p>We focus on what young people actually need to understand.</p></article><article class="benefit-card"><span aria-hidden="true">02</span><h3>Connect learning to action</h3><p>Resources should lead to useful conversations and experiences.</p></article><article class="benefit-card"><span aria-hidden="true">03</span><h3>Be clear about status</h3><p>We do not invent openings, results, partnerships, or statistics.</p></article></div></div></section>
    ${contactCta("Want to learn more about Navio Pathways?")}`,
  },

  "/opportunities/": {
    path: "/opportunities/",
    title: "Youth opportunities | Navio Pathways",
    description: "Explore Navio Pathways career, volunteer, leadership, mentorship, and youth-project opportunities with clear availability information.",
    noindex: false,
    html: `${breadcrumb("Opportunities")}${internalHero("Opportunities", "Explore careers, gain experience, and build confidence.", "Our opportunity areas are gathered in one place so you can quickly understand what Navio is developing and what is available now.", `<div class="button-row"><a class="button button-primary" href="#opportunity-list">View opportunity areas</a></div>`)}
    <section class="section compact"><div class="container"><div class="notice notice-neutral"><strong>Current status:</strong> Navio Pathways does not currently publish an open program intake or confirmed event. Join the executive team through the external application, or contact us to express interest in future opportunities.</div></div></section>
    <section class="section" id="opportunity-list"><div class="container opportunity-grid"><article class="info-card" id="careers"><p class="eyebrow">Career exploration</p><h2>Understand your options.</h2><p>Compare fields, learn what work is really like, and identify small ways to test an interest.</p><a class="text-link" href="/resources/#career-guide">Use the career guide <span aria-hidden="true">→</span></a></article><article class="info-card" id="volunteering"><p class="eyebrow">Volunteering</p><h2>Contribute with purpose.</h2><p>Future roles will have clear responsibilities, supervision, schedules, and eligible community-service information.</p><a class="text-link" href="mailto:${email}?subject=Volunteer%20interest">Email your interest <span aria-hidden="true">→</span></a></article><article class="info-card" id="leadership"><p class="eyebrow">Leadership and youth projects</p><h2>Learn by doing.</h2><p>Help shape resources, events, communications, and projects with clear adult guidance and accountability.</p><a class="text-link" href="/get-involved/#executive-team">View the executive application <span aria-hidden="true">→</span></a></article><article class="info-card" id="mentorship"><p class="eyebrow">Mentorship and workshops</p><h2>Learn from community.</h2><p>Future talks and structured activities will help youth ask professionals better questions in a safe setting.</p><a class="text-link" href="mailto:${email}?subject=Mentor%20or%20workshop%20interest">Contact our team <span aria-hidden="true">→</span></a></article></div></section>
    ${contactCta("Interested in a future opportunity?")}`,
  },

  "/get-involved/": {
    path: "/get-involved/",
    title: "Get involved with Navio Pathways",
    description: "Join the Navio Pathways executive team, express volunteer interest, or connect as a school, mentor, sponsor, or community partner.",
    noindex: false,
    html: `${internalHero("Get involved", "Help build practical opportunities for young people.", "Choose the role that fits your experience and availability. We will always be clear about what is active and what is still being developed.")}
    <section class="section" id="executive-team"><div class="container feature-panel"><div><p class="eyebrow">Executive team</p><h2>Help shape Navio Pathways.</h2><p>We are looking for thoughtful people who can take ownership, communicate reliably, and help build programs, partnerships, operations, or outreach.</p><p>The application opens in Google Forms and does not submit information through this website.</p><a class="button button-primary" href="${executiveForm}" target="_blank" rel="noopener noreferrer">Apply to the executive team <span class="sr-only">(opens in a new tab)</span></a></div><div>${photoPlaceholder("A real team photo from a future Navio Pathways planning session")}</div></div></section>
    <section class="section section-tint"><div class="container"><div class="section-heading concise-heading"><p class="eyebrow">Other ways to help</p><h2>Start with a direct conversation.</h2></div><div class="benefit-grid three"><a class="benefit-card" href="mailto:${email}?subject=Volunteer%20interest"><span aria-hidden="true">01</span><h3>Volunteer</h3><p>Tell us what you can contribute and when you are available.</p></a><a class="benefit-card" href="mailto:${email}?subject=School%20or%20community%20partnership"><span aria-hidden="true">02</span><h3>Partner</h3><p>Discuss a school, community, business, or sponsor collaboration.</p></a><a class="benefit-card" href="mailto:${email}?subject=Mentor%20or%20speaker%20interest"><span aria-hidden="true">03</span><h3>Mentor or speak</h3><p>Share practical experience through a future structured activity.</p></a></div></div></section>
    ${contactCta("Not sure where you fit?")}`,
  },

  "/resources/": {
    path: "/resources/",
    title: "Youth career and leadership resources | Navio Pathways",
    description: "Use concise Navio Pathways guides for career exploration, professional conversations, leadership reflection, and volunteering.",
    noindex: false,
    html: `${breadcrumb("Resources")}${internalHero("Resources", "Simple tools for your next useful step.", "These guides are available now. Use them on your own, with a parent or guardian, or with an educator.")}
    <section class="section"><div class="container resource-stack"><article class="resource-card" id="career-guide"><p class="eyebrow">Career guide</p><h2>Five steps to explore a career.</h2><ol class="compact-list"><li><strong>Notice:</strong> Write down tasks and topics that hold your attention.</li><li><strong>Research:</strong> Compare daily work, training routes, environments, and tradeoffs.</li><li><strong>Ask:</strong> Speak with someone who can share real examples.</li><li><strong>Try:</strong> Choose a small project, course, event, or volunteer task.</li><li><strong>Reflect:</strong> Decide what you want to explore next.</li></ol></article><article class="resource-card"><p class="eyebrow">Professional conversation</p><h2>Ask questions that reveal the work.</h2><ul class="check-list"><li>What surprised you when you entered this field?</li><li>Which skill do beginners underestimate?</li><li>What does a normal week look like?</li><li>What is one low-risk way to test my interest?</li></ul></article><article class="resource-card"><p class="eyebrow">Leadership reflection</p><h2>Describe what you did, not only your title.</h2><p>Write down the situation, your responsibility, the action you took, and what changed. Be specific about your contribution and what you would do differently next time.</p></article></div></section>
    <section class="section section-tint"><div class="container notice notice-neutral"><strong>Important:</strong> These resources provide general educational guidance. They do not guarantee admission, employment, volunteer hours, salary, or a particular outcome.</div></section>
    ${contactCta("Have a resource suggestion?")}`,
  },

  "/contact/": {
    path: "/contact/",
    title: "Contact Navio Pathways",
    description: "Contact Navio Pathways by email or Instagram about youth opportunities, volunteering, partnerships, schools, or community collaboration.",
    noindex: false,
    html: `${breadcrumb("Contact")}${internalHero("Contact", "Talk directly with our team.", "Use email, Instagram, or LinkedIn for updates, questions, and collaboration.")}
    <section class="section"><div class="container contact-grid simple-contact"><a class="contact-card" href="mailto:${email}"><span aria-hidden="true">@</span><div><p class="eyebrow">Email</p><h2>${email}</h2><p>Best for opportunities, volunteering, schools, partnerships, and detailed questions.</p></div></a><a class="contact-card" href="${instagram}" target="_blank" rel="noopener noreferrer"><span aria-hidden="true">◎</span><div><p class="eyebrow">Instagram</p><h2>@naviopathways</h2><p>Follow updates or send a short message. Opens in a new tab.</p></div></a><a class="contact-card" href="${linkedin}" target="_blank" rel="noopener noreferrer"><span aria-hidden="true">in</span><div><p class="eyebrow">LinkedIn</p><h2>Navio Pathways</h2><p>Connect with the organization and follow our community work.</p></div></a></div></section>
    <section class="section section-tint"><div class="container narrow contact-note"><h2>Help us respond clearly.</h2><p>Include your name, your connection to Navio Pathways, what you are asking about, and any useful timing. Do not email sensitive personal information about a young person.</p></div></section>`,
  },

  "/privacy/": {
    path: "/privacy/",
    title: "Privacy policy | Navio Pathways",
    description: "Read how the Navio Pathways public website approaches privacy, direct contact, analytics, youth information, and external services.",
    noindex: false,
    html: `${breadcrumb("Privacy")}${internalHero("Privacy", "A plain-language approach to website privacy.", "This page describes the public website. It should be reviewed as Navio Pathways programs and systems develop.")}
    <section class="section"><div class="container narrow policy-copy"><h2>Information you choose to send</h2><p>This website does not contain inquiry forms or collect application data. If you email us, use Instagram, or open the external executive application, the relevant service processes the information you choose to provide.</p><h2>Analytics</h2><p>Analytics is disabled unless a valid measurement ID is configured after privacy review. We do not intentionally send message content or form answers to analytics services.</p><h2>Youth privacy</h2><p>Do not send unnecessary sensitive information about a young person. Program-specific consent, retention, access, and safeguarding procedures must be confirmed before collecting participant information.</p><h2>Contact</h2><p>Questions can be sent to <a href="mailto:${email}">${email}</a>.</p></div></section>`,
  },

  "/terms/": {
    path: "/terms/",
    title: "Website terms | Navio Pathways",
    description: "Read the terms for using the Navio Pathways public website and its general educational resources.",
    noindex: false,
    html: `${breadcrumb("Terms")}${internalHero("Website terms", "Clear expectations for using this site.", "These terms apply to the public Navio Pathways website and general resources.")}
    <section class="section"><div class="container narrow policy-copy"><h2>General information</h2><p>Website content is for general educational and organizational information. It is not professional, academic, legal, financial, medical, or career advice.</p><h2>No guaranteed opportunity</h2><p>A message, application, or expression of interest does not guarantee acceptance, placement, volunteer hours, mentorship, employment, admission, or another outcome.</p><h2>Appropriate use</h2><p>Do not misuse the website, interfere with its operation, impersonate another person, or submit harmful or unlawful content through linked services.</p><h2>External services</h2><p>Links to email, Instagram, and Google Forms are governed by those services. Review their terms and privacy practices before sharing information.</p><h2>Contact</h2><p>Questions can be sent to <a href="mailto:${email}">${email}</a>.</p></div></section>`,
  },

  "/accessibility/": {
    path: "/accessibility/",
    title: "Accessibility statement | Navio Pathways",
    description: "Read the Navio Pathways commitment to accessible content, keyboard use, readable design, reduced motion, and feedback.",
    noindex: false,
    html: `${breadcrumb("Accessibility")}${internalHero("Accessibility", "A website more people can use.", "Navio Pathways aims to make its public information clear, readable, and compatible with common assistive technologies.")}
    <section class="section"><div class="container narrow policy-copy"><h2>What we support</h2><ul class="check-list"><li>Keyboard navigation and visible focus states</li><li>Semantic headings and landmarks</li><li>Strong colour contrast and readable type</li><li>Responsive layouts without horizontal scrolling</li><li>Reduced-motion preferences</li><li>Descriptive alternatives for meaningful images</li></ul><h2>Feedback</h2><p>If something is difficult to access, email <a href="mailto:${email}?subject=Accessibility%20feedback">${email}</a>. Include the page, the problem, and the format or support that would help.</p></div></section>`,
  },

  "/youth-safety/": {
    path: "/youth-safety/",
    title: "Youth safety approach | Navio Pathways",
    description: "Read the Navio Pathways public youth-safety approach for boundaries, privacy, communication, reporting, and future activities.",
    noindex: false,
    html: `${breadcrumb("Youth safety")}${internalHero("Youth safety", "Safety needs structure, not assumptions.", "This public summary sets expectations while detailed operating procedures are developed and reviewed.")}
    <section class="section"><div class="container narrow policy-copy"><h2>Core expectations</h2><ul class="check-list"><li>Treat every young person with dignity and respect.</li><li>Keep communication transparent and use approved channels.</li><li>Do not request unnecessary personal information or private contact.</li><li>Use clear supervision, consent, privacy, and reporting procedures.</li><li>Act on concerns and prohibit retaliation for good-faith reports.</li></ul><h2>Report a concern</h2><p>Email <a href="mailto:${email}?subject=Youth%20safety%20concern">${email}</a> with “Youth safety concern” in the subject line. If someone is in immediate danger, contact local emergency services.</p><div class="notice notice-important"><strong>Status:</strong> Detailed screening, escalation, recordkeeping, and activity procedures require appropriate professional review before recurring youth programming launches.</div></div></section>`,
  },

  "/links/": {
    path: "/links/",
    title: "Navio Pathways links",
    description: "Connect with Navio Pathways and apply to join the executive team.",
    noindex: true,
    html: `<section class="links-placeholder"><h1>Navio Pathways links</h1><p>Connect with Navio Pathways and apply to join the executive team.</p></section>`,
  },

  "/404.html": {
    path: "/404.html",
    title: "Page not found | Navio Pathways",
    description: "The requested Navio Pathways page could not be found.",
    noindex: true,
    html: `<section class="standalone-state"><div class="container narrow"><span class="state-mark" aria-hidden="true">?</span><p class="eyebrow">Page not found</p><h1>This page is no longer here.</h1><p class="lead">We recently simplified the website. The information you need may now be on one of the pages below.</p><div class="button-row centered"><a class="button button-primary" href="/opportunities/">View opportunities</a><a class="button button-secondary" href="/">Return home</a></div><div class="quick-links"><a href="/about/">About</a><a href="/get-involved/">Get involved</a><a href="/resources/">Resources</a><a href="/contact/">Contact</a></div></div></section>`,
  },
};
