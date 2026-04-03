# figma-to-design

Claude Code commands that turn Figma designs into production-ready Next.js/React code. Scans your codebase for design tokens, pulls designs from Figma, generates code matching your project's conventions, and visually verifies output via Playwright screenshot comparison — iterating until the result matches the design.

---

## How It Works

```
/figma-to-design-init (once per project)
  └─ Claude Code scans codebase → generates design-tokens.json
  └─ Discovers existing components, hooks, styling approach
  └─ Checks for global Playwright installation

/figma-to-design-build (per task)
  └─ User provides Figma URL + prompt
  └─ Asks about multiple viewports (desktop/tablet/mobile)
  └─ Pulls design context + screenshots from Figma MCP
  └─ Generates code using project tokens, styling conventions, existing components
  └─ Screenshots result via Playwright CLI
  └─ Compares Figma screenshot vs Playwright screenshot
  └─ Iterates (up to 4 rounds)
       ├─ Below 90% → auto-fixes and re-runs
       ├─ 90%+ → pauses, asks if you want to push to 95%
       └─ 95%+ or cap hit → stops
```

---

## Prerequisites

1. **Claude Code** installed and working
2. **A Next.js + React project** (v1 scope)
3. **Figma account** with Dev Mode access
4. **Figma MCP** configured in Claude Code
5. **Playwright** installed globally (`npm install -g playwright && npx playwright install chromium`)

---

## Installation

### Option A: Claude Code plugin (recommended)

```
/plugin marketplace add codestate-cs/figma-to-design
/plugin install figma-to-design
```

### Option B: npx skills add

```bash
npx skills add codestate-cs/figma-to-design
```

Works across Claude Code, Cursor, Codex, and other agents that support the [Agent Skills](https://agentskills.io) standard.

### Option C: Manual install

```bash
git clone https://github.com/codestate-cs/figma-to-design.git
cd figma-to-design
./install.sh
```

Restart Claude Code after installing. The commands `/figma-to-design-init` and `/figma-to-design-build` will be available in any project.

### Uninstall

```bash
# If installed via Option C
./uninstall.sh
```

---

## MCP Setup

You need Figma MCP configured. Add this to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/figma-mcp-server@latest"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "your-figma-personal-access-token"
      }
    }
  }
}
```

**Figma access token:** Figma → Settings → Account → Personal access tokens → Generate.

---

## Usage

### Step 1: Initialize (once per project)

```
/figma-to-design-init
```

This scans your codebase and generates `design-tokens.json` at the project root containing your styling approach, colors, spacing, typography, breakpoints, existing components, and hooks.

Re-running init when `design-tokens.json` already exists performs an incremental update — only scanning for changes rather than re-reading everything.

### Step 2: Build from Figma

Make sure your dev server is running (`npm run dev`), then:

```
/figma-to-design-build
```

Claude Code will ask for:
1. The Figma Dev Mode URL
2. Whether there are multiple viewport designs
3. A description of what you're building and where it goes

Then it generates code and runs the visual verification loop.

**Dry run:** Add "dry run" to your prompt to preview the plan without writing files.

---

## Example Prompts

### Good Prompts

```
Build the dashboard overview page from this Figma.
It should be the default page at /dashboard.
The data cards at the top should accept props for title, value, and trend.
Reuse the existing Card and Badge components.
```

```
Implement the user settings page.
It goes in app/settings/page.tsx.
The form sections should be separate components under components/settings/.
Use our existing Input and Select components for form fields.
The save button should be disabled until a field changes.
```

```
Build the pricing section from the landing page Figma.
This is a section component, not a full page — it'll be imported into app/page.tsx.
The pricing cards should be a reusable PricingCard component.
The toggle between monthly/annual should update all cards.
```

### Bad Prompts

```
Build this page.
```
*No context about where it lives, what's interactive, or what to reuse.*

```
Make it look exactly like the Figma.
```
*No information about behavior, state, routing, or data flow.*

---

## What It Enforces

### Reusability First
- Check existing components before creating new ones
- Extract repeated patterns into components
- Props-driven, composable components

### SOLID for Frontend
- **S** — Single Responsibility: one component, one job
- **O** — Open/Closed: extendable via props, not source modification
- **I** — Interface Segregation: don't bloat component props
- **D** — Dependency Inversion: depend on props and hooks, not concrete implementations

### DRY for Frontend
- Design tokens for all values — no magic numbers
- Shared logic in custom hooks
- Shared layout in layout components

---

## Troubleshooting

**"Figma MCP not responding"**
- Check your `FIGMA_ACCESS_TOKEN` is valid
- Make sure the Figma file is accessible to your account
- Restart Claude Code after changing `.mcp.json`

**"Playwright screenshot is blank"**
- Is your dev server running?
- Check Playwright is installed globally: `npx playwright --version`

**"design-tokens.json looks wrong"**
- Re-run `/figma-to-design-init` and point out what's missing
- You can manually edit it — it's just JSON

**"Generated code doesn't use my existing components"**
- Check the `components` section in `design-tokens.json` is complete
- Explicitly name the components you want reused in your prompt

**"Iteration loop isn't converging"**
- Break the page into smaller sections and run `/figma-to-design-build` per section
- Add more context about what matters most in the design

---

## Project Structure

```
figma-to-design/
├── .claude-plugin/
│   └── plugin.json                    # Plugin manifest
├── skills/
│   ├── init/SKILL.md                  # /figma-to-design-init
│   ├── build/SKILL.md                 # /figma-to-design-build
│   └── design-system-aware/SKILL.md   # Auto-invoked skill
├── install.sh                         # Install commands globally
├── uninstall.sh                       # Remove commands
└── README.md
```

---

## Limitations

- **Next.js + React only** for v1. Vue, Svelte, Angular not supported yet.
- **Does not handle backend logic.** API calls, data fetching, server actions are out of scope unless specified.
- **Does not guarantee pixel-perfection.** 90-95% is the practical target.
- **Does not create designs.** It implements them.

---

## License

MIT