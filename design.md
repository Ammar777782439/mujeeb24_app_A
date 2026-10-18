# Mujeeb 24 — Mobile App Design System

> Product design brief derived from the supplied `mujeeb24-backend-go` repository, generated OpenAPI contract, project-status documentation, and the public landing-page URL. This document describes the merchant-facing mobile app, not the public marketing landing page or platform super-admin console.

## 1. Product understanding

**Product:** Mujeeb 24 — a multi-merchant conversation and sales operations platform.

**Brand promise:** “لا تفوّت عميلك، ولو كنت مشغولًا.” / “Never miss a customer, even when you're busy.”

**Primary users:** business owners, sales/support agents, and team managers operating customer conversations, product catalogs, leads, and sales transactions.

**Core capabilities evidenced by the backend contract:**
- Authentication, refresh/logout, current principal, and accessible businesses.
- Merchant overview/dashboard.
- Customer conversation inbox, conversation details, messages, assignments, labels, read state, private notes, and reusable replies.
- Customer directory and customer profiles, related conversations and transactions, merge operation.
- Product catalogs, catalog items, variants, offers, and attribute schemas.
- Leads and qualification/lost states, attributions and lead scores.
- Transaction drafts, editing, confirmation/cancellation, and transaction review workflow.
- Channel connection provisioning, capabilities, reconnect/disconnect, and history-purge preview/confirmation.
- Team members, roles/access, invitations, canned replies, automation rules, business profile and policy.
- Merchant catalog AI turns and a separate approve-and-execute operation for stored catalog proposals.
- AI decisions and human review requests; audit events.

**Important boundary:** the repository is a Go backend, not a mobile client. Stitch should create visual screens and interaction prototypes only. Do not claim the backend has push notifications, offline sync, biometric login, file upload, payment gateway, or any unverified feature. The API contract is served under `/api/v1`; its server URL is relative, so the production base URL must be configured by the implementation team.

## 2. Design goals

1. Make the inbox and responding to customers the fastest, most prominent workflow.
2. Make complex merchant operations comfortable on a phone, not a squeezed desktop dashboard.
3. Support Arabic and English as first-class languages, with correct RTL/LTR layout mirroring.
4. Keep AI suggestions visibly distinct from confirmed business data and require an explicit review/approval step before any proposal execution.
5. Use the supplied website `https://mujeeb24.com/landing` as the brand reference. Inspect it directly in Stitch/browser when available; carry over its logo, actual colors, typography, tone, and visual motifs. Do not invent a conflicting identity or copy the landing page's marketing layout into the product app.
6. Use realistic, coherent demo data for prototypes, but label it as sample data and never represent it as live API data.

## 3. Visual direction

- Direction: polished, contemporary B2B SaaS; confident, calm, clear, approachable.
- Mobile-first, with one-handed reachability and concise information hierarchy.
- Use the brand colors sampled from the reference site. If the site cannot be inspected, use a restrained neutral foundation and a single brand-primary accent as a temporary token, clearly marked for later replacement.
- Use a legible Arabic UI typeface (for example, IBM Plex Sans Arabic or Noto Sans Arabic) and a compatible Latin font (for example, Inter). Confirm licensing and availability before implementation.
- Avoid overdecorated gradients, excessive glassmorphism, tiny charts, crowded tables, and generic AI sparkle decoration everywhere.
- Prefer 8pt spacing rhythm, rounded cards with restrained radius, clear separators, and accessible contrast.
- Use simple line icons with consistent stroke. Icons must mirror direction only where direction has semantic meaning; familiar brand/service icons should not be arbitrarily mirrored.
- Use light theme as the initial design baseline. Dark theme is optional and must not delay core screens.

## 4. Responsive mobile shell and navigation

Design for contemporary phone frames first (approximately 390 × 844 logical px), and show at least one smaller phone adaptation. Do not design a tablet/desktop-only layout.

Suggested bottom navigation (5 destinations maximum):
1. الرئيسية / Home
2. المحادثات / Inbox
3. العملاء / Customers
4. المبيعات / Sales (leads and transactions)
5. المزيد / More (catalog, channels, team, settings, AI tools)

