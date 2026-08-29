---
name: create-teaching-material
description: Create new course-appropriate worksheets, fact sheets, activities, experiments, and their solutions in the teaching repositories. Use for new instructional material; use an adaptation workflow only when the user explicitly asks to revise or reuse existing content.
---

# Create Teaching Material

Read the repository `AGENTS.md` and the matching `Teaching-SRC/<course>/COURSE.md`. Use the prompt for current syllabus progress and the course file only for stable context. Inspect a small number of nearby documents to learn notation, level, structure, and visual conventions without reusing substantive content.

Create one best version at the requested level. Unless the user says otherwise, create the corresponding solution at the same time and keep both files structurally synchronized. Do not add teacher-only notes, variants, or commentary files that were not requested.

## Validate the content

- Check that every task has exactly the intended solution coverage and that no solution item lacks a task.
- Independently recompute nontrivial mathematical and numerical results where practical.
- Keep terminology and notation consistent between task and solution.
- For physics, check units, dimensions, plausible significant figures, order of magnitude, and physical plausibility.
- Create local supporting graphics or data only when useful and place them according to the nearby repository structure.

Apply `$create-graphics` when a nontrivial visual is needed. Apply `$latex-document` to select the house class, build every affected source, update tracked PDFs, and perform the required visual inspection.
