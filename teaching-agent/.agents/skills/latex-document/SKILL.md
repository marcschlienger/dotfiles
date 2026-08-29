---
name: latex-document
description: Create, revise, build, and visually verify LaTeX teaching documents that use Marc's mtex classes and mstuff package. Use for work on teaching .tex sources or their tracked PDFs; use generic document skills for non-LaTeX artifacts.
---

# LaTeX Teaching Document

Read the applicable `AGENTS.md` and the matching canonical `COURSE.md` before editing. Treat repository policy and the current task as authoritative; this skill supplies the reusable build workflow.

## Choose the existing house style

- Use `msheet` for worksheets, fact sheets, group work, schedules, and experiment sheets.
- Use `mtest` for written assessments.
- Use `mexam` for oral examinations.
- Use `mtalk` for slide presentations.
- Use `mstuff` and `msheet.sty` where the document convention calls for them.

Inspect nearby material for the exact preamble, macros, filenames, and layout conventions. Confirm uncertain class or package resolution with `kpsewhich`. Do not edit shared classes, styles, common macros, templates, or build infrastructure unless the user explicitly requests that work.

## Build and check

1. Build every affected source with `latexmk -pdf <file.tex>` from its document directory. Build the corresponding solution too.
2. Preserve the established output filename and update a tracked PDF in place.
3. Fix compilation errors and undefined references or citations. Inspect meaningful overfull boxes and obvious layout warnings; harmless known warnings may remain.
4. For a new document, substantial revision, graphic change, or layout-affecting edit, render the PDF to images and inspect every page. Fix clipping, overlap, unintended blank pages, illegible graphics, poor page breaks, and inconsistent spacing. Compilation alone is sufficient for a trivial text-only correction.
5. Briefly report successful builds, visual inspection when performed, and any meaningful warning that remains.

Keep auxiliary files when the repository ignores them; routine cleanup is not required.
