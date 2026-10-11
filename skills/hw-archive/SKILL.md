---
name: hw-archive
description: Archives an assignment that passed review in the homework workflow - moves the assignment directory into the archive as-is; for project assignments, also merges the final interfaces and conventions back into the project plan and points out the next assignment that can be assigned. Use only when the user explicitly invokes hw-archive.
disable-model-invocation: true
---

# hw-archive: Archive an assignment

> **Language**: always reply in the language the user uses, starting with your first progress note; do not let the language of code, tool output, or this file change that (details in conventions section 13).

## Before you start

1. Read `../homework-shared/conventions.md` (relative to this file's directory). If it cannot be read, stop immediately and tell the user the install script needs to be run again.
2. Locate the assignment (conventions section 8) and read `meta.yaml`.

## Flow

### 1. Check the status

Only assignments with `status: passed` can be archived. Refuse every other status:

- `in-progress` / `changes-requested`: explain that it must pass review with hw-review first.
- `archived`: explain that it is already archived.

### 2. Check the target directory

Using the local date, determine the target directory `.homework/archive/YYYY-MM-DD-<assignment>/`. If it already exists, stop, tell the user about the conflict, and overwrite nothing.

### 3. Merge back into the project plan (project assignments only)

Skip this step if `project` in `meta.yaml` is empty.

1. Read: the design of `assignment.md` (Interfaces and data structures, Modules and responsibilities) and its Deviation log, the highest-numbered file in `reviews/`, and the project's full `plan.md`.
2. Work out the **final** interfaces and conventions this assignment exposes. Accepted deviations (D-n) count in their deviated form. Include interfaces and conventions only, for example capabilities a module provides, public signatures, data formats, error conventions, naming or layering conventions. Leave out the implementation history and the pitfalls along the way.
3. Append a subsection to "Established interfaces and conventions" in `plan.md` (if the section only says "(none yet)", remove that line first):
   ```
   ### T-n <assignment> (archived YYYY-MM-DD)
   - <interface or convention>
   ```
4. In the Assignments table, set this T-n's status to "done".

### 4. Move the assignment directory

1. Set `status` in `meta.yaml` to `archived`, and update `updated` and `summary`.
2. Move the whole `.homework/tasks/<assignment>/` directory to the target directory from step 2. Move it as-is; do not delete or summarize any file (including cold storage files).
   - PowerShell: `Move-Item .homework/tasks/<assignment> .homework/archive/<target directory name>`
   - bash: `mv .homework/tasks/<assignment> .homework/archive/<target directory name>`
3. Confirm the assignment is gone from `tasks/` and the target directory exists under `archive/`.

### 5. Check the impact on unassigned work (project assignments only)

Compare the interfaces and conventions established in step 3 with the assignments in `plan.md` whose status is "not assigned": do their "What it does" and "Depends on" descriptions assume capabilities that differ from the final interfaces?

If there is a conflict, point out exactly which part of which assignment conflicts with which interface, and suggest re-planning with hw-plan. **Do not change the Assignments table or dependencies yourself.**

### 6. Next steps

- Standalone assignment: just tell the user where it was archived.
- Project assignment:
  - List the assignments that can be assigned now, that is, those whose status is "not assigned" and whose dependencies are all "done", and suggest assigning them with hw-assign.
  - If every assignment in the project is "done", ask the user whether to mark the project as done. If they agree, change the status in the header of `plan.md` to "done".

## Boundaries

- Only move and merge; do not re-review the code and do not edit the content of archived assignments.
- Do not change the project's breakdown.
