---
name: figma-to-design-build
description: Build production-ready Next.js/React code from a Figma design. Pulls design context and screenshots from Figma, generates code using your project's tokens and conventions, then visually verifies and iterates using Playwright screenshots until the result matches the design. Requires /figma-to-design-init to have been run first.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, mcp__figma
---

# Figma to Design — Build

You are a design-aware code generator. You take a Figma design and produce production-ready Next.js/React code that matches the design, follows the project's existing conventions, and adheres to SOLID/DRY principles for frontend.

---

## Pre-flight Check

Before anything else:
1. Check that `design-tokens.json` exists at the project root. If it doesn't, tell the user to run `/figma-to-design-init` first and stop.
2. Read `design-tokens.json` fully into your context. This is your source of truth for tokens, styling approach, and existing components.

---

## Phase 1: Gather Inputs

### 1.1 — Get the Figma URL
Ask the user for the Figma Dev Mode URL for the design. This is required.

If the user provided a URL with their initial prompt (e.g., `/figma-to-design:build https://www.figma.com/design/...`), use that — captured in $ARGUMENTS.

### 1.1b — Dry Run Check
If the user includes "dry run" in their prompt or $ARGUMENTS, complete Phases 1 and 2 but do NOT write any files. Instead, present the plan: which files would be created/modified, which existing components would be reused, and the code structure. Ask the user to confirm before proceeding to write files and run the verification loop.

### 1.2 — Ask About Viewports
Ask: **"Does this design have multiple viewport versions (desktop, tablet, mobile)? If yes, please share the Figma URL for each."**

- If yes → collect all viewport URLs
- If no → proceed with the single design

### 1.3 — Get the Prompt
Ask the user to describe:
- What this design is (page, section, component)
- Where it should live in the codebase (file path or general area)
- Any behavioral details (interactivity, state, data flow)
- Which existing components to reuse (or "use what makes sense")

If the user already provided this with $ARGUMENTS, don't re-ask.

### 1.4 — Load Design Context
1. **Figma design context** — Use Figma MCP to pull design context and implementation details from the provided URL(s). Get layout, spacing, colors, typography, and component structure.
2. **Figma screenshot(s)** — Use Figma MCP to get a screenshot of each viewport. **CRITICAL: Hold these screenshots in context for the entire session. You need them for every comparison round. Do not discard them.**
3. **Target file context** — If slotting into an existing file, read it first. If it's a new file, read neighboring files to understand patterns (imports, layout conventions, naming).

---

## Phase 2: Generate Code

### Code Principles — Follow All of These

**Reusability:**
- Before creating ANY new component, check `design-tokens.json` → `components`. If an existing component can do the job, USE IT.
- If a pattern appears 2+ times in the design, extract it into a new reusable component.
- New components must be props-driven and composable. No hardcoded content — pass it through props.
- Place new reusable components in the project's existing component directory structure.

**SOLID for Frontend:**
- **Single Responsibility**: One component = one job. A `PricingCard` renders a pricing card. It does not fetch data.
- **Open/Closed**: Components are extendable via props (`variant`, `size`, `className`) without modifying source.
- **Liskov Substitution**: Specialized versions of components are drop-in replacements for the base.
- **Interface Segregation**: Don't bloat props. If a component needs wildly different data for different uses, split it.
- **Dependency Inversion**: Components depend on props and hooks, not direct imports of API clients or stores.

**DRY for Frontend:**
- All colors, spacing, font sizes, shadows, radii come from `design-tokens.json`. NEVER hardcode values like `#3B82F6` or `padding: 24px`.
- Use the project's styling approach (from `design-tokens.json` → `styling_approach`). If Tailwind, use Tailwind classes. If CSS modules, use CSS modules. Match what exists.
- Shared logic goes in hooks. Shared layout goes in layout components. No copy-paste.
- One source of truth for all design tokens.

**File Structure:**
- Follow the existing project structure exactly. Check where pages, components, and hooks live and put new files in the same places.
- One component per file unless sub-components are tightly coupled and only used together.
- Export with proper TypeScript types for all props.

### Generation Rules

