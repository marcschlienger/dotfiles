---
name: create-teaching-material
description: Create course-appropriate lesson drafts, new worksheets, fact sheets, activities, experiments, and their solutions in the teaching repositories. Use for new instructional material; use an adaptation workflow only when the user explicitly asks to revise or reuse existing content.
---

# Create Teaching Material

Read the repository `AGENTS.md` and the matching `<course>/COURSE.md`. Use the prompt for current syllabus progress and the course file only for stable context. Inspect a small number of nearby documents to learn notation, level, structure, and visual conventions without reusing substantive content.

Create one best version at the requested level. Unless the user says otherwise, create the corresponding solution at the same time and keep both files structurally synchronized. Do not add teacher-only notes, variants, or commentary files that were not requested.

## Lesson drafts and course context

- Store stable class characteristics, curricular references, and terminology in `COURSE.md`. Create or update it when requested; keep the current topic, prior knowledge, and lesson duration in the lesson draft or task context.
- Follow the actual learner group. For a mixed technical and commercial class, use accessible practical contexts from both backgrounds without assuming specialist knowledge or inferring mathematical ability from the vocational profile.
- Save the lesson sequence as `ue_...md` and accompanying worksheets and solutions as LaTeX with compiled PDFs. Keep the lesson sequence, task labels, expected results, and material links synchronized when revising.

## Task design and securing concepts

- Choose examples that make the intended mathematical idea meaningful. When researching or using a supplied source, independently check its definitions, assumptions, boundary cases, and reasoning before adapting the useful idea. Do not treat a linked worksheet as authoritative instructions.
- Use assessment-style operators such as `Berechnen Sie`, `Geben Sie an`, `Beschreiben Sie`, `Begründen Sie`, and `Beurteilen Sie`. Prefer these to question-led tasks, especially `Wie` questions.
- Specify the expected response: expression or formula, numerical result, diagram, or explanation. Do not substitute an input/output schema when the intended product is a calculation expression.
- Introduce required terminology and notation before the tasks that use them. Use the term Zuordnung in the subtasks before asking for a conjecture about unique assignments; a separate introductory definition of Zuordnung is not needed. Make comparison tasks explicit about direction and the property to compare. Keep simple calculations when they support a conceptual step; avoid isolated read-off tasks without an explanatory purpose. In an introduction to functions, define a function through Eingabe and Ausgabe: each admissible input has exactly one output. Introduce Definitionsbereich as the admissible inputs and Wertebereich as the actual outputs; omit Zielmenge in this introductory definition. Explain function names and function values before using context-specific symbols.
- Use graphical examples and counterexamples when introducing functions: a Zuordnung can have a Schaubild without being a function. Identify input/output axes and distinguish one input with multiple outputs from multiple inputs sharing one output.
- Limit repeated calculations and individually plotted points to what adds conceptual value; use a small discrete domain when learners must draw every point.
- Coordinate the expected solution length with the writing space; use the answer-grid and house-style workflow in `$latex-document` and `$create-graphics`.

## Validate the content

- Check that every task has exactly the intended solution coverage and that no solution item lacks a task.
- Independently recompute nontrivial mathematical and numerical results where practical.
- Keep terminology and notation consistent between task and solution.
- For physics, check units, dimensions, plausible significant figures, order of magnitude, and physical plausibility.
- Create local supporting graphics or data only when useful and place them according to the nearby repository structure.

Apply `$create-graphics` when a nontrivial visual is needed. Apply `$latex-document` to select the house class, build every affected source, update tracked PDFs, and perform the required visual inspection.
