---
name: create-assessment
description: Create or revise written tests and oral examinations with synchronized solutions and verified point totals. Use for assessment material in Teaching-Private; use create-teaching-material for ordinary instructional worksheets.
---

# Create Assessment

Read `Teaching-Private/AGENTS.md`, the matching canonical `Teaching-SRC/<course>/COURSE.md`, and `ASSESSMENT.md` when one exists. Assessment confidentiality, level, permitted tools, and the user's stated intent take priority over general workflow choices.

Use `mtest` for written assessments and `mexam` for oral examinations. Create one best version and its solution unless the user explicitly requests otherwise. Name the solution `lsg_<name>` after the assessment source, in the same assessment folder; never `l-...`. Do not add teacher commentary, grading notes, hints, alternate versions, or rubrics unless requested, apart from the Anforderungsbereiche described below.

For a written Klassenarbeit, inspect a few of Marc's earlier exams for the same subject and level before choosing the page structure. TG mathematics exams use the `mtest` title block followed directly by `Teil 1 --- Ohne Hilfsmittel`, then `Teil 2 --- Mit Hilfsmittel`; use `\msectionr[]` for tasks, `\mscore` at the relevant task or subtask, and the existing total-score and closing commands. Do not invent a separate header for time, total points, aids, name, paper use, or hand-in procedure unless the user asks for it. Preserve a different established structure when the matching earlier exams show one.
Put the specified exam date in the `mtest` title block below `Klassenarbeit <number>`; if no date is supplied, use the current date. Put the intended class and subject in the page header, and visually align its bottom with the bottom of the school logo above the title table.

## Anforderungsbereiche

For a written mathematics Klassenarbeit, classify every subtask by Anforderungsbereich (AFB I to III) and record the result in two places: tags in the solution and a separate `afb_<exam-name>.md` next to the exam. Follow the rule in `Teaching-Private/AGENTS.md`; this is standard output, not an extra commentary file.

- Take the levels from the Bildungsplan, not from the Ich-kann-Liste. Where the plan has no level marks per competence (the 1BKFH plan has none), use the Anforderungsbereiche of the Bildungsstandards it names (K1 to K6). Check the plan before assuming; do not invent a level scheme.
- Assign by the demanded activity: AFB I applies a known procedure, formula, or definition directly; AFB II links concepts, chooses an approach, or interprets or switches representations; AFB III treats general or parametric cases, evaluates models or procedures, or argues beyond routine. Split a subtask's BE when it spans two levels, and say that the split is a convention.
- In the solution use `\mtag` pills after `\mscore` and a final line of per-level sums that counts only visible blocks. Generate tags and the markdown file from one data set; the file holds the rule, the sums, a row per block including hidden alternatives, a table per task with BE, level, and reason, the borderline cases, and the sources.

## Validate conservatively

- Verify task wording, givens, notation, and solution correspondence.
- Independently recompute results where practical; for physics also check units, dimensions, significant figures, magnitude, and plausibility.
- Verify every item value, section subtotal, overall total, and the solution's point allocation, including that the per-level BE sums add up to the total for the visible version and with every alternative switched on.
- Preserve existing point allocations. Correct them only when the inconsistency and intended fix are both unambiguous; otherwise report the issue and ask when it materially blocks the task.

Apply `$create-graphics` for nontrivial assessment visuals and `$latex-document` for house style, compilation of source and solution, tracked PDFs, warnings, and visual verification.
