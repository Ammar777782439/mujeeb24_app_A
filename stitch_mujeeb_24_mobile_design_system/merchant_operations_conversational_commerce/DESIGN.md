---
name: Merchant Operations & Conversational Commerce
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#414754'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#717785'
  outline-variant: '#c1c6d6'
  surface-tint: '#005db7'
  primary: '#005bb3'
  on-primary: '#ffffff'
  primary-container: '#0073e0'
  on-primary-container: '#fefcff'
  inverse-primary: '#a9c7ff'
  secondary: '#395aaf'
  on-secondary: '#ffffff'
  secondary-container: '#86a5ff'
  on-secondary-container: '#0b378b'
  tertiary: '#006385'
  on-tertiary: '#ffffff'
  tertiary-container: '#007ea7'
  on-tertiary-container: '#fbfcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#a9c7ff'
  on-primary-fixed: '#001b3d'
  on-primary-fixed-variant: '#00468c'
  secondary-fixed: '#dbe1ff'
  secondary-fixed-dim: '#b3c5ff'
  on-secondary-fixed: '#001849'
  on-secondary-fixed-variant: '#1b4195'
  tertiary-fixed: '#c2e8ff'
  tertiary-fixed-dim: '#77d1ff'
  on-tertiary-fixed: '#001e2c'
  on-tertiary-fixed-variant: '#004d68'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
  surface-canvas: '#FFFFFF'
  surface-subtle: '#F8FAFC'
  surface-muted: '#F1F5F9'
  border-hairline: '#E2E8F0'
  text-muted: '#64748B'
  status-success: '#059669'
  status-success-container: '#ECFDF5'
  status-warning: '#D97706'
  status-warning-container: '#FFFBEB'
  status-error: '#EF4444'
  status-error-container: '#FEF2F2'
  ai-suggested: '#7C3AED'
  ai-suggested-container: '#F5F3FF'
  channel-whatsapp: '#25D366'
  channel-instagram: '#E1306C'
  channel-facebook: '#1877F2'
  presence-online: '#10B981'
  presence-offline: '#94A3B8'
typography:
  display-lg:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: '0'
  body-base:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: '0'
  body-bold:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: '0'
  label-caps:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  caption-sm:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 14px
    letterSpacing: '0'
  stat-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  code-mono:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: '0'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system establishes a clinical, high-clarity, and trustworthy B2B SaaS atmosphere tailored specifically for merchant-facing mobile conversational commerce and sales operations. The core audience comprises active business owners, operations managers, and merchant sales agents operating across fast-paced omnichannel funnels (WhatsApp, Instagram, Facebook). 

The emotional response evoked must be one of **decisive control, immediate scannability, and operational certainty**. In high-velocity commercial environments, ambiguous UI states can lead to lost orders or miscommunicated customer negotiations. Therefore, visual noise is strictly minimized: decorative glassmorphism, distracting backdrop blurs, and superficial gradient styling are eliminated in favor of high-contrast typography, crisp containment boundaries, and surgical state-driven chromatic cues.

The design movement adheres to **Modern B2B Utility & Minimalist Functionalism**:
- **RTL-First Architecture**: Native, first-class right-to-left layout mechanics designed around Arabic script baseline mechanics and proportional line rhythm, paired with symmetrical, isolated bidirectional (BiDi) containers for LTR alphanumeric tracking codes, currency markers, and telephone identifiers.
- **High-Density Legibility**: Rapid scanning on compact mobile displays, using structured visual anchors (solid badges, crisp separators, clear status indicators).
- **Asynchronous Integrity**: UI treatments deliberately differentiate between optimistic local drafts, AI-generated uncommitted suggestions, and verified server-side executions.

## Colors

The color palette uses a calibrated triad of blues to reinforce focused operational execution, supported by an ultra-clean neutral slate hierarchy and precise semantic indicators:

- **Primary (`#087FF5` - Electric Royal Blue)**: The leading interactive anchor. Governs primary action buttons, active tab icons, unread notification pills, focused input perimeters, and outbound merchant message bubbles.
- **Secondary (`#123B8F` - Deep Cobalt Navy)**: Used for high-emphasis merchant identifiers, elevated secondary badges, and commanding structural labels.
- **Tertiary (`#18B8F2` - Cyan Sky)**: Deployed as an informative accent for telemetry, auxiliary metrics, and real-time synchronization pulses.
- **Neutral (`#0F172A` - Slate 900)**: Foundational high-contrast text color, achieving greater than 14:1 contrast ratios on card and canvas surfaces.
- **Backgrounds & Containers**: Canvas is pure `#FFFFFF` for sharp daylight contrast, supported by `#F8FAFC` for secondary grouped groupings and `#F1F5F9` for inbound customer message bubbles and muted control backings.
- **Operational & Semantic Roles**:
  - `status-success` (`#059669` / `#ECFDF5`): Confirmed orders, won pipeline leads, and healthy channel connectivity.
  - `status-warning` (`#D97706` / `#FFFBEB`): Unconfirmed carts, awaiting customer payment, and pending review states.
  - `status-error` (`#EF4444` / `#FEF2F2`): Disconnected channels, failed webhook dispatches, and destructive warnings.
  - `ai-suggested` (`#7C3AED` / `#F5F3FF`): Explicitly designates automated recommendations, draft completions, and routing heuristics.
  - Channel Tokens: Strict compliance with third-party service branding (`#25D366` WhatsApp, `#E1306C` Instagram, `#1877F2` Facebook).

## Typography

The typographic architecture is dual-engine: **IBM Plex Sans Arabic** directs Arabic RTL copy, headings, and general message UI, while **Inter** is mapped to label tokens, numeric tallies, and Latin data presentation.

### Bi-Directional (BiDi) Isolation Rules
1. **Numeric & Identifier Protection**: International phone numbers (e.g., `+966 50 123 4567`), order numbers (`#ORD-9021`), UUIDs, and API credentials must be explicitly wrapped in directional isolation wrappers (`<bdi>` or `direction: ltr; unicode-bidi: isolate;`). This prevents Arabic punctuation inversion when punctuation marks or mathematical operators border numbers.
2. **Arabic Vertical Rhythm**: Arabic typography incorporates tall ascenders and extensive downward loops. All body line heights maintain an expanded minimum +4px clearance relative to Latin conventions to avoid letterhead truncation or overlap with diacritics.
3. **Monospaced Data**: System transaction signatures and API keys strictly map to `code-mono` (`JetBrains Mono`) rendered in LTR orientation.

## Layout & Spacing

This design system is strictly mobile-first, targeting compact handheld operational environments (`390×844` baseline viewport, scaling down gracefully to `360×640`). Tablet and desktop variants are omitted to enforce purposeful mobile density and swift thumb reachability.

### Layout Philosophy & Structure
- **8pt Incremental Grid**: Every layout relationship scales through exact multiples of 8px (with 4px used exclusively for compact inline elements such as badge text-padding and avatar badges).
- **Edge Boundaries**: The root canvas enforces a fixed horizontal `1rem` (16px) margin. Grouped list rows, timeline bubbles, and modal elements align strictly to this outer margin.
- **Touch Ergonomics**: All interactive click targets (icons, segmented filters, row selectors, button pills) must satisfy a minimum `44 × 44 pt` bounding box, with standard interactive heights set to `48px`.
- **Keyboard & Sheet Coordination**: Conversation composers and operational bottom sheets must respect dynamic safe areas (`env(safe-area-inset-bottom)`) and yield viewport height immediately upon virtual keyboard invocation without breaking message thread scroll positions.

## Elevation & Depth

To maximize cognitive speed and reduce device rendering overhead, elevation is communicated through **tonal surface separation and low-contrast borders** rather than thick, muddy dropshadows:

- **Surface Tiers**:
  - `Level 0 (Canvas)`: Pure `#FFFFFF` background.
  - `Level 1 (Cards & Rows)`: Pure `#FFFFFF` resting over `#F8FAFC` backgrounds, bounded by 1px hairline perimeter borders (`#E2E8F0`).
  - `Level 2 (Floating Action Docks & App Bars)`: Elevated sticky containers (e.g., bottom navigation bar and active conversation composer) featuring an ultra-subtle ambient shadow: `0px -2px 8px rgba(15, 23, 42, 0.04)` combined with an upper 1px border (`#E2E8F0`).
  - `Level 3 (Modal Bottom Sheets)`: Sheet containers with 20px top corner radius, cast over a `rgba(15, 23, 42, 0.40)` dimming overlay, supported by a localized `0px -8px 24px rgba(15, 23, 42, 0.12)` ambient rise.