Use a contextual top app bar with business switcher when the user has access to multiple businesses, screen title, search/filter actions where appropriate, and a visible language switch in settings. Preserve selected tab and scroll position when practical.

The exact final nav grouping is a design recommendation, not an API constraint. If a screen is nested, use a back action rather than adding another bottom tab.

## 5. Screen inventory and required states

### A. Entry and account
- Splash/brand loading state (brief, not a marketing screen).
- Login: email/username field and password based on actual login schema; show validation, incorrect credentials, rate-limit, and network-error states. Do not invent social login.
- Invitation inspection/acceptance: invitation token entry/deep-link landing, show validity/expiry/error, then new-account or existing-account acceptance as supported by the API.
- Business selection: only if `/me/businesses` returns multiple accessible businesses.
- Session-expired/re-authentication state.

### B. Home dashboard
- Summary cards based on the real `/businesses/{business_id}/dashboard/overview` response schema.
- Quick actions: open inbox, add customer, create lead, add catalog item, where permissions allow.
- Recent or actionable work only if returned by API. Do not fabricate KPI fields not in the schema.
- Skeleton loading, empty state for a new business, partial-data state, retry/error state.

### C. Inbox
- Conversation list with customer, last message preview, timestamp, channel badge, unread state, assignment, and status only when present in the API projection.
- Search and filters mapped to supported query parameters: state, ownership, channel, customer_id; use pagination cursor/limit as appropriate.
- Conversation details: message timeline, customer context, status/labels, assignee, internal notes, reusable replies, composer, send status.
- Actions: mark read, assign, update conversation, update labels, send a message intent, add private note, send canned reply.
- Message send UX must distinguish queued/pending, delivered/failed/unknown when supported. Do not show “sent” before backend confirmation.
- Empty inbox, no-filter-results, offline/network error, loading, permission-denied and send-failure states.
- Do not assume attachments, voice notes, reactions, typing indicators, presence, or read receipts beyond the explicit API contract.

### D. Customers
- Customer list with search/filter only where contract supports it; paginated list.
- Create/edit customer form using exact API DTO fields.
- Customer profile with available details, related conversations, and related transactions.
- Merge customer confirmation flow with a strong irreversible-action warning and clear source/target selection.

### E. Sales
- Leads list, lead detail/edit, create lead, qualify lead, mark as lost, attribution and score views.
- Transactions list, transaction detail, create draft, edit draft, cancel, confirm, submit for review, review details, approve/reject review.
- Distinguish draft, awaiting review, confirmed, cancelled, and other states only when those values exist in the contract.
- Confirm consequential actions with explicit confirmation and show success/failure from the API.

### F. Catalog
- Catalog list, create, detail/edit.
- Catalog items list, create, detail/edit.
- Item variants and offers: list/create/edit where endpoint exists.
- Attribute schema list/create/detail.
- Product forms should accommodate Arabic and English names/descriptions if the data model allows them; verify DTO schemas before defining field names.
- Product cards should prioritize image only if the API actually supplies an image field; otherwise use a neutral placeholder and do not invent image upload.

### G. AI-assisted catalog authoring
- Dedicated assistant conversation for merchant catalog authoring, with context and draft/proposal display.
- Clearly label generated suggestions as suggestions, not saved catalog facts.
- Preview all proposed changes before approval. The actual execution action maps to `POST /businesses/{business_id}/merchant-ai/executions` and should be explicit, permission-aware, and protected against double submission.
- Show validation issues, conflict/stale-version states, retry/error states, and an audit/decision detail where appropriate.
- Do not let AI propose unsupported actions, invent price/stock/policy facts, or imply that an operation has executed before the backend confirms it.

### H. Channels
- Connected-channel list, connection details, capabilities, connect/provisioning, reconnect, disconnect.
- Show channel status only from API data.
- History purge: first show the API preview, then a separate explicit confirmation screen/modal that explains local conversation history deletion is irreversible. Never place purge next to a normal button without safeguards.
- Do not hardcode supported providers; derive options from the current API response/capabilities.

