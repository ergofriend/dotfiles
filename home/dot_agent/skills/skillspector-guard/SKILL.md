---
name: skillspector-guard
description: Run SkillSpector before Codex or Claude reviews, answers questions about, compares, installs, adds, updates, audits, approves, or evaluates AI agent skills. Use for Codex/Claude/Cursor/agent skills from a local path, Git URL, zip, plugin, repository, marketplace source, or skills folder.
---

# SkillSpector Guard

Use SkillSpector as the first safety check before recommending, installing, or approving an AI agent skill.

## Workflow

1. Identify the skill source: local folder, Git URL, zip, marketplace/plugin reference, or repository path.
2. If no source is available, ask the user for the skill path or source URL.
3. Before install or approval, run SkillSpector on the source with JSON output.
4. Read the JSON report and relevant skill files, then summarize the risk score, severity, recommendation, and notable findings.
5. Do not install or recommend installing a skill with HIGH/CRITICAL findings unless the user explicitly accepts the risk after seeing the findings.

## Commands

Prefer static analysis first:

```sh
skillspector scan <skill-source> --no-llm --format json
```

Treat this as the default path: SkillSpector produces a machine-readable static report, then the calling agent reviews that report together with relevant source files such as `SKILL.md`, scripts, manifests, and install commands.

Use SkillSpector's internal LLM analysis only when the user asks for it and the required provider credentials are already configured:

```sh
skillspector scan <skill-source>
```

If `skillspector` is not available, ask the user how they want to install or provide it. Do not assume a dotfiles layout or run install commands without approval.

Accept any reasonable user-provided installation path or command, such as a package manager, a virtual environment, a cloned repository, a container, or an existing `skillspector` binary on `PATH`. Explain that installation may fetch dependencies, clone/update repositories, or modify local bin/profile paths.

## Handling Results

Report concisely:

- scanned source
- SkillSpector version if shown
- score, severity, and recommendation
- findings that affect install/review decisions
- whether it is reasonable to proceed

If the scan fails because dependencies, Nix, network access, or credentials are missing, state the blocker and the exact command or input needed next. If the user declines installation, stop and report that SkillSpector could not be run.