- **Glassmorphism Prohibition**: Translucent backdrop blurs are omitted across operational screens to avoid degradation of text legibility on lower-spec mobile devices.

## Shapes

The design system employs a refined geometric curve vocabulary that balances ergonomic softness with B2B structural rigor:

- **Base Radius (`0.5rem` / 8px - 10px)**: The standard corner curvature for input fields, interactive buttons, catalog cards, and conversation list row highlights.
- **Capsule / Pill (`rounded-full` / 9999px)**: Reserved for operational status badges, channel indicators, filter chips, and unread count markers.
- **Asymmetric Radii (Conversation Bubbles)**:
  - Inbound Bubbles: `16px` on top-start, top-end, and bottom-end corners; `4px` on bottom-start corner.
  - Outbound Bubbles: `16px` on top-start, top-end, and bottom-start corners; `4px` on bottom-end corner.
- **Sheet Drawers**: Modals transitioning from screen bottom enforce `20px` on top-left and top-right corners, with `0px` at the screen base.

## Components

### Buttons
- **Primary Action**: 48px height, `10px` radius, solid `#087FF5` fill with `#FFFFFF` text (`body-bold`). Active tap state triggers `#0668CA`.
- **Secondary Action**: 48px height, `#F0F5FF` container fill with `#123B8F` typography.
- **Destructive**: 48px height, `#FEF2F2` container fill with `#EF4444` border and text; high-severity confirmations convert to solid `#EF4444` with `#FFFFFF` text.
- **Interactive State Rule**: Optimistic state changes are forbidden. Buttons processing transactions must render an inline white spinner while maintaining their geometric dimensions until backend response receipt.

### Conversational Message Bubbles
- **Inbound (Customer)**: `#F1F5F9` background, `#0F172A` body text. Aligned to the reading-start side (Right in RTL).
- **Outbound (Merchant Agent)**: `#087FF5` background, `#FFFFFF` body text. Aligned to the reading-end side (Left in RTL). Accompanied by micro-indicators for state: Clock (Pending), Single Check (Sent), Double Check (Delivered), Electric Blue Double Check (Read).
- **AI-Suggested Draft Card**: Container `#F5F3FF` with a 1px dashed `#7C3AED` boundary. Contains an explicit header label "مسودة مقترحة من الذكاء الاصطناعي" without decorative sparkles, paired with quick actions: "تطبيق وإرسال" (Primary pill) and "تعديل" (Ghost pill).
- **Internal Team Memo**: Container `#FFFBEB` with a 1px solid `#FDE68A` border, padlock glyph, and amber-tinted annotation text.

### Badges & Operational Chips
- **Geometry**: Compact height (24px), `rounded-full` pill, padding: 4px vertical, 10px horizontal.
- **Statuses**:
  - `Online`: 8×8px `#10B981` dot with `#ECFDF5` chip backing.
  - `Unread Count`: Solid `#087FF5` pill with white bold typography (`label-caps`).
  - `Pending Transaction`: `#FFFBEB` fill with `#D97706` typography.
  - `Confirmed`: `#ECFDF5` fill with `#059669` typography.

### Inputs & Form Fields
- **Container**: 48px height, 1px `#E2E8F0` border, `#FFFFFF` fill, `10px` radius.
- **Focus**: Transitions to 2px `#087FF5` focus ring with zero outline displacement.
- **Directional Alignment**: Text align aligns to reading-start (Right for Arabic descriptions, Left for SKU, phone numbers, and currency rates).

### Lists & Segmented Cards
- **Separation**: Row divisions in dense indexes (inbox, customers, catalog) utilize an explicit 1px `#E2E8F0` hairline divider spanning from content inset to edge.
- **Channel Identifiers**: Customer avatars (48px circle) anchor a pinned 18px channel icon badge (WhatsApp, Instagram, or Facebook) on the bottom trailing corner.

### Navigation Bars
- **Contextual Top App Bar**: 56px height, pure `#FFFFFF`, housing dynamic tenant organization picker, view title, and contextual filter triggers.
- **Bottom Navigation Dock**: 64px fixed height + safe area, pure `#FFFFFF` with 1px top border (`#E2E8F0`). Exactly 5 merchant destinations: المحادثات (Conversations), العملاء والفرص (Customers & Leads), الكتالوج (Catalog), الطلبات والعمليات (Sales & Orders), and الإعدادات (Settings). Active tab displays `#087FF5` tint; inactive displays `#64748B`.