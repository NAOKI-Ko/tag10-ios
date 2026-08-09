# START HERE — TAG10

This is the single Git entry point for a fresh ChatGPT, Codex, or other AI
session. Restore the project from this repository instead of relying on prior
ChatGPT/Codex conversations, account memory, or an earlier handoff message.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `main`
- Phase: **Phase 2B — Visual Polish**
- Status: **CLOSED / APPROVED**
- Work Unit: **Phase 2B Final Review Sync**
- Latest Reviewed Implementation Commit:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Phase 2B Review Target Implementation Commit:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Reviewed Phase 2B State Snapshot:
  `59b75cbc3af84148721bc58e5870d4c6ba9f8fed`
- Phase 2B Handoff Sync:
  `54bd99d750ffcd47f2a26a2af9ade678591312c6`
- Phase 2B Code / State Review: **PASS**
- Phase 2B Codex Visual QA: **PASS**
- Phase 2B ChatGPT Final Visual Review: **PASS**
- Final Decision: **APPROVE**
- Continuity: **READY**
- Review Sync: **completed by the commit containing this snapshot**
- Next Action: **Await explicit Phase 3 Work Unit from ChatGPT / Notion.**
- Phase Gate: **Do not start Phase 3 automatically.**

Phase 2B is formally closed. No implementation work is currently authorized;
the repository must remain at this approved state until an explicit Phase 3
Work Unit is provided by ChatGPT / Notion.

## Cold Start Reading Order

Read in this order before selecting or changing work:

1. `docs/START_HERE.md`
2. `docs/PROJECT_STATE.md`
3. `AGENTS.md`
4. `docs/PRODUCT_SPEC.md`
5. `docs/GAME_RULES.md`
6. `docs/IMPLEMENTATION_PLAN.md`
7. `docs/QA_CHECKLIST.md`
8. `prototype/tag10-heat.html`
9. `docs/CODEX_REPORT.md`
10. `docs/REVIEW_LOG.md`
11. Relevant source and tests for the explicitly authorized task

For gameplay balance and behavior, `docs/GAME_RULES.md` is authoritative. The
HTML prototype is the reference for feel, rendering ideas, CPU behavior, and
existing flow. `docs/PROJECT_STATE.md` is authoritative for choosing the next
work unit and applying the current phase gate.

## Recovery Procedure

1. Confirm local `main`, `origin/main`, and a clean worktree.
2. Read `docs/PROJECT_STATE.md` before deciding what to do.
3. Confirm the Latest Reviewed implementation and referenced review commits
   exist in Git.
4. Confirm the evidence paths and review statuses recorded in PROJECT_STATE.
5. Work only on the explicit task authorized by PROJECT_STATE or the user.
6. Keep `PROJECT_STATE.md`, `CODEX_REPORT.md`, and `REVIEW_LOG.md` synchronized
   when implementation, verification, review, or the next action changes.

## Stop Conditions

Stop without implementation and report the conflict if any of the following
disagree:

- Notion's active Work Unit
- `docs/PROJECT_STATE.md`
- Git specifications and source-of-truth documents
- Source code and tests
- Review Target / Latest Reviewed commit history
- Explicit user instructions

Do not resolve a state or product contradiction by guessing. Do not advance to
a later phase until `docs/PROJECT_STATE.md` or an explicit task authorizes it.

## Phase 2B Final Review Receipt

- Decision: **APPROVE**
- Approved Implementation / Latest Reviewed Implementation:
  `b6ff62966387df9eebc1d322cf14d89133a51276`
- Reviewed State Snapshot:
  `59b75cbc3af84148721bc58e5870d4c6ba9f8fed`
- Handoff Sync:
  `54bd99d750ffcd47f2a26a2af9ade678591312c6`
- Code / State Review: **PASS**
- Codex Visual QA: **PASS**
- ChatGPT Final Visual Review: **PASS**
- Evidence reviewed:
  - `docs/evidence/phase-2b/intro.png`
  - `docs/evidence/phase-2b/countdown.png`
  - `docs/evidence/phase-2b/result.png`
- Deferred Visual Validation:
  - motion trail → Phase 3
  - tag effect → relevant gameplay phase
  - shock effect → relevant gameplay phase
- Phase Gate: **Phase 3 must not start until a new Work Unit explicitly
  authorizes it.**
