# Homework Workflow Shared Conventions

Every hw-* skill (hw-plan, hw-assign, hw-hint, hw-progress, hw-review, hw-archive) must read this whole file before doing any work. It defines the workspace layout, metadata, state machine, tiers, and the rules for restoring context and writing it back. Each skill only describes its own flow and does not repeat these conventions.

Templates live in `templates/` next to this file. Reference them by paths relative to this file, for example `templates/meta.yaml`.

## 1. Directory layout

```
<target project root>/
  .homework/
    config.yaml                     workspace config
    projects/
      <project>/plan.md             project plan (created by hw-plan)
    tasks/
      <assignment>/
        meta.yaml                   metadata
        assignment.md               requirement, design, acceptance criteria, progress checklist, decisions, deviations
        hints.md                    hint log (created on the first hint)
        hints.history.md            hint cold storage
        progress.md                 progress snapshots (created on the first check-in)
        progress.history.md         progress cold storage
        reviews/
          review-1.md               review reports, numbered in order
    archive/
      YYYY-MM-DD-<assignment>/      archived assignments, kept as-is
  .cursor/rules/homework-guard.mdc  guard rule
```

- Assignment and project names are always kebab-case, for example `config-loader`.
- An assignment that does not belong to any project is a "standalone assignment". Its layout is identical to a project assignment; only the project fields in `meta.yaml` are empty.

| File | Template |
|---|---|
| `config.yaml` | `templates/config.yaml` |
| `meta.yaml` | `templates/meta.yaml` |
| `assignment.md` | `templates/assignment.md` |
| `plan.md` | `templates/plan.md` |
| `hints.md` | `templates/hints.md` |
| `progress.md` | `templates/progress.md` |
| `reviews/review-N.md` | `templates/review.md` |
| `homework-guard.mdc` | `templates/homework-guard.mdc` |

## 2. Preflight checks and initialization

### Git check

The workflow relies on git to determine an assignment's change scope. Before any operation that writes to the workspace, run:

```bash
git rev-parse --is-inside-work-tree
```

If this is not a git repository: stop, create no files, and explain that the assignment's change scope is computed with git. Suggest running `git init` and making an initial commit first.

### Initialization

hw-plan or hw-assign runs this the first time it needs to write. Skip any part that already exists:

1. Create `.homework/` and write `config.yaml` from the template.
2. If the guard rule `.cursor/rules/homework-guard.mdc` does not exist, create it from the template. Never overwrite an existing one.
3. Local ignore: get the exclude file path with `git rev-parse --git-path info/exclude`, and append these two lines if they are missing:
   ```
   .homework/
   .cursor/rules/homework-guard.mdc
   ```
   Do not modify the project's `.gitignore`.

## 3. Metadata: `meta.yaml`

Fields are defined in `templates/meta.yaml`. Key points:

- `summary` is a one-line status. Listing assignments reads only this field and never opens markdown files.
- `depends_on` holds project task ids (for example `[T1]`); it is an empty list for standalone assignments.
- `stale` and `stale_reason` are a staleness flag, not a status. Only hw-plan sets them when re-planning; whichever skill reconciles the design with the user clears them.
- Every write-back updates `updated` and `summary`.

## 4. State machine

There are exactly four statuses: `in-progress`, `changes-requested`, `passed`, `archived`.

```
  (assign) --> in-progress --(review)--> passed --(archive)--> archived
                   ^              |
                   |              v
                   +----- changes-requested
                (user keeps coding; the next review decides again)
```

| Transition | Performed by |
|---|---|
| none -> `in-progress` | hw-assign |
| `in-progress` / `changes-requested` / `passed` -> `passed` or `changes-requested` | hw-review |
| `passed` -> `archived` | hw-archive |

All other transitions are invalid. hw-hint and hw-progress never change the status. When a request does not meet the required status, refuse and explain what has to happen first.

An "unarchived assignment" is any assignment under `tasks/` whose status is not `archived`.

## 5. Scaffolding tiers

| Tier | `tier` value | What the design provides |
|---|---|---|
| Architecture tier | `architecture` | Module breakdown, responsibilities, data flow, acceptance criteria |
| Spec tier (default) | `spec` | Everything in the architecture tier + interface signatures, types and data structures, key approach, edge-case list |
| Skeleton tier | `skeleton` | Everything in the spec tier + file placement, stubs with only signatures and TODOs, pseudocode for the hard parts |

## 6. Red line: never write runnable business logic

The AI does not write the implementation for the developer. The only exceptions:

1. Skeleton-tier stubs: only signatures, doc comments, TODO comments, and "not implemented" placeholders (such as `raise NotImplementedError`, `throw new NotImplementedException()`, `todo!()`).
2. hw-hint level-3 hints: a key snippet of at most 10 lines, never a whole function.
3. The user, after being reminded, explicitly confirms they want the AI to implement it: do it, and add an "AI-written" entry to that assignment's `hints.md`.

## 7. IDs and references

