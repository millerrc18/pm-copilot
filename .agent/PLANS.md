# Using PLANS.md for multi-hour problem solving (ExecPlans)

This document describes the requirements for an execution plan (an "ExecPlan"), a living design document that a coding agent can follow to deliver a working feature or system change. Treat the reader as a complete beginner to this repository: they have only the current working tree and the single ExecPlan file you provide. There is no memory of prior plans and no external context.

This file is meant to be referenced by Codex when you ask it to create and execute an ExecPlan.

## How to use ExecPlans and PLANS.md

When authoring an ExecPlan, follow this file to the letter. If this file is not in your context, refresh your memory by reading the entire PLANS.md file. Be thorough in reading (and re-reading) source material to produce an accurate specification. When creating a spec, start from the skeleton and flesh it out as you do your research.

When implementing an ExecPlan, do not prompt the user for "next steps"; proceed to the next milestone. Keep all sections up to date, add or split entries in the list at every stopping point to state the progress made and next steps. Resolve ambiguities autonomously, and commit frequently.

When discussing an ExecPlan, record decisions in a log in the spec for posterity; it should be unambiguously clear why any change to the specification was made. ExecPlans are living documents, and it should always be possible to restart from only the ExecPlan and no other work.

When researching a design with challenging requirements or significant unknowns, use milestones to implement proof-of-concepts and small prototypes that validate feasibility. Include prototypes to guide a fuller implementation.

## Requirements

Non-negotiable requirements:

- Every ExecPlan must be fully self-contained. Self-contained means it contains all knowledge and instructions needed for a novice to succeed.
- Every ExecPlan is a living document. Contributors must revise it as progress is made, as discoveries occur, and as design decisions are finalized. Each revision must remain fully self-contained.
- Every ExecPlan must enable a novice to implement the feature end-to-end without prior knowledge of this repo.
- Every ExecPlan must produce a demonstrably working behavior, not merely code changes.
- Every term of art must be defined in plain language, or do not use it.

Purpose and intent come first. Begin by explaining, in a few sentences, why the work matters from a user's perspective: what someone can do after this change that they could not do before, and how to see it working. Then guide the reader through exact steps to achieve that outcome, including what to edit, what to run, and what they should observe.

The agent executing your plan can list files, read files, search, run the project, and run tests. It does not know any prior context and cannot infer what you meant from earlier milestones. Repeat any assumption you rely on.

Do not point to external blogs or docs. If knowledge is required, embed it in the plan in your own words.

## Formatting

Each ExecPlan must be one single fenced code block labeled as `md` that begins and ends with triple backticks. Do not nest additional triple-backtick fences inside. When you need to show commands, transcripts, diffs, or code, present them as indented blocks within that single fence.

When writing an ExecPlan to a Markdown (.md) file where the content of the file is only the single ExecPlan, omit the triple backticks.

Write in plain prose. Prefer sentences over lists. Avoid checklists, tables, and long enumerations unless brevity would obscure meaning. Checklists are permitted only in the `Progress` section, where they are mandatory.

## Guidelines

Self-containment and plain language are paramount. If you introduce a phrase that is not ordinary English, define it immediately and remind the reader how it manifests in this repository by naming the files or commands where it appears.

Anchor the plan with observable outcomes. State what the user can do after implementation, the commands to run, and the outputs they should see. Acceptance should be phrased as behavior a human can verify rather than internal attributes.

Specify repository context explicitly. Name files with full repository-relative paths, name functions and modules precisely, and describe where new files should be created.

Be idempotent and safe. Write steps so they can be run multiple times without causing drift. If a step can fail halfway, include how to retry.

Validation is not optional. Include instructions to run tests, to start the system if applicable, and to observe it doing something useful. Include expected outputs and error messages so a novice can tell success from failure.

Capture evidence. When steps produce terminal output or logs, include concise examples.

## Milestones

Milestones are narrative. If you break the work into milestones, introduce each with a paragraph describing scope, what will exist at the end, commands to run, and acceptance to observe. Each milestone must be independently verifiable.

## Living plans and design decisions

ExecPlans must contain and maintain:

- `Progress`
- `Surprises & Discoveries`
- `Decision Log`
- `Outcomes & Retrospective`

If you change course mid-implementation, document why in the Decision Log and reflect implications in Progress.

## Skeleton of a good ExecPlan

Use this skeleton as the starting point for every ExecPlan.

    # <Short, action-oriented description>

    This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

    If a PLANS.md file is checked into the repo, reference the path to that file here from the repository root and note that this document must be maintained in accordance with it.

    ## Purpose / Big Picture

    Explain what someone gains after this change and how they can see it working.

    ## Progress

    Use a list with checkboxes to summarize granular steps. Every stopping point must be documented here.

    - [ ] Example incomplete step.

    ## Surprises & Discoveries

    Document unexpected behaviors with concise evidence.

    ## Decision Log

    Record decisions:

    - Decision: ...
      Rationale: ...
      Date/Author: ...

    ## Outcomes & Retrospective

    Summarize outcomes, gaps, and lessons learned.

    ## Context and Orientation

    Describe the current state relevant to this task as if the reader knows nothing.

    ## Plan of Work

    Describe, in prose, the sequence of edits and additions. Name exact files and locations.

    ## Concrete Steps

    State exact commands to run and where to run them. Include short expected outputs.

    ## Validation and Acceptance

    Describe how to exercise the system and what to observe.

    ## Idempotence and Recovery

    Provide safe retry and rollback paths.

    ## Artifacts and Notes

    Include key evidence snippets.

    ## Interfaces and Dependencies

    Name libraries and interfaces to use and why.

