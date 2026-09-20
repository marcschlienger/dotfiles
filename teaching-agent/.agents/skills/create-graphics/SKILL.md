---
name: create-graphics
description: Create or revise reproducible teaching graphics such as TikZ diagrams, plots, SVG assets, and small supporting data files for LaTeX material. Use when a teaching task needs a new or materially changed visual; do not activate for purely textual edits.
---

# Create Teaching Graphics

Read the applicable repository policy, course context, and nearby visual conventions. Choose the simplest maintainable representation that supports the pedagogical purpose:

- Prefer TikZ or pgfplots when the visual is naturally generated with LaTeX and benefits from matching document typography.
- Use SVG for reusable vector artwork that is clearer to author externally.
- Use a small data file or helper script when deterministic regeneration materially improves correctness.

Keep source assets local to the relevant material and follow the established directory and naming pattern. Reuse existing packages and macros where practical; do not alter shared class/style infrastructure to accommodate one graphic.

## Handwritten answer areas

Use TikZ grids with 5 mm squares for responses on Marc's worksheets instead of blank vertical space or dotted lines. Inspect a nearby worksheet for the established line color and weight. If the loaded class/package already provides an appropriate grid command, prefer it; otherwise keep a small local helper or direct TikZ drawing.

Place each grid directly with its task, without floating it elsewhere. Keep answer grids visibly narrower than the text block (typically at most 14 cm on A4). Capture the available line width before entering TikZ, especially inside lists, and account for the stroke width so the drawing stays within that width. Choose the height from the expected handwritten calculation, drawing, or explanation: count handwriting lines, not printed solution lines. Allow at least 3 cm for a written conjecture and more for multi-part explanations. Use larger areas for multi-part justifications and diagrams; compact horizontal spacing must not remove needed writing room. In the rendered PDF, check that the grid is print-legible, stays inside the margins, and is not separated from the task by a page break.

## Validation

Check labels, units, scales, mathematical accuracy, legibility, contrast, and consistency with the task and solution. Build the containing documents and visually inspect every affected page at a readable resolution. Fix clipping, overlap, unreadable labels, misleading geometry or scales, and poor placement. Mention notable new assets, packages, or helper scripts in the completion summary.
