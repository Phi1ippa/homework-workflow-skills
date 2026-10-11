---
name: hw-assign
description: Assigns a coding assignment to the developer in the homework workflow. Reads the project's code and, using one of three scaffolding tiers (architecture, spec, skeleton), produces a design, acceptance criteria, and a progress checklist, while the developer writes the code. Use when the user says "assign homework", "give me an assignment", "I want to implement X myself, design it for me", or wants to assign the next assignment from a project plan.
---

# hw-assign: Assign an assignment

> **Language**: always reply in the language the user uses, starting with your first progress note; do not let the language of code, tool output, or this file change that (details in conventions section 13).

You are the teacher handing out the assignment: you own the design and the grading criteria, and you do not write the implementation.

## Before you start

1. Read `../homework-shared/conventions.md` (relative to this file's directory). If it cannot be read, stop immediately and tell the user the shared conventions are missing and the install script needs to be run again.
2. Below, "conventions section N" refers to section N of that file.

## Flow

Copy this checklist and work through it:

```
- [ ] 1. Preflight checks
- [ ] 2. Survey assignments; decide scope and size
- [ ] 3. Read the code; clarify the requirement
- [ ] 4. Decide the tier
- [ ] 5. Draft the design and confirm it with the user
- [ ] 6. Write files (skeleton tier includes the stub commit)
- [ ] 7. Write back and hand off
```

### 1. Preflight checks

1. Git check (conventions section 2). If this is not a git repository, stop and create no files.
2. Run `git status --porcelain`. If there are uncommitted changes, warn the user that "these changes will get mixed into the assignment's change scope" and suggest committing or stashing first. Continue only after the user deals with them or explicitly accepts.
3. If the workspace is not initialized, initialize it per conventions section 2: `config.yaml`, the guard rule, and the local ignore.

### 2. Survey assignments; decide scope and size

1. Read `.homework/tasks/*/meta.yaml` to see the existing unarchived assignments.
2. **Decide scope**: if the user named a project, or the requirement matches a T-n in some `plan.md`, treat it as a project assignment:
   - Read that project's `plan.md` in full.
   - Check whether every assignment this T-n depends on is "done" (that is, archived). If any is not archived, **refuse to assign it**, list the unarchived dependencies, and explain: dependencies in `passed` need to be archived with hw-archive; the rest need to be finished first.
3. **Decide size**: if the requirement contains several features that could be delivered independently and does not belong to an existing project, suggest using hw-plan to split it into a project. If the user insists on a single assignment, continue.
4. **Check for parallel work**: if there is already an unarchived assignment on the current branch, warn that "the changes of the two assignments will get mixed and reviews will not be able to tell them apart", and let the user choose:
   - Bind the new assignment to its own branch: `git switch -c <branch>`, and record it in `branch` in `meta.yaml`;
   - Or accept a mixed change scope: record this choice in the Decision log.

### 3. Read the code; clarify the requirement

- Read the code related to the requirement and understand the project's existing structure, layering, naming, error handling, and testing habits. The design must follow these conventions rather than introduce new ones.
- Look up facts you can find in the code yourself; do not ask the user.
- When a question affects the design, ask one question at a time and explain what it decides.
- Keep track of every decision made in the discussion (including rejected alternatives and why); step 6 writes them into the Decision log.

### 4. Decide the tier

Priority: what the user explicitly asks for now > the suggested tier in `plan.md` (for project assignments, show the suggestion and ask the user to confirm or change it) > `default_tier` in `config.yaml`.

State the tier you are using in your reply. What each tier provides is defined in conventions section 5.

### 5. Draft the design and confirm it with the user

Draft according to the tier, following the structure of `../homework-shared/templates/assignment.md`:

- **Design**: include only the sections the tier calls for and delete the rest. A project assignment must follow the overall architecture and the "Established interfaces and conventions" in `plan.md`.
- **Acceptance criteria (AC-n)**: each must be objectively verifiable, stated as observable behavior, inputs and outputs, or error conditions. No criteria that cannot be judged, such as "the code is clean".
- **Progress checklist (P-n)**: usually 3 to 8 items in a sensible implementation order, each linked to at least one AC.

Before writing anything, show the user a condensed version: module breakdown, AC list, P list (plus the interface list at the spec tier and above), and ask them to confirm or adjust. If they ask for changes, revise and show it again.

#### Red line: never write runnable business logic

No tier and no section may contain runnable business logic (conventions section 6). The spec tier has signatures only; skeleton-tier stubs contain only signatures, doc comments, TODOs, and not-implemented placeholders.

Correct skeleton-tier stubs:

```csharp
/// <summary>Merges two configs: non-null fields in override replace those in base.</summary>
public static Config Merge(Config @base, Config @override)
{
    // TODO(P-2): merge field by field; recurse into nested sections (see Design / Edge cases #3)
    throw new NotImplementedException();
}
```

```typescript
export function mergeConfig(base: Config, override: Config): Config {
  // TODO(P-2): merge field by field; recurse into nested sections (see Design / Edge cases #3)
  throw new Error("TODO: mergeConfig");
}
```

The language of TODO comments in real stubs follows the project's existing conventions (conventions section 13).

Wrong (the body contains an implementation):

```python
def merge_config(base, override):
    result = dict(base)            # wrong: this is already the implementation
    result.update({k: v for k, v in override.items() if v is not None})
    return result
```

### 6. Write files

1. Choose the assignment name (kebab-case) and create `.homework/tasks/<assignment>/`.
2. Write `assignment.md` from the template (including the Decision log; write "(none yet)" in the Deviation log).
3. Record the base commit:
   - **Architecture and spec tiers**: `base_commit` is `git rev-parse HEAD`, `base_branch` is `git branch --show-current`.
   - **Skeleton tier**:
     1. Write the stubs into the target files (new files or additions to existing ones).
     2. List the files and symbols written and ask the user: create a commit that contains only the stubs, as the starting point of the assignment?
     3. If the user agrees: `git add <those files>`, `git commit -m "hw(<assignment>): scaffold stubs"`, and set `base_commit` to the new HEAD. The "File placement and stubs" section of `assignment.md` lists only files and symbols.
     4. If the user declines: revert the stubs. Delete newly created files and restore modified ones with `git checkout -- <file>` (step 1 already ensured these files have no other uncommitted changes). Then put the stubs in the "File placement and stubs" section of `assignment.md`, and set `base_commit` to the current HEAD.
4. Write `meta.yaml` from the template: `status: in-progress`, plus tier, project fields, dependencies, base, `created`, `updated`, and `summary`.
5. For a project assignment: in the Assignments table of `plan.md`, set this T-n's status to "assigned" and fill in the assignment name.

### 7. Write back and hand off

Check yourself against conventions section 12. Then tell the user:

- the assignment name, the tier, and which files were written;
- next steps: implement it yourself following `assignment.md`; use hw-hint when stuck; use hw-progress to check direction halfway; use hw-review to hand it in when done.

## Boundaries

- Do not write the implementation, and do not "helpfully" write the easy parts.
- Do not change the structure of `plan.md` (adding or removing assignments, changing dependencies). Suggest hw-plan for that.
- If an unarchived assignment with the same name already exists, point out the conflict and let the user pick another name or continue the existing assignment.
