---
name: create-assessment
description: Create or revise written tests and oral examinations with synchronized solutions and verified point totals. Use for assessment material in Teaching-Private; use create-teaching-material for ordinary instructional worksheets.
---

# Create Assessment

Read `Teaching-Private/AGENTS.md`, the matching canonical `Teaching-SRC/<course>/COURSE.md`, and `ASSESSMENT.md` when one exists. Assessment confidentiality, level, permitted tools, and the user's stated intent take priority over general workflow choices.

Use `mtest` for written assessments and `mexam` for oral examinations. Create one best version and its solution unless the user explicitly requests otherwise. Do not add teacher commentary, grading notes, hints, alternate versions, or rubrics unless requested.

For a written Klassenarbeit, inspect a few of Marc's earlier exams for the same subject and level before choosing the page structure. TG mathematics exams use the `mtest` title block followed directly by `Teil 1 --- Ohne Hilfsmittel`, then `Teil 2 --- Mit Hilfsmittel`; use `\msectionr[]` for tasks, `\mscore` at the relevant task or subtask, and the existing total-score and closing commands. Do not invent a separate header for time, total points, aids, name, paper use, or hand-in procedure unless the user asks for it. Preserve a different established structure when the matching earlier exams show one.
Put the specified exam date in the `mtest` title block below `Klassenarbeit <number>`; if no date is supplied, use the current date. Put the intended class and subject in the page header, and visually align its bottom with the bottom of the school logo above the title table.

## Validate conservatively

- Verify task wording, givens, notation, and solution correspondence.
- Independently recompute results where practical; for physics also check units, dimensions, significant figures, magnitude, and plausibility.
- Verify every item value, section subtotal, overall total, and the solution's point allocation.
- Preserve existing point allocations. Correct them only when the inconsistency and intended fix are both unambiguous; otherwise report the issue and ask when it materially blocks the task.

Apply `$create-graphics` for nontrivial assessment visuals and `$latex-document` for house style, compilation of source and solution, tracked PDFs, warnings, and visual verification.
