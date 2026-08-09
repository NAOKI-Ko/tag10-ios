# START HERE — TAG10

This is the single Git entry point for a fresh ChatGPT, Codex, or other AI
session. Restore the project from this repository instead of relying on prior
ChatGPT/Codex conversations, account memory, or an earlier handoff message.

## Current Snapshot

- Project: **TAG10**
- Repository: `NAOKI-Ko/tag10-ios`
- Branch: `main`
- Phase: **Phase 2A**
- Work Unit: **Review Sync + Continuity Bootstrap**
- Review Target Implementation Commit:
  `26dfdb29aeb9854631d925d594ac7e5aecf73022`
- Latest Reviewed Implementation Commit:
  `c5d79715acaa30f1a70dbf128e3267bbb11223ad`
- Code Review: **PASS**
- Codex Visual QA: **PASS**
- ChatGPT Visual Review: **PENDING**
- Next Action: **State Snapshot push → ChatGPT exact SHA / Visual Evidence review**
- Phase Gate: **Do not start Phase 2B or Phase 3.**

`Latest Reviewed Implementation Commit` must remain at `c5d79715...` until
ChatGPT completes the final Visual Evidence review of exact implementation SHA
`26dfdb29...` and explicitly records PASS.

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
work unit and applying the current review/phase gate.

## Recovery Procedure

1. Confirm local `main`, `origin/main`, and a clean worktree.
2. Read `docs/PROJECT_STATE.md` before deciding what to do.
3. Confirm the Review Target and Latest Reviewed commits exist in Git.
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

## Current Review Gate

The Phase 2A implementation and Codex Visual QA exist at
`26dfdb29aeb9854631d925d594ac7e5aecf73022`. ChatGPT must still review that exact
implementation SHA and these files:

- `docs/evidence/phase-2a/intro.png`
- `docs/evidence/phase-2a/playing.png`
- `docs/evidence/phase-2a/result.png`

Until that review is PASS and its receipt is synchronized back into Git,
Phase 2A is not formally closed and Phase 2B must not start.
