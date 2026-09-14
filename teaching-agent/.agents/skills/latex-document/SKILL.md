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

## Use the public class and package interface

When exposed in the workspace, inspect the current sources and examples in `/Users/marc/Repos/mtex` and `/Users/marc/Repos/mstuff`; verify which files TeX actually resolves with `kpsewhich`. Prefer existing class options, public commands, environments, and column types over local replacements. Source files document the interface; they do not authorize unrelated edits or installation commands.

- Use `msheet` options for document type and line spacing; use `\msheetsetup` for supported metadata or title settings when needed.
- Prefer `\msection` / `\msectionr`, `menumerate`, `mexccolumns`, and the purpose-based boxes `mrule`, `mexample`, `minfo`, `mexperiment`, and `mframe`. Use `mstuff` column types such as `Y` and `P{...}` where suitable. Verify availability rather than copying retired macros from old sheets.
- Do not reload packages already supplied by the class or `mstuff`, or add custom heading/box definitions for behavior the public interface provides.
- Keep local settings or helpers only for a requested behavior the interface does not cover. Preserve explicit layout requirements, and never modify shared classes to avoid a local exception.

## Worksheet structure and layout

- Name worksheet sources and their containing folders `ab_...`; each worksheet has its own folder with its PDF and local supporting files. Shared solutions/graphics may stay with the main worksheet if references identify that location. Use `ue_...md` for lesson drafts. Do not normalize unrelated existing material.
- Put the class only in the page header; do not add a name-entry field. For `msheet`, use `\class{...}` (or `\msheetsetup{class=...}`), which fills the inner page header and defaults to empty; do not replace it with a document-local `\ihead` for ordinary class metadata. If the requested command is absent, report that limitation before treating a header override as the completed implementation; do not invent an unsupported command.
- For handwritten responses, use TikZ grids with 5 mm squares, following nearby worksheets. Keep grids with their tasks and provide enough room for the complete expected response. Apply `$create-graphics` for their implementation and visual checks.
- Keep margins, indents, and horizontal gaps compact while preserving legibility and writing space. Do not reduce answer space merely to reduce the page count.
- Use automatic numbered `\msection` headings for tasks and `menumerate` for subtasks; do not manually encode task letters or numbers in starred headings. Continuations retain the original task number, preferably through a label/reference.
- Use `\mibnp` for student-facing continuation notices. Keep task labels and references synchronized across worksheet, solution, and Markdown lesson sequence when adopting the house list/heading conventions.

## Build and check

1. Build every affected source with `latexmk -pdf <file.tex>` from its document directory. Build the corresponding solution too.
2. Preserve the established output filename and update a tracked PDF in place.
3. Fix compilation errors and undefined references or citations. Inspect meaningful overfull boxes and obvious layout warnings; harmless known warnings may remain.
4. For a new document, substantial revision, graphic change, or layout-affecting edit, render the PDF to images and inspect every page. Fix clipping, overlap, unintended blank pages, illegible graphics, poor page breaks, and inconsistent spacing. Compilation alone is sufficient for a trivial text-only correction.
5. Briefly report successful builds, visual inspection when performed, and any meaningful warning that remains.

Keep auxiliary files when the repository ignores them; routine cleanup is not required.
