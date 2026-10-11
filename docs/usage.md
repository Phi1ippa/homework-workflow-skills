# Homework Workflow Usage Guide

These skills let you write the code yourself with the AI's help: the AI designs, answers questions, and grades, while you write the code, much like homework at school. The goal is not to have the AI write faster for you, but to make sure you truly understand the code in your own repository while still using AI.

For installation, see the [README](../README.md).

## 1. The overall flow

```
  small requirement ---------------------------+
                                               v
  big requirement --> [hw-plan] --> plan.md --> [hw-assign] --> assignment.md
                      plan project              assign
                                                    |
                         +--------------------------+------------------+
                         v                          v                  v
                     [hw-hint]               [hw-progress]      (you write code)
                     when stuck               mid-way check
                         |                          |
                         +------------+-------------+
                                      v
                                 [hw-review] --- changes requested ---> fix, hand in again
                                    review
                                      | passed
                                      v
                                [hw-archive] --> project assignments: merged into plan.md,
                                   archive        next assignment unlocked
```

An assignment has only four statuses:

```
  in-progress --(review)--> passed --(archive)--> archived
       ^           |
       |           v
   changes-requested
```

## 2. How to invoke a skill

- **By name (most reliable)**: mention the skill name in your message, for example "use hw-assign to assign...", or type `/hw-assign`.
- **Natural language**: every skill except hw-archive can be triggered by phrases like "assign homework", "I'm stuck", or "hand in". If it does not trigger, name the skill.
- **hw-archive can only be invoked by name.** It moves files, so it is never triggered automatically.

Every skill replies in the language you write in.

## 3. Each skill: when to use it and example prompts

### hw-plan: plan a project

**When to use it**

- The requirement is big, with several independently deliverable features that should be split into assignments done in order.
- You are not sure whether to split it and want to think it through with the AI first.
- The project is under way and requirements changed, or hw-archive reported that an assignment's outcome conflicts with the later plan.

**What it does**

It works like a discussion: one question at a time, diagrams for the breakdown and dependencies, and a suggested tier for each assignment based on how familiar you are with the tech involved. It writes nothing until you explicitly confirm. There are only two outcomes: it writes the project plan `plan.md`, or it tells you "one assignment is enough" and hands off to hw-assign.

**Prompts**

Starting:

> Use hw-plan to plan this: I want to add a save system to my game, with local saves, cloud sync, and a save-slot screen.

> This requirement is a bit big. Help me split it into assignments.

> (hw-plan) I want to build a command-line tool that supports get/set/remove and stores data in a JSON file. Help me decide whether it needs splitting.

During the discussion:

> I'm not familiar with System.Text.Json, so give those assignments the skeleton tier. I know file I/O well, so the architecture tier is fine there.

> Put the UI assignments later. Get the data layer solid first.

> T2 is too big. Split it further.

> Don't write any files yet. Let me think about it.

Confirming:

> Looks good. Write it with this breakdown.

Re-planning:

> (hw-plan) Adjust project save-system: we're dropping cloud sync for now, take it out of the plan.

> The archive step said T3 conflicts with T1's interface. Use hw-plan to adjust it.

**Notes**

- Archived assignments cannot be changed; add a new assignment to adjust.
- In-progress assignments affected by re-planning are flagged as "stale". Any skill you invoke on them afterwards first reconciles and fixes the design with you.

---

### hw-assign: assign an assignment

**When to use it**

- You want to implement a feature yourself and need a design and acceptance criteria.
- The project plan has a next assignment ready to be assigned.

**What it does**

It reads your code first so the design follows your project's existing structure and conventions, asking one question at a time when something is unclear. Before writing anything, it shows you a condensed version (modules, acceptance criteria AC, progress checklist P). Only after you confirm does it write `assignment.md` and record the base commit. Later reviews use that commit as the starting point to tell which code you wrote. At no tier does it write runnable implementation.

**Choosing a tier**

| Tier | What you get | Good for |
|---|---|---|
| Architecture | Module breakdown, responsibilities, data flow, acceptance criteria | Familiar territory; you want to design the interfaces too |
| Spec (default) | Plus interface signatures, data structures, key approach, edge cases | Most tasks |
| Skeleton | Plus stubs written into your code files (signatures and TODOs only), pseudocode for hard parts | Unfamiliar domains or tech stacks |

**Prompts**

Standalone assignments:

> Use hw-assign to assign this: implement an in-memory cache with expiry, supporting Set, Get, Remove, and Count.

> Assign homework: implement item stacking and splitting for the inventory system. Use the skeleton tier; I don't know this area well.

> Assign homework: add size-based rolling to the logging module. Use the architecture tier; I'll design the interfaces myself.

> I want to implement JWT validation middleware myself. Design it for me.

