---
name: Modern Material Utility
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daef'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8fd'
  surface-container-highest: '#dce2f7'
  on-surface: '#141b2b'
  on-surface-variant: '#434655'
  inverse-surface: '#293040'
  inverse-on-surface: '#edf0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#006329'
  on-tertiary: '#ffffff'
  tertiary-container: '#007f36'
  on-tertiary-container: '#c7ffca'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#f9f9ff'
  on-background: '#141b2b'
  surface-variant: '#dce2f7'
typography:
  headline-lg:
    fontFamily: Roboto Flex
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Roboto Flex
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Roboto Flex
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Roboto Flex
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Roboto Flex
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Roboto Flex
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Roboto Flex
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Roboto Flex
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-md:
    fontFamily: Roboto Flex
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Roboto Flex
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-compact: 0.75rem
  margin: 1rem
  margin-compact: 0.75rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system targets professionals, students, and mobile-first users seeking fast, trustworthy, and distraction-free document manipulation on Android. The aesthetic bridges Google's Material Design 3 guidelines with a crisp, modern utility ethos. 

The emotional signature is defined by:
- **Precision & Reliability:** High structural discipline, dependable tactile feedback, and crisp structural edges that instill immediate confidence during critical file conversions, page reordering, and signing.
- **Clarity over Clutter:** High-contrast hierarchy with subdued chrome, allowing the document viewport and batch operations to remain primary.
- **Modern Android Native Feel:** Tailored for Android conventions (scaffolds, top app bars, floating action surfaces, and bottom navigation anchors) with developer-ergonomic, declarative Flutter layouts.

## Colors

The palette leverages a precise technical blue anchored on slate neutrals and verified green accents:

- **Primary (`#2563EB`):** High-intent interactions, primary action buttons, focused states, active navigation tabs, and primary selection overlays.
- **Primary Container / Tint (`#EFF6FF`):** Tonal fills for active chips, hovered or selected list items, and file drop states.
- **Secondary / Supporting (`#64748B`):** Metadata, file sizes, page counts, secondary labels, disabled icons, and structural dividers.
- **Tertiary / Success (`#16A34A`):** Completed conversion flags, successful exports, signature verification badges, and non-destructive alerts.
- **Neutral Dark / On-Surface (`#111827`):** Primary headings, document titles, active icons, and high-emphasis body text.
- **Surface / Cards (`#FFFFFF`):** Base container fill for elevated cards, modal sheets, and dialogue panels.
- **Background (`#F8FAFC`):** Global canvas background providing subtle contrast behind card containers.
- **Borders / Outlines (`#E2E8F0`):** Hairline demarcations separating cards, form fields, and toolbar dividers.

## Typography

Typography uses `Roboto Flex` across all Android layout scopes, balancing native feel with structural legibility:

- **Hierarchy:** Document titles and tool groupings employ `headline-sm` or `headline-md` for quick scanning on dense screens.
- **Data & Attributes:** Document metadata (timestamp, file dimensions, pagination) utilizes `body-sm` rendered in secondary neutral (`#64748B`).
- **Interactive Labels:** Buttons, chip options, and bottom navigation destinations use `label-lg` and `label-md` with strict medium weights (`500`) for visual balance against outlined icons.

## Layout & Spacing

The layout is built for compact Android viewports using a 4-column mobile grid:

- **Gutters & Margins:** Default screen outer margin is `1rem` (16dp). Internal grids for tool tile pickers (e.g., 2-column or 3-column PDF tools) use `0.75rem` (12dp) gutters to conserve vertical space.
- **Top App Bar:** Pinned standard height of 56dp (or 64dp for large title transitions). Accommodates clean outlined trailing utility icons (Search, Batch Selection, Overflow Menu).
- **Bottom Navigation Bar:** Fixed 80dp Material 3 navigation bar anchored to the bottom safe area with pill-shaped selection indicators (`#EFF6FF`).
- **Scaffold Padding:** Content containers maintain `1rem` horizontal safe bounds with `0.5rem` to `1rem` vertical item gap rhythm.

## Elevation & Depth

Visual depth combines structural hairline outlines with low-opacity ambient shadows:

