# End-to-End Testing Guide

Use this guide to verify the skills after installing or modifying them. It walks through every skill, the guard rule, and context recovery across conversations.

## Setup

- Use a small git repository as a playground. The examples below assume a small C# key-value library called `MiniKv` (a .NET class library plus an xUnit test project, run with `dotnet test`) that already has a few conventions for the AI to pick up:
  - a single exception type `KvException` with a stable `KvErrorCode`;
  - key validation through `KeyGuard.EnsureValid`;
  - time read through an injectable `IClock`, with a `ManualClock` for tests.
  Any small repository with a few conventions works; adapt the prompts to your language and domain.
- Commit the starter code so the working tree is clean.
- Install the skills (see the README). After changing skill sources, run the install script again.
- **Open the playground folder on its own in Cursor.** The guard rule only applies when that project is the workspace.
- "You say" lines below are suggested prompts; the skill name in parentheses makes triggering more reliable. Once things work, also try natural phrasing without the skill name to check automatic triggering.
- "Check" lists what to verify after each step.

Useful commands:

```powershell
git status --short                                   # .homework/ and homework-guard.mdc must not appear
git log --oneline
Get-ChildItem .homework -Recurse -Name
Get-Content .homework/tasks/<assignment>/meta.yaml
dotnet test
```

---

## Part 1: a standalone assignment end to end (with cross-conversation checks)

### 1. Assign

You say:
> Use hw-assign to assign this: implement an in-memory store with expiry, MemoryStore, supporting Set(key, value, optional ttl), Get, Remove, and Count. Expired entries count as missing. Spec tier.

Check:
- [ ] The AI read the existing convention files first, and the design reuses `KvException` / `KvErrorCode` and the injectable `IClock`
- [ ] Before writing, it showed a condensed version of modules, acceptance criteria (AC), and progress checklist (P), and waited for confirmation
- [ ] `assignment.md` contains signatures only, no method bodies
- [ ] `meta.yaml`: `status: in-progress`, `tier: spec`, and `base_commit` equals `git rev-parse HEAD`
- [ ] `.cursor/rules/homework-guard.mdc` was created; neither it nor `.homework/` appears in `git status --short`

### 2. Write part of the code, then ask for help twice

Write only `Set` and `Get`, **without handling expiry**.

You say:
> (hw-hint) Get returns the wrong value, expired entries can still be read.

Then:
> Still not clear. Be more specific.

Check:
- [ ] The first hint gives only a direction (location or area), not how to do it
- [ ] The second gives an approach (steps), with no code
- [ ] In `hints.md`, Current status shows the issue at level 2, open; the Log has two entries, both with source `hint`

### 3. New conversation: does the hint level carry over?

**Open a new conversation** and say:
> (hw-hint) I still haven't figured out the expiry problem.

Check:
- [ ] The AI selected the assignment automatically (since there is only one) and said so at the start
- [ ] It went straight to a **level 3** snippet (10 lines at most) instead of starting over at level 1
- [ ] `hints.md` has a new level-3 entry that only says "gave a snippet for ...", with no code pasted

### 4. New conversation: the guard rule

**Open another new conversation without mentioning any hw-skill** and say:
> Implement the Remove method of MemoryStore for me.

Check:
- [ ] The AI did not write code right away; it said "this is within the scope of assignment ...", suggested hw-hint, and asked whether you still want it implemented directly

Then reply:
> Yes, just write it.

Check:
- [ ] The AI wrote `Remove`
- [ ] The Log of `hints.md` has `### AI-written · ... · source guard`, and `Remove` is listed under "AI-written" in Current status

### 5. Check-in with an intentional deviation

Finish `Count` yourself and **deviate from the design on purpose in one place**. For example, if the design has `Get` return `null` for a missing key (or uses a `TryGet` pattern), make it throw `KvException(KvErrorCode.NotFound, ...)` instead; or add an extra parameter to `Set`.

You say:
> (hw-progress) Check my progress.

Check:
- [ ] It showed each P's inferred status with evidence and updated the checklist in `assignment.md` only after you confirmed
- [ ] It pointed out the deviation and asked "is this intentional?"
- [ ] After you answered "intentional, because ...", it did not judge it and recorded it under "Deviations awaiting review" in `progress.md`
- [ ] It made no code-quality comments; `status` in `meta.yaml` is still `in-progress`

### 6. First hand-in: aim to fail

**Don't write tests yet**, or leave an obvious edge-case bug, such as not rejecting a negative or zero `ttl`.

You say:
> (hw-review) Hand in.

Check:
- [ ] Every AC is listed as met or not met
- [ ] The deviation you explained in step 5 was accepted or rejected; if accepted, the Deviation log in `assignment.md` has D-1 and the matching design text was updated and marked "(changed by D-1)"
- [ ] Issues are sorted into Must fix, Suggested, and Optional, numbered `R1-n`, with **no corrected code**
- [ ] The verdict is `changes-requested`, written to `reviews/review-1.md`, and `meta.yaml` was updated to match

You say:
> Just fix it for me.

Check:
- [ ] It declines and suggests hw-hint

### 7. Fix and hand in with a defense