Project assignments:

> (hw-assign) Assign T1.

> Assign the next assignment in project save-system.

When confirming the condensed version:

> AC-3 is too strict, drop it.

> Make the progress checklist finer; split P-2 into two steps.

> Good, write it.

Responding to prompts:

> Bind this assignment to a new branch feature/inventory. (when another assignment is on the same branch)

> Yes, create the scaffold commit. / Don't commit; put the stubs in the document. (skeleton tier)

**Notes**

- Commit or stash your current changes before assigning, or they will mix into the assignment's change scope. It will remind you.
- A project assignment can only be assigned after the assignments it depends on are **archived**. Passing review is not enough.
- If the requirement is too big, it suggests hw-plan instead. If you insist, it will still assign it as one assignment.

---

### hw-hint: graded hints

**When to use it**

You are stuck while writing code: you do not know where to start, your approach is not working, or the result is wrong and you cannot find out why.

**What it does**

Hints come in three levels, and it only goes up when you say it is not enough:

| Level | What you get |
|---|---|
| 1 Direction | Where the problem is (location or area), which part of the design to revisit |
| 2 Approach | Solution steps, patterns to use, pitfalls to watch; no code |
| 3 Snippet | 3 to 10 lines of key code, never a whole function |

Every hint is logged in `hints.md`. Ask about the same issue in a new conversation and it continues from the last level.

**Prompts**

> I'm stuck: Get returns the wrong value, expired entries can still be read.

> (hw-hint) Deserializing the save file keeps dropping fields. Give me a hint.

> Still not clear. Be more specific.

> Just give me the level 3 hint.

> I still haven't figured out the expiry problem. (continuing an earlier issue in a new conversation)

> I've solved H-2.

> I still can't write it. Just write it for me. (it confirms once, then records it as "AI-written")

**Notes**

- Hints stay consistent with the assignment's design. If your code already deviates from the design, it points out the deviation first.
- AI-written parts get special attention in reviews and defenses. This is not a penalty; it is to make sure you understand that code.

---

### hw-progress: status and check-ins

**When to use it**

- You want to see which assignments you have and how far each one is.
- You are halfway through and want to check your direction before finishing, rather than finding out at the end.
- You are back after a few days and want to get your bearings quickly.

**What it does**

It infers each progress item's status from the code and updates the checklist only after you confirm. When the code differs from the design, it first asks whether that is intentional:

- Intentional: it records your reason for the review to evaluate, without judging it now.
- Unintentional: it asks whether you want to know how to fix it, and if so gives hints following hw-hint's graded rules.

It does not grade, does not review code quality, and does not change the assignment's status.

**Prompts**

> What assignments do I have?

> Where am I?

> Do a check-in on memory-store.

> I'm halfway through. Is my direction right?

Responding to its inferences and warnings:

> P-3 isn't finished yet, mark it in progress.

> That deviation is intentional: Get throws NotFound now, because callers need to tell "missing" apart from "empty value".

> Not intentional. Give me a hint on how to bring it back in line.

> Not intentional. I'll fix it myself.

---

### hw-review: review an assignment

**When to use it**

You finished the assignment, or finished the fixes from the last review.

**What it does**

1. Reviews only the code you changed after the base commit.
2. Checks each acceptance criterion.
3. Evaluates deviations from the design. The design is a suggestion, not a contract: deviations with a sound reason are accepted and written back into the design; unsound ones must be fixed; for ones without a stated reason, it asks you why first.
4. Sorts code issues into "Must fix", "Suggested", and "Optional". It only points out problems, never provides corrected code, and never touches your files.
5. Verdict: `passed` when every acceptance criterion is met, no deviation is rejected, and there are no "Must fix" issues; otherwise `changes-requested`.
6. Defense (optional): 2 to 3 questions about where you got stuck, where you deviated, and what the AI wrote. Weak answers are listed as "Understanding gaps" and never fail the assignment on their own.

**Prompts**

> Hand in.

> I'm done. Review it.

> Review it and quiz me.

> Hand in. No defense this time.

> Hand in. Also, I changed load failures from throwing an exception to returning an empty save, because having no save file on first launch is normal. (explaining a deviation up front saves a round trip)

> Fixed. Review it again. (after rework, it re-checks each issue from the last review)

After the review:

> Why is R1-2 a must-fix?

> How do I fix this? (it suggests getting hints with hw-hint)

**Notes**

- If something can be verified by a command (such as `dotnet test` or `npm test`), it runs it. For Unity projects, tests run in the Editor, so tell it the Test Runner results.
- It does not add new acceptance requirements on the spot. If the acceptance criteria missed something important, it raises it as "Suggested", which does not affect the verdict.

---

### hw-archive: archive an assignment

