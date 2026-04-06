# Project: project-z 

Short description: What this project does in one sentence.
Tech stack: Godot_v4.6

## My Preferences & Rules (YOU MUST FOLLOW THESE)

- Always think step-by-step before editing files.
- Be extremely careful with file edits — show me a diff or plan first when possible.
- Prefer small, safe changes over big refactors unless I ask.
- Use clear, descriptive variable/function names.
- Add comments only when the code is complex.
- Never commit secrets, .env files, or large binaries.
- Always run tests/lint/build after making changes if they exist.

## Coding Style

- Follow existing style in the project.
- Use [your preferred conventions, e.g. 4 spaces, single quotes, etc.]
- Keep functions small and focused.
- Error handling: Be explicit, never silent failures.

## How to Run the Project

- Build command: `make build` or `npm run build`
- Run dev server: `npm run dev`
- Run tests: `npm test` or `cargo test`
- Lint: `npm run lint`

## Project Structure

- `/src` → main source code
- `/tests` → all tests
- `/docs` → documentation
- Key files: README.md, main.py / index.ts, etc.

## Important Notes

- This is running on a local 9B model → be extra patient with long tasks and break them down.
- If you get stuck, ask for clarification instead of guessing.
- Prefer using tools (read_file, edit_file, bash) over assuming.

## Memory / Context

Always keep in mind the user's goal: [write your current goal here]

## Auto-Learning Rules (Very Important)

- After every significant task, successful change, or mistake correction, you MUST summarize what you learned in 2-4 bullet points.
- At the end of the session or when I say "update memory", propose improvements to this CLAW.md file.
- Use the `edit_file` tool to actually update CLAW.md with new rules, preferences, or lessons.
- Only add high-confidence learnings. Keep the file under 250 lines total.
- Structure new learnings like this:

**Learned [Date]:**
- Rule: ...
- Example: ...
- Why: ...