Fix the issues from review-1 and add tests (`MemoryStoreTests.cs`, using `ManualClock` to control time), and make sure `dotnet test` passes.

You say:
> (hw-review) Fixed. Review it and quiz me.

Check:
- [ ] Every `R1-n` from review-1 was re-checked
- [ ] It asked 2 to 3 questions, at least one about the expiry check (H-1) or the AI-written `Remove`, and waited for your answers
- [ ] Answer one question wrong on purpose: the verdict can still be `passed`, and the wrong answer appears under "Understanding gaps"
- [ ] `reviews/review-2.md` was written and the status is `passed`

### 8. Archive

First try without naming the skill:
> Archive this assignment.

Check:
- [ ] hw-archive is not triggered automatically (it can only be invoked by name); the AI may suggest using hw-archive

Then say:
> (hw-archive)

Check:
- [ ] The assignment directory was moved to `.homework/archive/YYYY-MM-DD-<assignment>/` with all files intact
- [ ] It is gone from `.homework/tasks/`, and `status` in its `meta.yaml` is `archived`

Commit the code: `git add -A; git commit -m "feat: memory store"`.

---

## Part 2: the skeleton tier

You say:
> Use hw-assign to assign this: give MemoryStore an optional capacity limit MaxEntries that evicts the least recently used (LRU) entry when exceeded. Skeleton tier.

Check:
- [ ] Stubs were written into the source files, with bodies containing only `// TODO` comments and placeholders such as `throw new NotImplementedException()`
- [ ] It compiles (`dotnet build` passes)
- [ ] The AI asked whether to create a commit containing only the stubs. **Agree**
- [ ] `git log --oneline` shows `hw(<assignment>): scaffold stubs`, and `base_commit` in `meta.yaml` equals that commit

Implement part of it yourself, then say:
> (hw-review) Hand in.

Check:
- [ ] The review's change scope contains only the code you wrote; the stubs themselves are not counted as your changes

(Optional) `git reset` back to before the assignment, assign it again, and **decline** the commit. Check that the stubs are reverted and listed in `assignment.md` instead.

Afterwards, either get it passed and archive it, or delete the assignment directory. Commit your code to keep the working tree clean.

---

## Part 3: the project flow

### 1. Plan

You say:
> (hw-plan) I want to add persistence and a command line to MiniKv: save a snapshot of the data to a JSON file and load it on startup; then provide a command-line tool (a new console project) that supports get/set/remove and stores data in the snapshot file.

Check:
- [ ] The AI asked one question at a time, including how familiar you are with the relevant tech (`System.Text.Json`, file I/O, command-line parsing)
- [ ] It showed the breakdown and dependencies as an ASCII diagram, and wrote no files before you explicitly confirmed
- [ ] The breakdown has at least one dependency, such as the command line (T2) depending on persistence (T1)
- [ ] After confirmation, `.homework/projects/<project>/plan.md` was created, with no code or method signatures and a suggested tier for each assignment
- [ ] It ended with "next: assign T1 with hw-assign"

### 2. Assigning with unmet dependencies is refused

You say:
> (hw-assign) Assign T2.

Check:
- [ ] It refuses and explains that T1 is not archived yet

### 3. Finish T1 with an interface deviation

You say:
> (hw-assign) Assign T1.

Implement it yourself and **make one public interface differ from the design on purpose**. For example, if the design says "throw `KvException(Io)` when the snapshot file is missing", return an empty store instead; or turn a synchronous method into `async Task`.

You say:
> (hw-review) Hand in. Also, I changed xxx to yyy because ...

Check:
- [ ] The deviation was accepted, recorded as D-1, and the matching design text was updated
- [ ] After passing, archive it with hw-archive

Check the archive result:
- [ ] "Established interfaces and conventions" in `plan.md` has a T1 subsection recording the interface **after** the deviation
- [ ] T1 is "done" in the Assignments table; the AI says "T2 can be assigned now"
- [ ] If the deviation conflicts with T2's description, the AI pointed out the conflict and suggested hw-plan, without editing T2 itself

### 4. Assign T2

You say:
> (hw-assign) Assign T2.

Check:
- [ ] T2's design is based on T1's interface after the deviation, not T1's original design (for example, if T1 became async, T2's design calls it asynchronously)

### 5. (Optional) Re-plan

While T2 is in progress, say:
> (hw-plan) Adjust the project: the command line needs a list command too, which requires T1 to provide a way to list all keys.

Check:
- [ ] It explains that T1 is archived and cannot change, and suggests a new assignment
- [ ] It shows a change summary and writes only after you confirm; "Change log" in `plan.md` has a new entry
- [ ] If T2 is affected, its `meta.yaml` has `stale: true` with a reason; any hw-skill invoked on T2 afterwards first reconciles the design with you

---

## Language check

Throughout the steps above, write in a language other than English (for example Chinese) in at least one conversation. Check that the AI replies in that language from its first progress note to its final summary, even though the skills, the code, and the tool output are in English.

## Reporting problems

When something fails, note the step, the skill, and how the actual behavior differed from what was expected. After changing the sources under `skills/`, run the install script again and retry from the relevant step.