**When to use it**

After an assignment passes review (`passed`). Can only be invoked by name.

**What it does**

- Moves the assignment directory as-is to `.homework/archive/<date>-<assignment>/`.
- For project assignments, it also merges the assignment's final interfaces and conventions (including accepted deviations) into `plan.md`, marks it done, and tells you which assignments can be assigned now.
- If the newly established interfaces conflict with the plan for later assignments, it points out the conflict and suggests adjusting with hw-plan, without changing the plan itself.

**Prompts**

> /hw-archive

> Use hw-archive to archive memory-store.

---

## 4. The guard rule: soft reminders in new conversations

The first time you assign an assignment, `.cursor/rules/homework-guard.mdc` is created in your project. It applies in every conversation:

- When you ask for code that falls inside an assignment's scope, the AI first reminds you "this is within the scope of assignment X", suggests hw-hint, and asks whether you still want it implemented directly.
- If you confirm, it implements it as usual and records that part as "AI-written".
- Requests unrelated to any assignment, questions, and code explanations are not affected.

Prompts for responding to the reminder:

> Give me a hint then.

> Yes, just write it.

## 5. Typical scenarios

### Scenario 1: a small feature

```
You: Use hw-assign to assign: implement item stacking. Spec tier.
     ... confirm the condensed version, files written ...
(you write code)
You: I'm stuck, the counts are wrong when splitting.   -> hw-hint level 1
You: Be more specific.                                  -> level 2
(keep writing)
You: Hand in.                                           -> changes-requested
(fix according to the review)
You: Fixed. Review it and quiz me.                      -> passed
You: /hw-archive
```

### Scenario 2: a big feature that needs several assignments

```
You: Use hw-plan to plan: a save system with local saves + cloud sync + a save-slot screen.
     ... discuss, confirm the breakdown, plan.md written
         (T1 local saves, T2 cloud sync depends on T1, T3 screen depends on T1) ...
You: Assign T1.
     ... finish it, review passes ...
You: /hw-archive                     -> T1's interfaces merged into plan.md; T2 and T3 can now be assigned
You: Assign T2.                      -> designed against T1's final interfaces
```

### Scenario 3: coming back after a few days

```
You: What assignments do I have?                   -> list with one-line status
You: Do a check-in on save-local.                  -> progress, recorded deviations
You: I still haven't figured out the expiry issue. -> hw-hint continues from the last level
```

## 6. Configuration

`.homework/config.yaml`:

| Field | Default | Purpose |
|---|---|---|
| `default_tier` | `spec` | Tier used when none is specified: `architecture`, `spec`, `skeleton` |
| `language` | empty | Language for the body of assignment files, such as `en` or `zh-CN`; empty means follow your language. Conversation always uses your language |
| `review.defense` | `false` | Whether reviews include a defense by default; override per review with "quiz me" or "no defense" |

## 7. Files created in your project

```
<project>/
  .homework/
    config.yaml
    projects/<project>/plan.md           project plan
    tasks/<assignment>/
      meta.yaml                          status, tier, base commit
      assignment.md                      requirement, design, acceptance criteria, progress checklist, decisions, deviations
      hints.md                           hint log
      progress.md                        progress snapshots
      reviews/review-N.md                review reports
    archive/<date>-<assignment>/         archived assignments
  .cursor/rules/homework-guard.mdc       guard rule
```

All of these are listed in `.git/info/exclude`, so they are local only: they never appear in `git status`, are never committed, and your `.gitignore` is not modified. At the skeleton tier, if you agree, a commit `hw(<assignment>): scaffold stubs` is created; it is the only thing that enters your commit history.

## 8. FAQ

**Will the AI remember the assignment in a new conversation?**
Yes. Everything lives in the assignment files, and every skill restores context from those files and git at the start, without relying on chat history.

**Can I work on several assignments at once?**
Yes, but several assignments on the same branch mix their changes, and reviews cannot tell them apart. When you assign a second one, it suggests binding it to a new branch. Project assignments with dependencies must be done in order.

**What if I don't like the AI's design?**
Ask for changes when it is being assigned. If you only find the problem while writing, write it the way you think is right and explain why when you hand in; sound deviations are accepted and written back into the design.

**Will reviews break after a rebase or squash?**
No. If the base commit cannot be found, it falls back to the merge base of the base branch and the current HEAD, and tells you it did so.

**What if I just want the AI to write some part directly?**
You can. After you confirm once, it writes it, but records it as "AI-written", and reviews and defenses focus on that part.

**How do I stop using it and clean up?**
Delete `.homework/` and `.cursor/rules/homework-guard.mdc` from your project, then remove the two matching lines from `.git/info/exclude`. To uninstall the skills themselves, see the README.
