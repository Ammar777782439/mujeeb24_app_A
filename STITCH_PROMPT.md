# Google Stitch — Master Prompt for Mujeeb 24 Mobile App

Use this prompt in Google Stitch. Provide the repository URL and landing-page URL as references, and attach `design.md` as project guidance if Stitch supports reference files.

---

You are a senior product designer creating a production-quality mobile app UI for **Mujeeb 24**, a merchant-facing customer conversation and sales operations platform. This is a mobile product interface, not a marketing landing page.

## Required references
- Backend repository: https://github.com/Ammar777782439/mujeeb24-backend-go
- Brand / visual reference: https://mujeeb24.com/landing
- Design specification: `design.md`

Inspect the landing page for the real logo, brand palette, typography, imagery, and visual language. Reuse the brand identity faithfully while adapting it into a practical mobile application. Do not simply reproduce the landing-page layout. Treat the repository's generated OpenAPI document and design.md as the source of truth for product capabilities. If a reference is inaccessible, do not pretend to have inspected it; use a restrained temporary design system and mark brand tokens as pending verification.

## Product context
Mujeeb 24 helps businesses manage customer conversations, customers, leads, transactions, product catalogs, connected communication channels, teams, canned replies, automation rules, and carefully reviewed AI-assisted catalog operations. The brand promise is “لا تفوّت عميلك، ولو كنت مشغولًا.” / “Never miss a customer, even when you're busy.”

## Deliverable
Create a coherent high-fidelity **mobile app** with connected screens and a reusable component system. Design mobile-first for a typical phone viewport around 390 × 844 logical pixels. Include a smaller-phone adaptation. Do not create desktop dashboard mockups as the primary deliverable.

## Languages and direction
- Create Arabic screens first, with correct RTL layout.
- Provide English LTR counterparts for all key screens.
- Mirror the whole layout appropriately between RTL and LTR; isolate IDs, URLs, email addresses, and phone numbers from bidi layout problems.
- Use natural, concise Arabic UI copy, not literal awkward translations.
- Include localized date/time formatting and ensure long Arabic text wraps naturally.

## Main navigation
Use a clear mobile navigation with no more than five bottom tabs, recommended: Home, Inbox, Customers, Sales, More. Put catalog, channels, team, AI authoring, audit/review, and settings under More or sensible nested screens. Include a business switcher only when multiple businesses are available to the signed-in user.

## Screens to design
1. Splash/loading and login, including validation and authentication errors.
2. Invitation acceptance and business selection (conditional on multiple businesses).
3. Home dashboard using only metrics that the API overview actually returns.
4. Inbox list with search/filter, unread state, assignment, channel/status badges when supported.
5. Conversation detail with message timeline, composer, assignment, labels, private notes, and canned replies.
6. Customer list, create/edit form, customer profile, related conversations/transactions, and guarded merge flow.
7. Leads list/detail, create/edit, qualify, and mark-lost states.
8. Transactions list/detail, draft creation/editing, submit-for-review, review detail, approve/reject, confirm/cancel flows.
9. Catalog list/detail, catalog item list/form, variants, offers, and attribute schema screens.
10. Merchant AI catalog authoring conversation, proposal preview, validation errors, explicit approval/execution state, and successful persisted result.
11. Channel connections list/detail, provisioning, reconnect/disconnect, capabilities, and a highly guarded history-purge preview/confirmation flow.
12. Team members, role/access editing, invitation creation/list/resend/revoke, canned replies, automation rules, business profile and policy settings.
13. AI decision details, request-human-review, audit event list/detail, and account/language settings.
14. System states: skeleton loading, empty, no results, form validation, API error/retry, expired session, forbidden, conflict/stale data, rate-limit, success, pending send, failed/unknown send, and destructive confirmation.

## Core UX priorities
- The inbox and customer response workflow are the central experience.
- Keep high-frequency actions reachable with one hand and forms usable on a phone.
- Use progressive disclosure for advanced controls.
- Clearly distinguish private notes from customer-visible messages.
- Make pending, queued, sent, delivered, failed, and unknown delivery states distinct only when the API supplies those states. Never claim delivery before server confirmation.
- AI output is a suggestion, not trusted business truth. Always show the proposal and validation feedback before execution. Use a deliberate confirmation action for AI proposal execution.
- Use explicit confirmations for cancel, disconnect, customer merge, member revocation, and irreversible history purge.
- Respect permissions; do not show privileged actions as available to everyone.

## API-aware constraints
The backend is Go and the generated OpenAPI contract is located at `api/openapi/mujeeb24-dashboard-v1.generated.yaml`. The API path prefix is `/api/v1`. Key operation families include:
- Auth: `/auth/login`, `/auth/refresh`, `/auth/logout`, `/me`, `/me/businesses`
- Dashboard: `/businesses/{business_id}/dashboard/overview`
- Conversations: `/businesses/{business_id}/conversations` and nested messages, notes, assign, labels, read, canned-reply send
- Customers, leads, transactions, catalogs, catalog items, variants, offers, attribute schemas
- Channel connections, team members/invitations, canned replies, automation rules, business policy
- Merchant AI turns and explicit execution, AI decisions, and audit events

Do not invent request fields, metrics, statuses, provider names, attachments, push notifications, offline mode, payment gateway, biometric sign-in, or any feature not supported by the contract. Use the OpenAPI schemas for exact data shapes before implying that a control is wired. Design is allowed to use realistic sample content, but it must be treated as prototype-only sample data.

## Visual system
- Modern, premium-but-practical B2B SaaS UI that matches the supplied Mujeeb 24 website identity.
- Sample actual brand tokens from the website if accessible. Do not guess brand colors if they can be observed.
- Use legible Arabic typography and a compatible Latin typeface.
- Establish consistent spacing, radii, elevation, button hierarchy, form controls, badges, chips, list rows, bottom sheets, alerts, and confirmation dialogs.
- Prioritize readability, high contrast, restrained use of accent color, and generous touch targets.
- Avoid generic dashboard clutter, overly dense tables, decorative gradients everywhere, and excessive AI-themed visual clichés.
- Use meaningful icons with consistent stroke; mirror directional icons in RTL where appropriate.

## Required prototype behavior
Link the main flow so it can be explored:
Login → business selection (if applicable) → Home → Inbox → Conversation detail → send/reply state.
Also link:
Home/More → Catalog → AI proposal → Review → explicit execution confirmation → updated catalog item.
Use clickable navigation, tabs, filters, dialogs, and primary actions where Stitch supports interactions. Prototype interactions must not imply a live backend connection.

## Quality bar
Deliver a unified app, not unrelated screen concepts. Every screen must share the same design system and maintain correct Arabic RTL and English LTR behavior. Include loading, empty, error, success, and destructive states for key workflows. Make the interface credible for daily use by a small business owner or support/sales team. Keep platform super-admin operations out of the main merchant app unless separately requested.

Start by producing the design system and the Arabic RTL core flow. Then extend the same components to the remaining screens and English LTR counterparts. If anything in the repository or website cannot be inspected, explicitly list it as an assumption instead of inventing product behavior.