### I. Team and settings
- Team member list, role/access editing, revoke membership; guard against revoking the last active owner.
- Invitation list/create/resend/revoke; never expose invitation tokens in list views.
- Canned replies list/create/edit.
- Automation rules list/create/edit with clear enabled/disabled state only if supported by DTO.
- Business profile and business policy settings.
- Language setting (Arabic/English), account/session logout, app information.

### J. Review and audit
- AI decisions list/detail and request-human-review action.
- Business audit-event list/detail, with readable timestamps and event summaries.
- These screens may be placed under More/Settings and shown according to user permissions.

### K. Error and system states
- Loading skeletons; empty states with a single relevant next action; form validation; API/network failure with retry; expired session; forbidden/permission error; not-found; conflict/stale-data; rate-limit; destructive confirmation; success toast/inline confirmation.
- Use Arabic and English copy for all system states, not just screen titles.

## 6. Core user flows

### Flow 1: Sign in → select business → Home
1. Login request to `POST /auth/login`.
2. Load principal with `GET /me` and accessible businesses with `GET /me/businesses`.
3. If multiple businesses, select one; otherwise continue.
4. Load dashboard overview for selected business.
5. If access token expires, use `POST /auth/refresh` only according to the backend session contract; logout calls `POST /auth/logout`.

### Flow 2: Reply to customer
1. Open Inbox and load `GET /businesses/{business_id}/conversations`.
2. Open a conversation and load conversation projection and messages.
3. Mark read, assign/update labels if needed, add private note or choose canned reply.
4. Send message through `POST /businesses/{business_id}/conversations/{conversation_id}/messages` or the canned-reply send endpoint.
5. Reflect pending/result/error states from server response; never optimistically claim external delivery.

### Flow 3: Add/update catalog item with AI assistance
1. Browse catalogs/items.
2. Start a merchant AI turn using `POST /businesses/{business_id}/merchant-ai/turns`.
3. Review returned structured proposal and validation messages.
4. Explicitly approve execution through `POST /businesses/{business_id}/merchant-ai/executions` only when the proposal is eligible.
5. Refresh catalog item and show confirmed persisted result.

### Flow 4: Manage lead and transaction
1. Open lead list, inspect details, edit or qualify/mark lost.
2. Create a transaction draft linked to customer/lead where schema supports it.
3. Edit draft; submit for review if needed; inspect review result; approve/reject or confirm/cancel according to the contract.

### Flow 5: Connect channel
1. Start channel provisioning from channel connections.
2. Show pending/authorization/in-progress state based on returned response; never fake OAuth completion.
3. Display current connection and capabilities.
4. Offer reconnect/disconnect. History purge is a separate guarded flow with preview and final confirmation.

### Flow 6: Invite a team member
1. Create a one-time invitation.
2. Show a share action only if the API returns a usable invitation URL/token for that one-time response; never expose tokens in list views or logs.
3. Show invitation status; allow resend/revoke.
4. Edit roles/access with explicit permission boundaries.

## 7. API integration map

Base path in OpenAPI: `/api/v1` (server URL is relative). Confirm the deployed origin and any gateway prefix before wiring.

