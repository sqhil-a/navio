const ROLES = Object.freeze([
  "Chief Executive Officer",
  "Chief Executive Vice President",
  "Chief Operating Officer",
  "Chief Growth Officer",
  "Chief Financial Officer",
  "Chief Marketing Officer",
  "Chief Program Officer",
  "Chief Technology Officer",
]);

const ACCESS_HASH = "60fa97d2e22292b50d431ba0a7ca35fbf6a250a6426485e63d522a52924905e4";
const accessGate = document.querySelector("#access-gate");
const generatorShell = document.querySelector("#signature-generator");
const accessForm = document.querySelector("#access-form");
const accessPassword = document.querySelector("#access-password");
const accessError = document.querySelector("#access-error");

const form = document.querySelector("#signature-form");
const nameInput = document.querySelector("#full-name");
const roleSelect = document.querySelector("#role");
const nameError = document.querySelector("#name-error");
const roleError = document.querySelector("#role-error");
const formStatus = document.querySelector("#form-status");
const preview = document.querySelector("#signature-preview");

const hashValue = async (value) => {
  const encoded = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", encoded);
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, "0")).join("");
};

const openGenerator = () => {
  accessGate.hidden = true;
  generatorShell.hidden = false;
  nameInput.focus();
};

accessForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  accessError.textContent = "";
  const enteredPassword = accessPassword.value;
  if (!enteredPassword) {
    accessError.textContent = "Enter the shared password.";
    accessPassword.focus();
    return;
  }

  const enteredHash = await hashValue(enteredPassword);
  accessPassword.value = "";
  if (enteredHash !== ACCESS_HASH) {
    accessError.textContent = "That password is not recognized.";
    accessPassword.focus();
    return;
  }
  openGenerator();
});

const escapeHtml = (value) => String(value).replace(/[&<>'"]/g, (character) => ({
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  "'": "&#39;",
  '"': "&quot;",
})[character]);

const populateRoles = () => {
  const options = ROLES.map((role) => {
    const option = document.createElement("option");
    option.value = role;
    option.textContent = role;
    return option;
  });
  roleSelect.append(...options);
};

const signatureMarkup = (fullName, role) => `
<table cellpadding="0" cellspacing="0" border="0"
       style="font-family: Arial, Helvetica, sans-serif; color:#111111;">
  <tr>
    <td style="vertical-align:middle; padding-right:14px;">
      <img
        src="https://sqhil-a.github.io/navio/assets/email-signature.png"
        alt="Navio Pathways"
        width="84"
        style="display:block; width:84px; height:auto; border:0;"
      >
    </td>
    <td
      width="1"
      style="width:1px; background-color:#6257ff; font-size:1px; line-height:1px;"
    >
      &nbsp;
    </td>
    <td style="vertical-align:middle; padding-left:14px;">
      <div style="
        font-size:16px;
        line-height:20px;
        font-weight:700;
        color:#111111;
      ">${fullName}</div>
      <div style="
        margin-top:1px;
        font-size:11px;
        line-height:14px;
        font-weight:600;
        color:#6257ff;
      ">${role}</div>
      <div style="
        margin-top:4px;
        font-size:13px;
        line-height:16px;
        font-weight:700;
        color:#111111;
      ">Navio Pathways</div>
      <div style="
        margin-top:1px;
        font-size:8px;
        line-height:10px;
        font-weight:600;
        letter-spacing:1.1px;
        color:#777777;
        text-transform:uppercase;
      ">Guiding Youth. Shaping Futures.</div>
      <table cellpadding="0" cellspacing="0" border="0" style="margin-top:7px;">
        <tr>
          <td style="padding-right:8px;">
            <a href="https://naviopathways.com" target="_blank" rel="noopener noreferrer" style="text-decoration:none;">
              <img
                src="https://sqhil-a.github.io/navio/assets/website.png"
                alt="Website"
                width="30"
                height="30"
                style="display:block; width:30px; height:30px; border:0;"
              >
            </a>
          </td>
          <td style="padding-right:8px;">
            <a href="https://www.linkedin.com/company/navio-pathways/" target="_blank" rel="noopener noreferrer" style="text-decoration:none;">
              <img
                src="https://sqhil-a.github.io/navio/assets/linkedin.png"
                alt="LinkedIn"
                width="30"
                height="30"
                style="display:block; width:30px; height:30px; border:0;"
              >
            </a>
          </td>
          <td>
            <a href="https://www.instagram.com/naviopathways/" target="_blank" rel="noopener noreferrer" style="text-decoration:none;">
              <img
                src="https://sqhil-a.github.io/navio/assets/instagram.png"
                alt="Instagram"
                width="30"
                height="30"
                style="display:block; width:30px; height:30px; border:0;"
              >
            </a>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>`;

const standaloneDocument = (fullName, role) => `<!DOCTYPE html>
<html lang="en-CA">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex, nofollow, noarchive">
  <meta name="referrer" content="no-referrer">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; img-src https:; style-src 'unsafe-inline';">
  <title>${fullName} - Navio Pathways Email Signature</title>
</head>
<body style="margin:0; padding:24px; background:#ffffff;">
${signatureMarkup(fullName, role)}
</body>
</html>`;

const selectedRole = () => ROLES.includes(roleSelect.value) ? roleSelect.value : "";

const updatePreview = () => {
  const fullName = escapeHtml(nameInput.value.trim() || "Jane Smith");
  const role = escapeHtml(selectedRole() || "Navio Pathways Role");
  preview.srcdoc = standaloneDocument(fullName, role);
};

const clearValidation = () => {
  nameInput.removeAttribute("aria-invalid");
  roleSelect.removeAttribute("aria-invalid");
  nameError.textContent = "";
  roleError.textContent = "";
  formStatus.textContent = "";
};

const validate = () => {
  clearValidation();
  const fullName = nameInput.value.trim();
  const role = selectedRole();

  if (!fullName) {
    nameInput.setAttribute("aria-invalid", "true");
    nameError.textContent = "Enter your full name.";
  }

  if (!role) {
    roleSelect.setAttribute("aria-invalid", "true");
    roleError.textContent = "Select your Navio Pathways role.";
  }

  if (!fullName) nameInput.focus();
  else if (!role) roleSelect.focus();

  return fullName && role ? { fullName, role } : null;
};

const openSignature = ({ fullName, role }) => {
  const safeName = escapeHtml(fullName);
  const safeRole = escapeHtml(role);
  const documentHtml = standaloneDocument(safeName, safeRole);
  const signatureTab = window.open("", "_blank");

  if (signatureTab) {
    signatureTab.opener = null;
    signatureTab.document.open();
    signatureTab.document.write(documentHtml);
    signatureTab.document.close();
    formStatus.textContent = "Signature opened in a new tab.";
  } else {
    formStatus.textContent = "Allow popups for this page, then generate the signature again.";
  }
};

populateRoles();
updatePreview();

nameInput.addEventListener("input", () => {
  nameInput.removeAttribute("aria-invalid");
  nameError.textContent = "";
  updatePreview();
});

roleSelect.addEventListener("change", () => {
  roleSelect.removeAttribute("aria-invalid");
  roleError.textContent = "";
  updatePreview();
});

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const values = validate();
  if (values) openSignature(values);
});