| ID | Meaning | Defined in |
|---|---|---|
| `AC-n` | Acceptance criterion | `assignment.md` |
| `P-n` | Progress item | `assignment.md` |
| `D-n` | Accepted deviation | `assignment.md` Deviation log |
| `H-n` | Hint issue (a single hint is `H-n.m`) | `hints.md` |
| `R<review number>-n` | Issue raised in a review, e.g. `R2-3` | `reviews/review-N.md` |
| `T-n` | Assignment within a project | `plan.md` |

- Once assigned, an ID never changes and is never reused.
- Documents reference each other by ID instead of copying content. For example, write "AC-3 not met" rather than restating AC-3.
- Never paste code that can be retrieved from git into documents; refer to file paths and symbol names. The only exception is stubs listed in `assignment.md` when a skeleton-tier commit was declined.

## 8. Locating the assignment

Skills that act on a single assignment locate it in this order:

1. The user named an assignment -> use it.
2. The current branch (`git branch --show-current`) matches an assignment's `branch` field -> use it.
3. Exactly one unarchived assignment exists -> select it automatically and say which one at the start of the reply.
4. Several unarchived assignments exist -> list each one's name, project, status, and `summary`, then wait for the user to choose. Never pick one on your own.
5. No unarchived assignments -> say so, suggest hw-assign, and stop.

## 9. Restoring context

Every skill restores context from files and git only, and never relies on anything said earlier in the conversation.

1. Locate the assignment (section 8) and read `meta.yaml`.
2. If `stale: true`: first explain `stale_reason` to the user, reconcile and fix the affected design in `assignment.md` together with them, clear the stale flag, and only then continue with the original operation.
3. Read files according to the table below. "Current status" means the "Current status" section at the top of a log file.
4. Check code progress: look at the change summary first (section 10), then read only the files relevant to the task at hand.

| Skill | meta | assignment | hints | progress | reviews | plan.md |
|---|---|---|---|---|---|---|
| hw-plan | all assignments | - | - | - | - | full |
| hw-assign | all assignments | writes | - | - | - | full (project assignments) |
| hw-hint | read | relevant sections | Current status + log entries for the current issue | Current status | - | - |
| hw-progress | read (all when listing) | design + progress checklist | Current status | Current status | - | - |
| hw-review | read | full | Current status + Log | Current status | latest one | - |
| hw-archive | read | design + Deviation log | - | - | latest one | full (project assignments) |

Cold storage files (`*.history.md`) and older reviews are not read by default; read them only when you need to look up a specific detail.

## 10. Change scope

An assignment's change scope = the diff from the base commit to the current working tree (including uncommitted changes) + untracked new files:

```bash
git diff --stat <base_commit>                  # overview first
git diff <base_commit> -- <path>               # then specific files
git ls-files --others --exclude-standard       # untracked new files
```

- Check that the base commit exists with `git cat-file -e <base_commit>^{commit}`. If it is gone (after a rebase or squash), use `git merge-base <base_branch> HEAD` instead and tell the user that a fallback happened.
- If the assignment is bound to a branch and you are not on it, remind the user to switch first.
- `.homework/` is locally ignored, so it never shows up in the change scope.

## 11. Log files: status vs. log, hot vs. cold

`hints.md` and `progress.md` have two sections:

- **Current status**: overwritten, always kept short. New conversations read only this section by default.
- **Log**: appended, newest last.

Length budget:

| Content | Limit |
|---|---|
| One hint entry | 5 lines |
| One progress snapshot | 8 lines |
| Entries in a Log section | 5; move the overflow |
| One review report | template sections, about one page |
| The Established section of `plan.md` | interfaces and conventions only, no process |

Overflow rule: after appending an entry, if the Log section has more than 5 entries, cut the oldest entry **verbatim** and append it to the matching cold storage file (`hints.history.md` / `progress.history.md`). Never summarize or delete. If the cold storage file does not exist, create it with the first line `# <original file name> cold storage`.

## 12. Writing back

A conclusion reached in conversation but not written to a file does not exist. Before finishing, every skill checks itself against this list:

```
- [ ] Decisions, conclusions, and reasons the user gave this time are all written to the right files
- [ ] meta.yaml `updated` and `summary` are updated
- [ ] If the status changed, the transition follows section 4
- [ ] Any Log section with more than 5 entries has been moved to cold storage
- [ ] New IDs are sequential and not reused; documents reference each other by ID
- [ ] No code that git can provide was pasted into documents
```

Always use the local date in `YYYY-MM-DD` format. If unsure, get it from the shell instead of guessing.

## 13. Language

This file and the templates are written in English, but that does not decide the output language.

- **Conversation**: always reply in the language of the user's most recent message, including the opening progress note, updates along the way, and the final summary. Do not switch because of the language of code, comments, tool output, or this file, and do not mix two languages in one sentence. When you need to mention a fixed term from the templates, render it in the user's language.
- **Assignment files**: write the body in the language set by `language` in `config.yaml`; if it is not set, use the user's language. Keep the fixed headings from the templates unchanged (such as "Current status", "Log", "Acceptance criteria", "Progress checklist", "Deviation log", "Established interfaces and conventions"), because other skills rely on them to find content.
- **Code**: identifiers and code comments follow the target project's existing conventions. For example, if the project's comments are in English, TODO comments in stubs are in English too.