| App area | Key endpoints evidenced by OpenAPI |
|---|---|
| Authentication | `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, `GET /me`, `GET /me/businesses` |
| Dashboard | `GET /businesses/{business_id}/dashboard/overview` |
| Business profile/policy | `GET/PATCH /businesses/{business_id}`, `GET/PATCH /businesses/{business_id}/policy` |
| Conversations | `GET /businesses/{business_id}/conversations`, `GET/PATCH /businesses/{business_id}/conversations/{conversation_id}`, `POST .../assign`, `POST .../labels`, `GET/POST .../messages`, `POST .../notes`, `POST .../read`, canned-reply send endpoint |
| Customers | `GET/POST /businesses/{business_id}/customers`, `GET/PATCH /businesses/{business_id}/customers/{customer_id}`, customer conversations/transactions, `POST .../merge` |
| Leads | `GET/POST /businesses/{business_id}/leads`, `GET/PATCH .../{lead_id}`, `POST .../qualify`, `POST .../mark-lost`, attributions and scores |
| Transactions | `GET/POST /businesses/{business_id}/transactions`, `GET/PATCH .../{transaction_id}`, cancel/confirm, submit-review and review approve/reject |
| Catalog | catalogs, catalog items, variants, offers, attribute schemas under `/businesses/{business_id}/...` |
| Channels | `/businesses/{business_id}/channel-connections` and connection detail/capabilities/reconnect/disconnect/history-purge endpoints |
| Team | `/businesses/{business_id}/team/members`, `/team/invitations` and member role/access/revoke operations |
| Canned replies/automation | `/businesses/{business_id}/canned-replies`, `/businesses/{business_id}/automation-rules` |
| Merchant AI | `POST /businesses/{business_id}/merchant-ai/turns`, `POST /businesses/{business_id}/merchant-ai/executions` |
| AI decisions/audit | `/businesses/{business_id}/ai-decisions`, `/businesses/{business_id}/audit-events` |

The generated OpenAPI document is the source of truth for field names, request/response DTOs, required properties, enums, security, and error shapes. Before implementation, inspect each operation's schema; do not infer fields from endpoint names.

## 8. Localization and RTL requirements

- Arabic is the default prototype locale; include English variants for all key screens.
- In Arabic, set the entire layout to RTL: navigation, list ordering, form labels, back/forward affordances, drawer placement, and alignment. In English, mirror to LTR.
- Use locale-aware dates and numerals; avoid concatenating translated fragments. Keep phone numbers, emails, IDs, URLs, and code-like values directionally isolated to avoid bidi corruption.
- Arabic labels should be natural, concise, and consistent. Avoid machine-translated wording.
- Long Arabic names and message previews must wrap gracefully. Provide flexible layout for both short and long English strings.
- Language change must not alter the selected business, current work, or saved data.

## 9. Accessibility and interaction

- WCAG AA contrast target for text and controls.
- Touch targets around 44 × 44 pt minimum.
- Do not communicate status by color alone; pair color with text/icon.
- Visible focus state in keyboard-capable prototypes; accessible labels for icon-only controls.
- Confirm destructive actions, preserve form data after recoverable errors, and prevent duplicate submissions.
- Ensure bottom sheets, dialogs, keyboard, and message composer work on short screens.

## 10. Design deliverables expected from Stitch

Create a coherent high-fidelity mobile UI kit and connected screen flow, not a single hero mockup:
1. Arabic RTL core flow.
2. English LTR counterparts for all primary screens.
3. Design system page: colors sampled from reference, typography, spacing, radii, buttons, fields, chips, cards, tabs, bottom sheets, badges, empty/loading/error states.
4. High-fidelity screens: login, business selection, home, inbox list, conversation detail, customers list/detail, leads list/detail, transactions list/detail/review, catalog list/item form/item detail, AI proposal review, channels, team, settings, AI decision/audit detail.
5. At least the primary flow should be linked in a clickable prototype.
6. Include realistic empty/loading/error/success and destructive confirmation states for critical workflows.
7. Keep the component system consistent across screens and locales.

## 11. Out of scope / do not invent

- Public landing page redesign (it is only a brand reference).
- Platform super-admin screens such as plan billing, global AI-provider configuration, platform-wide usage, and platform business administration. Those endpoints exist but are not part of the primary merchant mobile app; only create them if explicitly requested later.
- Payment gateway checkout or consumer shopping app unless a separate product requirement confirms this.
- Push notification settings, attachments, offline mode, biometric login, voice/video calls, and other features not evidenced by the current contract.
- Hardcoded provider/channel names, business metrics, prices, stock levels, message delivery states, or unsupported API fields.

## 12. Open implementation checks

Before connecting the design to a real app, confirm:
- Deployed API base URL and CORS/gateway behavior for mobile clients.
- Exact DTO fields/enums for each selected endpoint in `api/openapi/mujeeb24-dashboard-v1.generated.yaml`.
- Supported channel providers and the full provisioning/OAuth handoff experience.
- Which role/permission values should hide or disable each action.
- Whether the production website provides approved logo assets and exact brand tokens.
- Whether push notifications are planned; they are not assumed by this design brief.