- **Surface Level 0 (Canvas):** Background color `#F8FAFC`, flat.
- **Surface Level 1 (Cards & File Items):** `#FFFFFF` fill bounded by a continuous 1px outline in `#E2E8F0` coupled with an ambient shadow: `box-shadow: 0 1px 3px 0 rgba(15, 23, 42, 0.05), 0 1px 2px -1px rgba(15, 23, 42, 0.03)`.
- **Surface Level 2 (Bottom Sheets & Dialogs):** `#FFFFFF` with outline `#E2E8F0` and `box-shadow: 0 10px 15px -3px rgba(15, 23, 42, 0.08), 0 4px 6px -4px rgba(15, 23, 42, 0.04)`.
- **Surface Level 3 (Floating Action Button & Overlays):** `#2563EB` fill with `box-shadow: 0 4px 12px 0 rgba(37, 99, 235, 0.28)`.
- **Pressed & Focused States:** Rather than heavy drop shadows, interactive cards depress slightly or gain an outer focus ring (`2px solid rgba(37, 99, 235, 0.3)`).

## Shapes

The design uses rounded corners (Level 2: base radius `0.5rem` / 8dp):

- **Small Controls (Buttons, Inputs, Chips):** `0.5rem` (8dp) to `0.75rem` (12dp) for crisp, compact touch targets.
- **Cards & Document Thumbnails:** `0.75rem` (12dp) corner radii to present friendly, modern card contours without wasting corner space.
- **Modals & Bottom Sheets:** `1.5rem` (24dp) on top-left and top-right corners with centered `0.25rem` (4dp) grab handles.
- **Selection Badges & Icons:** Fully circular (`rounded-full` / 9999px) for checkmarks, status rings, and icon container backings.

## Components

- **Buttons:**
  - *Primary Button:* Solid `#2563EB`, text `#FFFFFF`, height 44dp, padding `0 1.25rem`, border-radius 12dp, medium typography weight.
  - *Tonal / Secondary Button:* Background `#EFF6FF`, text `#2563EB`, border 1px solid transparent.
  - *Outlined Button:* Transparent fill, 1px border `#E2E8F0`, text `#111827`.
  - *Floating Action Button (Extended FAB):* Background `#2563EB`, foreground `#FFFFFF`, height 56dp, border-radius 16dp, containing an outlined addition/scan icon and label.

- **Cards & Document List Tiles:**
  - *Document Card:* Surface `#FFFFFF`, border 1px solid `#E2E8F0`, corner radius 12dp, padding 12dp. Includes a 48x64dp page thumbnail placeholder with a light outline, file title (`headline-sm` / 14dp semi-bold), and secondary metadata row.
  - *Tool Grid Tile:* Square card housing a 24dp outlined tool icon within a 44dp `#EFF6FF` rounded square, followed by concise tool label (`Merge`, `Split`, `Compress`, `Sign`).

- **Input Fields & Search Bars:**
  - Top search bar rendered in `#FFFFFF`, border 1px solid `#E2E8F0`, height 48dp, corner radius 12dp. Outlined search icon left, clear/mic right.
  - Text inputs use floating or stacked label patterns, 1px active focus border `#2563EB` with an ambient blue focus ring.

- **Chips:**
  - *Filter & Action Chips:* Height 32dp, border-radius 8dp, border 1px solid `#E2E8F0`, background `#FFFFFF`. Selected state transitions to `#EFF6FF` background, `#2563EB` border, and `#2563EB` text/icon.

- **Selection Controls (Checkboxes, Radios, Toggles):**
  - Outlined border `#64748B` in resting state; filled `#2563EB` with `#FFFFFF` checkmark when selected. Target bounds conform to Android 48dp touch targets via invisible padding.

- **Top App Bar & Bottom Navigation:**
  - *Top App Bar:* Single-line 56dp surface `#FFFFFF` or `#F8FAFC` (scrolling content elevates with 1px border `#E2E8F0`). Back button: 24dp clean outlined back arrow.
  - *Bottom Navigation Bar:* 3-4 destinations (`Recent`, `Tools`, `Files`, `Settings`). Selected item highlights with an elliptical `#EFF6FF` pill around the active 24dp outlined icon and `#2563EB` label.

- **Status & Feedback Indicators:**
  - Conversion/upload progress uses a slim 4dp continuous track `#E2E8F0` with progress fill `#2563EB`.
  - Success notifications present a compact snackbar featuring `#16A34A` iconography and `#111827` high-contrast background.