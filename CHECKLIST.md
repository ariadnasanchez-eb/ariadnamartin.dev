# Pre-publish checklist · ariadnamartin.dev

`scripts/check.sh` runs automatically before every `git push` and blocks the push if anything fails. These are the items a script can't judge, to review by eye whenever the page changes.

## Legal (Spain / EU)
- [ ] Privacy policy still describes every tool that collects data (Calendly, Tally, email). Adding a new form, newsletter or tool means updating `legal.html` first.
- [ ] No cookies, analytics or embeds. If any are added: cookie banner with "reject" as easy as "accept", and update the cookies section.
- [ ] Legal notice shows real business details. Add the NIF once registered as autónoma.
- [ ] Terms & conditions and refund policy: not needed while nothing is sold online. Terms go in each proposal or contract.
- [ ] Tally forms have a required consent checkbox linking to `https://ariadnamartin.dev/legal.html`.

## Content
- [ ] Every number and claim can be defended on a call (see Evidence on Hand in PRODUCT.md).
- [ ] No testimonials, logos or case studies unless they are real and the client gave written permission.
- [ ] Images are our own or properly licensed. Fonts: Poppins (SIL Open Font License, self-hosted).

## Accessibility
- [ ] New colours keep text contrast at 4.5:1 (3:1 for large text).
- [ ] Buttons and links say what they do ("Book a free Health Check", not "Click here").
- [ ] Page still works with the keyboard alone (Tab through it once).

## Final look
- [ ] Desktop and mobile screenshots of the changed sections.
- [ ] After publishing: open https://ariadnamartin.dev in a private window.
