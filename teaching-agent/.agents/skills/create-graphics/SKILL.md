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

Check labels, units, scales, mathematical accuracy, legibility, contrast, and consistency with the task and solution. Build the containing documents and visually inspect every affected page at a readable resolution. Fix clipping, overlap, unreadable labels, misleading geometry or scales, and poor placement. Mention notable new assets, packages, or helper scripts in the completion summary.