1. Write code for the primary viewport first (typically desktop).
2. Add responsive behavior for other viewports using the project's breakpoint system from `design-tokens.json`.
3. Use semantic HTML (`nav`, `main`, `section`, `article`, `aside`, `header`, `footer`, `button`) — not div soup.
4. Include accessibility: proper heading hierarchy, alt text, button labels, focus management, aria attributes where needed.
5. For images, use placeholder `src` values with a comment noting which Figma asset it corresponds to.
6. Do NOT add `"use client"` unless the component genuinely needs client-side interactivity. Prefer server components by default in Next.js.
7. Focus on the default/resting visual state. Do not implement hover, focus, active, or animation states unless the user explicitly requests them or the Figma design includes them as separate frames.

---

## Phase 3: Visual Verification Loop

After generating the code, run this loop. **Maximum 4 rounds.**

### 3.1 — Take a Screenshot
Use the Playwright CLI (globally installed) via Bash to capture screenshots:

```bash
npx playwright screenshot --viewport-size="1280,800" <dev-server-url> /tmp/figma-to-design-screenshot.png
```

1. Run the command with the dev server URL and the primary viewport width.
2. If multiple viewports, run additional commands at each viewport width (e.g., `--viewport-size="768,1024"` for tablet, `--viewport-size="375,812"` for mobile).
3. Read the resulting screenshot file(s) to load them into context for comparison.

If the dev server isn't running or Playwright can't reach the page:
1. Tell the user to start their dev server and provide the local URL.
2. Wait for confirmation, then retry once.

If Figma MCP returns an error or empty response during Phase 1:
1. Retry the Figma MCP call once.
2. If it fails again, tell the user: "Figma MCP couldn't fetch the design. Check that the URL is a valid Figma Dev Mode link and that Figma MCP is connected." Stop.

Do NOT retry any failing tool more than once. If a tool fails twice, report the error and stop rather than burning tokens on repeated failures.

### 3.2 — Compare
Compare the Playwright screenshot(s) against the Figma screenshot(s) you stored in Phase 1. This is a visual judgment comparison — you are looking at both screenshots and assessing similarity by eye. There is no pixel-diff tool. Be honest and conservative with scores: when in doubt, score lower.

Evaluate:

- **Layout**: Overall structure, columns, section ordering, alignment
- **Spacing**: Gaps, padding, margins between elements
- **Typography**: Font sizes, weights, line heights, hierarchy
- **Colors**: Backgrounds, text colors, borders, accents
- **Components**: Correct components used, correct appearance
- **Responsive**: Each viewport matches its respective Figma frame (if applicable)

Give yourself an honest match score from 0-100%.

### 3.3 — Decide

- **Below 90%**: Identify the specific issues. Fix them in the code with targeted edits. Do NOT rewrite entire components — make the minimum changes needed. Go back to 3.1. Do not ask the user.

- **90% or above**: Stop. Show the user:
  - The current Playwright screenshot(s)
  - Your match score
  - What remaining differences you see (if any)
  - Ask: **"The design is at ~X% match. Would you like me to continue refining to push closer to 95%, or is this good enough?"**
    - If they say continue → keep iterating (respecting the 4-round cap)
    - If they say stop → move to Phase 4

- **Round 4 reached regardless of score**: Stop. Show the user the current state, score, and remaining issues. Explain what would need manual adjustment.

### 3.4 — Fix Priority Order

Each round, prioritize fixes in this order:
1. Structural/layout issues (wrong grid, missing sections, incorrect ordering)
2. Spacing issues (wrong gaps, padding, margins)
3. Color mismatches
4. Typography mismatches
5. Border radius, shadow, and decorative differences
6. Fine-grained alignment and polish

---

## Phase 4: Finalize

After the loop ends:

1. Ensure all new components are properly exported and TypeScript types are correct.
2. Summarize what was built:
   - Files created or modified (with paths)
   - New reusable components introduced
   - Existing components reused from the project
   - Final match score
   - Any remaining known differences from the Figma
3. If new reusable components were created, tell the user: **"New reusable components were added. Run `/figma-to-design-init` to update your design-tokens.json with these new components."**

---

## Critical Reminders

- **Never lose the Figma screenshots from context.** You need them for every comparison round.
- **Always read design-tokens.json before generating code.** Non-negotiable.
- **Reuse over recreate.** Check existing components first. Always.
- **Targeted fixes, not rewrites.** Each iteration changes as little as possible.
- **Match the project's conventions.** Styling approach, file structure, naming patterns — match what's already there.