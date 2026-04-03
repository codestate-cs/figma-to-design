---
name: figma-to-design-init
description: Initialize the design-to-code workflow. Scans your codebase for styling patterns, extracts design tokens, discovers reusable components, and generates a design-tokens.json file. Run this once per project before using /figma-to-design-build.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Initialize Design System

You are initializing the design-to-code workflow for this project. Your job is to deeply understand the existing codebase's design patterns and produce a `design-tokens.json` file at the project root.

## Pre-check: Incremental Update

Before scanning, check if `design-tokens.json` already exists at the project root.

- If it **does not exist**: proceed with a full scan (Steps 1-7).
- If it **does exist**: read it into context. Then run a targeted scan:
  1. Check if the styling approach or config file has changed. If yes, re-extract tokens (Step 2).
  2. Scan only for new, modified, or deleted components and hooks since the file was last generated (compare file paths in the existing JSON against what's on disk).
  3. Merge changes into the existing `design-tokens.json` — add new entries, update changed entries, remove entries for deleted files.
  4. Skip Steps 6-7's Playwright install if already installed.

This avoids re-reading the entire codebase when only a few components have changed.

## Step 1: Identify the Styling Approach

Scan the project for how styles are written. Look for:

- `tailwind.config.ts` or `tailwind.config.js` → Tailwind CSS
- `*.module.css` or `*.module.scss` files → CSS/SCSS Modules
- `styled-components`, `@emotion/styled`, or `@emotion/css` in `package.json` → CSS-in-JS
- `.css` files imported directly into components → Vanilla CSS
- A combination of the above

Record the primary styling approach. If mixed, note the dominant one and secondary ones.

## Step 2: Extract Design Tokens

Based on the styling approach, extract tokens from the appropriate source:

**If Tailwind:** Read `tailwind.config.ts/js` and extract the `theme` / `extend` values — colors, spacing, fontFamily, fontSize, borderRadius, boxShadow, screens (breakpoints).

**If CSS Variables:** Search for `:root` or `[data-theme]` blocks in CSS files. Extract all custom properties.

**If CSS-in-JS / Theme file:** Look for theme objects (commonly in `theme.ts`, `styles/theme.ts`, `lib/theme.ts`, or similar). Extract the token values.

**If Vanilla CSS:** Scan the most-used CSS files for recurring values. Group them as tokens even if they aren't formally defined as such.

For all approaches, extract:
- **Colors**: primary, secondary, background, surface, text, border, error, success, warning, info — and any other semantic color names used
- **Spacing**: the scale or common spacing values used
- **Typography**: font families, size scale, weight scale, line heights
- **Breakpoints**: responsive breakpoints
- **Shadows**: box-shadow values
- **Borders**: border-radius values, border widths

## Step 3: Discover Reusable Components

Scan the project for existing UI components. Common locations:
- `src/components/`, `src/components/ui/`, `components/`, `app/components/`
- Any barrel export files (`index.ts`) that re-export components

For each component found, record:
- **name**: The component name
- **path**: File path relative to project root
- **description**: What it does, written in plain English. Read the component code to understand it — don't just guess from the name.
- **props**: The props it accepts (read from TypeScript types, PropTypes, or the JSX usage)

Prioritize components that are clearly meant for reuse:
- UI primitives (Button, Input, Select, Checkbox, Radio, Toggle, Textarea)
- Layout components (Container, Grid, Stack, Sidebar, PageLayout)
- Feedback components (Alert, Toast, Modal, Dialog, Tooltip, Popover)
- Data display (Card, Table, Badge, Avatar, Tag, List)
- Navigation (Navbar, Tabs, Breadcrumbs, Pagination, MobileNav)

Skip page-specific components that are not reusable.

## Step 4: Discover Shared Hooks and Utilities

Look for custom hooks relevant to UI development:
- `useMediaQuery`, `useBreakpoint` → responsive behavior
- `useDebounce`, `useThrottle` → input handling
- `useClickOutside` → dropdowns, modals
- `useForm`, `useFormField` → form state
- Any data fetching hooks

Record these in a `hooks` section with name, path, and description.

## Step 5: Generate design-tokens.json

Write the file to the project root as `design-tokens.json`. Structure:

```json
{
  "styling_approach": "<tailwind | css-modules | css-in-js | vanilla-css | mixed>",
  "styling_config_path": "<path to tailwind config, theme file, or primary CSS file>",
  "colors": { },
  "spacing": { },
  "typography": { },
  "breakpoints": { },
  "shadows": { },
  "borders": { },
  "components": [
    {
      "name": "ComponentName",
      "path": "src/components/ui/ComponentName.tsx",
      "description": "What it does in plain English",
      "props": ["variant", "size", "children"]
    }
  ],
  "hooks": [
    {
      "name": "useHookName",
      "path": "src/hooks/useHookName.ts",
      "description": "What it does"
    }
  ]
}
```

## Step 6: Check Playwright

Ensure Playwright is installed globally and ready for the visual verification workflow:

1. Run `npx playwright --version` to check if Playwright is available.
2. If not installed, run `npm install -g playwright` and then `npx playwright install chromium`.
3. If already installed, skip this step.

## Step 7: Verify and Confirm

After generating the file:
1. Show the user a summary: styling approach detected, number of colors/tokens, components discovered, hooks found
2. Ask if anything looks wrong or missing
3. If they correct something, update the file
4. Confirm initialization is complete and they can now use `/figma-to-design-build`

## Important Rules

- Do NOT invent tokens that don't exist in the codebase. Only record what's actually there.
- If the project is new with almost no tokens or components, say so. A sparse file is fine.
- If you find inconsistencies (e.g., 5 different grays with no naming convention), note them but record as-is. Don't "clean up" the design system — that's the user's job.