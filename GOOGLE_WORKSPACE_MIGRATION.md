# Google Workspace activation and Gmail migration

Last reviewed: August 12, 2026

Google Workspace for Nonprofits activation is pending. Website copy is not the principal Workspace activation gate; Google also requires an eligible verified organization, an active Workspace account, a verified primary domain, and an authorized administrator.

## Current public DNS observation

Observed before implementation:

- `naviopathways.com` mail is routed to Zoho MX servers.
- A Google site-verification TXT record is present.
- Two separate SPF TXT records are published: one authorizes Google; the other authorizes Zoho and Porkbun.
- No DMARC record was returned by the public DNS check.

Multiple SPF policies can produce an SPF permanent error. Consolidate authorized senders into one SPF policy, but do not remove an active sender until its mail path is understood and tested.

## While activation is pending

- [ ] Confirm `naviopathways.com` is the verified primary domain in Google Admin, not a secondary domain or alias.
- [ ] Confirm the Workspace subscription or trial is active.
- [ ] Confirm the applying account is a super administrator and is controlled by Navio Pathways.
- [ ] Preserve current Zoho MX records so `hello@naviopathways.com` continues receiving mail.
- [ ] Inventory every legitimate outbound sender, including Zoho, Google, Porkbun forwarding, forms, and any mailing service.
- [ ] Consolidate the two SPF records into one policy containing only senders that are genuinely active; verify SPF with Google Admin Toolbox.
- [ ] Do not switch MX records merely to influence the nonprofit review.

## Controlled migration after approval

1. Export or back up Zoho mail and record the current MX, SPF, DKIM, and forwarding configuration.
2. Create and test required Gmail users, aliases, and groups, including `hello@naviopathways.com`.
3. Lower DNS TTL ahead of the agreed migration window if appropriate.
4. Replace Zoho MX records with the current Google-prescribed MX configuration and activate Gmail in Google Admin.
5. Update the single SPF record so it authorizes Google and any other sender that remains active; remove obsolete Zoho or forwarding includes only after verification.
6. Generate a 2048-bit Google DKIM key, publish it, start authentication, and verify `DKIM=pass` on a message delivered to an external account.
7. After SPF and DKIM have operated for at least 48 hours, publish DMARC with `p=none` and an organization-controlled aggregate-report address.
8. Review DMARC reports for at least one week before gradually moving to quarantine and later reject, if reports show all legitimate senders authenticate correctly.
9. Test inbound, outbound, reply, forwarding, aliases, groups, mobile clients, spam placement, and recovery/rollback.
10. Retain the Zoho backup until the organization approves migration completion.

## Official references

- [Activate Google Workspace for Nonprofits](https://support.google.com/nonprofits/answer/3367223)
- [Set up Google Workspace MX records](https://support.google.com/a/answer/6156494)
- [Set up SPF](https://support.google.com/a/answer/33786)
- [Set up DKIM](https://support.google.com/a/answer/174124)
- [Recommended DMARC rollout](https://support.google.com/a/answer/10032473)
