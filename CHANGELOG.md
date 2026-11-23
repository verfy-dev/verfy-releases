# Changelog

What changed in the Verfy CLI (`pip install verfy`) and the website. Newest first. Every CLI version is on [PyPI](https://pypi.org/project/verfy/#history) and as standalone builds on the [releases page](https://github.com/verfy-dev/verfy-releases/releases).

## 0.26.5 (2026-11-23)

- **The sandboxed editor terminal is no longer beta.** `verfy setup --sandbox-terminal on` (and the editor extension's "Open the terminal inside the sandbox") now checks that the sandbox is installed before it writes the editor's terminal profile: `srt` on macOS and Linux, and on Windows both `verfy` and `srt` inside WSL2. Before, a missing sandbox left VS Code, Cursor or Devin Desktop with a terminal that did not open, so the agent could run nothing. Now nothing is changed and Verfy says what to install. Turning it off always works.
- **Verfy Cloud's Slack buttons are no longer beta** on the website. A new test in Verfy Cloud checks the signature against the worked example on Slack's request-verification page, the `block_actions` request, the app manifest keys and every Block Kit limit.
- The root README has the website's headline, and the READMEs no longer call Verfy Cloud or the editor hooks beta.

## 0.26.4 (2026-11-23)

- **GitHub Copilot and Devin, checked against their hook references.** Their hooks are no longer marked beta. A new test, `tests/test_copilot_devin_spec.py`, sends each agent's documented input (Copilot's camelCase and PascalCase formats; Devin's `PreToolUse`) and accepts only the answers each reference describes. What it found is fixed:
  - **Copilot running Claude Code's hook.** Copilot also reads `.claude/settings.json` and runs `verfy hook pre-tool-use` from it, but reads only a top-level `permissionDecision`, so Verfy's Claude Code answer could be ignored there. Verfy now tells Copilot's call apart (it carries a `timestamp` and no transcript) and answers in Copilot's format.
  - **Devin shows why a call was blocked.** Besides exit code 2 and stderr, the reason now goes in `{"decision": "block", "reason": ...}` on stdout, where Devin's reference says it reads it.
  - **`COPILOT_HOME`** is honoured: `verfy hook install --copilot` writes to `$COPILOT_HOME/hooks/verfy.json` when it is set.
- `verfy hook install` no longer calls the Codex, Gemini CLI and Copilot hooks beta.

## 0.26.3 (2026-11-20)

- **The first minute.** `verfy` on its own now shows three steps (`verfy demo`, `verfy init`, `verfy doctor --live`) instead of forty commands; `verfy --help` still lists them all. `verfy demo` ends with the next step, and `verfy init` names `verfy doctor --live` among its next steps.
- **`verfy check` reads scripts too.** `verfy check python fix.py` reads `fix.py` the way the hook does, and shows every finding in it with the file and line, since a person asked.
- The README shows the script check in action.

## 0.26.2 (2026-11-20)

- **Cursor, checked against Cursor's hook reference.** The Cursor hook is no longer marked beta. A new test, `tests/test_cursor_spec.py`, sends every event Verfy registers with every field Cursor's reference lists and accepts only the answers each event takes. What it found is fixed:
  - **Files attached to a read** (`beforeReadFile`'s `attachments`) are checked like the file itself: attaching `~/.ssh/id_rsa` to a read of `notes.md` is denied.
  - **Cursor's Write tool** may send the file under `contents`; that key, and `file_content` and `new_content`, are now read as the file's text, so a secret or a script in it is checked before the write.
  - **MCP results with keys taken out** are answered as an object (`updated_mcp_tool_output`), as the reference says, also when the result arrived as a JSON string.
- **Hook input on Windows is read as UTF-8.** Python decoded the pipe with the system's code page (cp1251, cp1252, ...), which garbled a path with non-ASCII letters (`C:\Users\Жавохир\...`) and could make a hook fail into asking. The bytes are now decoded as UTF-8, with a byte-order mark or UTF-16 from PowerShell handled too. This was true of every agent's hook, Claude Code's included.
- **`verfy doctor --live` checks more of Cursor:** besides `ls` and `rm -rf ~`, a read of a project file must pass, and a read of `~/.ssh/id_rsa` and a write to Claude Code's settings must be stopped, sent as UTF-8 the way Cursor sends them.

## 0.26.1 (2026-11-20)

- **Fix: a script ending in an unfinished string with a backslash was let through unread.** Reading such a file stepped past its end, the script reader stopped, and the call kept only the rules' answer for the command (`python e.py`), so the `rm -rf ~` inside was not seen. A crafted file could use this to hide from 0.26.0's script reading. Found by the new fuzz test the same day.
- **What the script reader cannot parse now asks.** A file Verfy fails to read no longer drops the whole check: the other files of the call still count, and code the agent wrote that could not be read asks first (VFY-SCRIPT-002) instead of running unread.
- **Fuzzing.** `tests/fuzz_precheck.py` fuzzes the rule engine and the script reader with Atheris (`pip install atheris`, Linux, Python 3.11 or 3.12), and `tests/test_fuzz_smoke.py` runs the same targets on random inputs in every test run: no input may make them raise.
- The README shows the project's [OpenSSF Scorecard](https://scorecard.dev/viewer/?uri=github.com/verfy-dev/verfy).

## 0.26.0 (2026-11-20)

- **A script is read before it runs.** Until now the guard judged the command an agent ran, so `python fix.py` was checked as a command and `fix.py` itself was not; an agent could write the dangerous part into a file and run the file. Now, before such a command runs, Verfy reads the code it starts and checks it with the same rules:
  - scripts named on the command line, run by an interpreter (Python, Node.js, Deno, Bun, tsx, Ruby, Perl, PHP, bash, sh, zsh, PowerShell), run directly (`./x.sh`), sourced, a module of the project (`python -m pkg`), given inline (`python -c`, `node -e`) or in a here-document (`python - <<EOF`);
  - package scripts: `npm test`, `npm run build`, `npm install` (the project's install scripts), the same for yarn, pnpm and bun, and a Makefile's recipes for `make`;
  - code the agent wrote or changed in this session, when a command runs project code without naming it (a test runner such as pytest loading `conftest.py`, a build tool, an interpreter importing a module).
- **How a script is checked.** A shell script line by line, as commands. Other languages by what they hand to the shell (`os.system`, `subprocess`, `child_process`, `system`, backticks), what they delete (`shutil.rmtree`, `fs.rmSync`), the paths and URLs written in them (Verfy's own key named in pieces, a credential file in code that also uses the network, a denied host such as the cloud metadata address), and a script started from a script, three levels deep. A finding names the file and the line: `In fix.py, line 3: [VFY-SH-001] ...` (VFY-SCRIPT-001).
- **Who wrote it matters.** Code the agent wrote or changed in this session (a file tool, a shell redirect, `curl -o`, or any file changed since the session started) gets every finding. Code that was already in the project gets only what is blocked outright, so a project's own scripts do not ask each time they run; a cloned repository's `rm -rf ~` is still stopped. Code a runner only loads counts for what is blocked outright, so a script you approved once does not ask again on every later command.
- **What no one can read first is said so.** A script written by the same command that runs it, a download run right away (`curl -o x.sh ... && bash x.sh`) or a script too large to read asks first (VFY-SCRIPT-002). Code that decodes or downloads more code and runs it (`exec(base64.b64decode(...))`, `eval(atob(...))`) asks first (VFY-SCRIPT-003) and counts toward a session's escalation.
- Policy: `"scripts": {"read": "on" | "off"}`, on by default; a repository's policy can turn it on, not off. The files each session wrote are kept in `~/.verfy/scripts.json` for a day. The hook and the gateway both read scripts; a typical check takes a few milliseconds.
- **Limits.** Code that builds a command while it runs, reads it from elsewhere or loads modules the agent did not write is followed only as far as its text shows, and compiled programs are not read. A sandbox holds the rest (`verfy run --sandbox`; on Windows through WSL2).

## 0.25.0 (2026-11-20)

- **Receipts for any agent.** Any program can now sign a receipt for an action it took, not only a coding agent's tool calls: a refund, an email sent, a row deleted, a deploy. `verfy.Recorder(agent="refund-bot").record("refund", system="stripe", kind="payment", args={...})`, the `@rec.track(...)` decorator (plain and async functions; a raised exception is recorded as `error` and raised again) and the `with rec.action(...)` block write a `verfy.receipt/1` receipt with the same key and chain as the hook, so `verfy verify`, verfy.dev/verify and Verfy Cloud check it like any other. From any other language: `verfy record ACTION --system S --kind K --args JSON`.
  - Only salted hashes of the arguments and the result are kept unless you ask for the arguments (`include_args`, secrets redacted). Decimal, datetime, UUID, sets, dataclasses and pydantic models are recorded as data; integers beyond JavaScript's safe range become text so the Python and JavaScript engines sign the same bytes.
  - Anything Verfy Cloud would refuse is refused before anything is written, so one record can never stop later uploads. A record that fails after the action ran is logged and the program carries on. Threads and processes record at once without forking the chain; the key is created once even when two processes start together.
  - A record's `decision.policy_sha256` is `"none"`: no Verfy policy decided it.
- **Share links (Verfy Cloud).** `verfy share` (or `rec.share()`) uploads what is waiting and prints a link anyone can open to check one receipt: its signature, its place in the chain and when Verfy received it. `verfy share --agent` links to the device's whole record as numbers (receipts, kinds, outcomes, first and last), never one action's details. Links can expire (`--expires-days`) and be revoked in the dashboard. A receipt that carries its arguments cannot be shared.
- **Verfy's witness statement.** Each link and each answer of the new verification API carries a statement signed with Verfy Cloud's own Ed25519 key (`verfy.witness/1`): the receipt's hash, when it first reached Verfy and the state of the chain. `verfy witness verify proof.json` checks it offline with the key published at verfy.dev/.well-known/verfy-witness.json, and checks the receipt inside against the device key. A shared test vector keeps the Python and JavaScript signatures byte for byte the same.
- **The verification API (Verfy Cloud).** Insurers, auditors and marketplaces that check other teams' agents make a verifier key under Usage & API and call `GET /api/v1/verify/shares/{token}` or `POST /api/v1/verify/receipts` (does Verfy have this signed receipt, and since when). Every call is counted; the dashboard shows this month's receipts, records, links and checks.
- **Stop an action before it runs.** `Recorder(rules=[...])` checks rules before each tracked call: by kind, system or action name, with a limit on one action (`over`) or on today's total (`daily`), and `ask` or `deny`. A person approves an `ask` in Verfy Cloud's approval queue (`on_ask="team"`, which sees the rule and its message, never the arguments) or through your own function. A stopped call raises `verfy.ActionDenied`, never runs, and is recorded as `blocked` or `declined`. It fails closed: a missing amount counts as over the limit, an approver that cannot be reached declines, and daily totals are kept under a lock so two processes cannot both spend the last of a limit. Rules also come from `~/.verfy/policy.json` and the team policy (`"actions"`).
- **LangChain, the OpenAI Agents SDK and CrewAI.** `verfy.integrations.langchain.VerfyCallbackHandler`, `verfy.integrations.openai_agents.VerfyRunHooks` and `verfy.integrations.crewai.VerfyCrewHooks` record every tool call and check the rules before it, with nothing to change in the tools. Each is tested against the real framework (a CrewAI crew and an Agents SDK run with a model that makes no network call); none is a dependency. A call CrewAI's hook cannot check is blocked, because CrewAI runs the tool when a hook fails.
- **Node.js and the Vercel AI SDK.** `verfy-cli/js/verfy-node.mjs` records the same receipts from Node.js 18 and later; the tests check Node's receipts with Python and Python's with Node. `withVerfy(tools, rec)` (`verfy-ai-sdk.mjs`) records every tool call of a Vercel AI SDK agent, tested with a real `generateText` run. `node scripts/build-npm.mjs` builds both as the npm package `@verfy-dev/receipts` with types.
- **Deals two agents sign** (`verfy.deal/1`): `seller.offer(...)` and `buyer.accept(offer)` give each side a receipt in its own chain, the second naming the first, over the same terms; `verfy deal verify` checks both. **Payments tied to a mandate:** `rec.record_payment(amount, currency, payee=..., mandate=...)` keeps the amount and payee only as a salted hash and names the mandate it carried out by its hash (`verfy deal hash`). These receipts hold only references, so they upload without `--allow-args`.
- **Incident packs.** `verfy incident export --since --until [--agent] [--prove] [--attest]` writes every receipt in a window as one unbroken run of the chain, with the key, with `--prove` Verfy's public-log proof for each, and with `--attest` Verfy Cloud's signed statement of which of them it holds and since when (it receives only their hashes); `verfy incident verify` checks it all offline.
- **Verfy as the deal's witness (Verfy Cloud).** `POST /api/v1/verify/deals` with a verifier key checks a deal, says when each side's receipt reached Verfy and where it is in the public log, and signs that. `verfy deal verify --online` asks it and checks the signature.
- **Verfy's public log (Verfy Cloud).** Every receipt Verfy accepts becomes the next leaf of one append-only RFC 6962 Merkle tree of receipt hashes; its size and root are signed with the witness key at least daily. `verfy log prove` checks a receipt is in it; `verfy log watch` checks the newest head only added to the heads this machine saw before, so Verfy cannot quietly drop or change a receipt it accepted. New public endpoints: `/api/v1/log`, `/api/v1/log/proof`, `/api/v1/log/consistency`, `/api/v1/log/heads`.
- **Attacks no rule names yet.** Three layers beyond the rules. *Escalation:* a session that tried something Verfy blocked, or several suspicious things, needs approval for every risky action for an hour, and after more tries is blocked (VFY-AD-001, VFY-AD-002). *Novelty:* after a warm-up of 50 actions, a program that reaches the network or runs inline code, or a host, this machine's agents never used is asked about once (VFY-AD-003); nothing is learned from a session under escalation. *The rule feed:* `verfy rules update` takes rules Verfy publishes between releases, signed with its witness key; a feed rule can only ask or deny, the first signing key is remembered and an older feed is refused; machines enrolled with automatic upload refresh it daily. `verfy adaptive` shows what was learned. Policy: `"adaptive": {"escalate", "novelty", "warmup"}`, which a repository's policy can only tighten.
- **New rules** for shapes no earlier rule caught: code that only exists after decoding run by `bash -c`, `eval` or an interpreter (VFY-SH-041), data sent out in a DNS name or a web address built from a command's output (VFY-SH-039; `nslookup`, `dig`, `host` and `drill` now count as reaching the network), and a browser's saved passwords or cookies read (VFY-SH-040). Both engines check them on the shared fixtures. A custom rule can name `"kind": "shell"` to apply to commands only.
- **`verfy doctor --live`** runs each installed hook exactly as its agent does (Claude Code, Cursor, Codex, Gemini CLI, Copilot, Windsurf, Devin), with a harmless and a destructive call in that agent's format, in a throwaway Verfy folder: the command must start, answer in time, let `ls` pass and stop `rm -rf ~`.
- **`verfy demo` shows each rule on its own again.** Its project folder sat inside the demo's Verfy folder, which Verfy protects, so writing `notes.md` was blocked when it should run; the project now sits next to it. Escalation is off in the demo, and the demo says what it would have done.
- **The formats are written down** in [docs/spec](docs/spec/README.md): receipts, rules, witness statements, the log, deals and incident packs.

## 0.23.1 (2026-11-13)

- **Verfy moved to the [verfy-dev](https://github.com/verfy-dev) organization on GitHub.** The repositories are now `verfy-dev/verfy`, `verfy-dev/verfy-releases` and `verfy-dev/verfy-action`; the old addresses redirect. Every link, the install scripts, the release checks (build attestations and Sigstore identities), the Homebrew tap (`brew tap verfy-dev/verfy https://github.com/verfy-dev/verfy-releases`), the Scoop bucket, the pre-commit `repo:`, the Claude Code plugin marketplace (`claude plugin marketplace add verfy-dev/verfy-releases`) and the GitHub Action (`verfy-dev/verfy-action@v1`; the old name keeps working) use the new name. The container image is now `ghcr.io/verfy-dev/verfy`, and the MCP Registry name `io.github.verfy-dev/verfy`.
- This release is built and signed from the new repositories, so `gh attestation verify ... -R verfy-dev/verfy-releases` and the install scripts check it under the new name.

## 0.23.0 (2026-11-13)

- **`verfy mcp`: Verfy as an MCP server.** Add it to any agent (`{"command": "verfy", "args": ["mcp"]}`) and the agent can ask Verfy before it acts. Six read-only tools:
  - `check_line` and `check_tool_call`: would Verfy's rules allow, ask about or deny this terminal line or this tool call, and which rule decides;
  - `scan_mcp_config`: how the MCP servers in a config are started (the VFY-CFG rules), for a config you give or the ones on this computer;
  - `scan_tools`: warning signs in tool definitions, with a grade;
  - `agent_settings`: what `verfy posture` reports;
  - `recent_receipts`: the latest signed receipts and whether the chain verifies.

  It changes nothing, starts no server and makes no network call. Its answers are advice to the agent; the hook and the gateway are what stop a call. Its own tool definitions pass Verfy's scanner.
- **`verfy report` writes one HTML page about this computer:** which agents are guarded, risky agent settings, how MCP servers are started, what is locked, and the receipts (counts by verdict, the rules that fired most, receipts per day, the latest ones, and whether the chain verifies). It is a single file with no script and nothing loaded from outside, and it holds no secret. `--json` prints the same data.
- **pre-commit hooks.** In `.pre-commit-config.yaml`, add this repository at `rev: cli-v0.23.0` with `verfy-mcp-config` (a static check of the MCP configs in the commit: a package with no pinned version, `curl | sh`, plain http, a key in the file; it starts nothing) and, if you want it, `verfy-lock` (runs `verfy lock check`, which starts the servers).
- **A GitLab CI job,** [`examples/ci/gitlab-ci.yml`](https://github.com/verfy-dev/verfy-releases/blob/main/examples/ci/gitlab-ci.yml): the same lock check as the GitHub Action, for merge requests. It is run in its container image by this repository's CI, not yet on GitLab itself.
- **The research covers 99 MCP servers,** up from 46: every added server has at least 2,000 downloads a week on npm or PyPI.
- The JavaScript engine has `packageOf`: the package a server is started from, also behind a gateway. [verfy.dev/check](https://verfy.dev/check) uses it to show how often that server changed its tools.
- `verfy posture --json` says for each finding whether `--fix` can fix it (`fixable`).
- **In the MCP Registry:** `server.json` describes `verfy mcp` for the official registry (`io.github.verfy-dev/verfy`, the PyPI package started with `mcp`), and the PyPI description carries the ownership line it checks.
- **Homebrew, Scoop and a container image.** verfy-releases is also a Homebrew tap and a Scoop bucket, refreshed by each release build with that release's files and checksums, and each release publishes `ghcr.io/verfy-dev/verfy` with Node.js and uv for CI. A workflow installs all three on clean machines.

## 0.22.0 (2026-11-13)

- **`verfy posture` says when an agent's own sandbox is off, and `--fix` turns it on.** Verfy checks the command that starts a script the agent wrote, not what the script then does; the operating system sandbox each agent has holds that. Now:
  - **Claude Code** (`sandbox.enabled`, medium): the fix turns the sandbox on, keeps commands inside it (`allowUnsandboxedCommands: false`) and closes the credential folders, as `verfy sandbox sync` does. On native Windows, where Claude Code's sandbox does not run, posture says so and points to WSL2 instead of editing anything.
  - **Gemini CLI** (`security.toolSandboxing`, medium; the older `tools.sandbox` counts too): the fix sets it to true.
  - **Copilot in VS Code** (`chat.agent.sandbox.enabled`, low): the fix sets it to `"on"`, also in a settings file with comments, which is kept as it was.

  A sandbox turned on in the project's settings counts. The fix creates a settings file the agent has not written yet. Codex's `danger-full-access` was already reported; Cursor and Devin Desktop keep their sandbox setting in the app, where Verfy does not read it.

## 0.21.0 (2026-11-12)

- **`verfy setup --undo` takes Verfy out again.** It shows what it would change, and `--write` does it. Verfy's hook is taken out of every agent's file (Claude Code, Cursor, Codex CLI, Gemini CLI, Copilot, Devin, Windsurf), the MCP servers are taken out from behind the gateway, and the sandboxed terminal is removed. Everything else in those files stays, also what you changed after setup. A file that held nothing but Verfy's hook is removed. A backup of every changed file is kept, and your key, receipts and policy are not touched. `verfy setup --write` puts it all back.
  - A remote server is put back from the backup file that setup made. Without that file it stays behind the gateway and is named, so nothing is left broken.
  - Codex's `config.toml` is edited in place, with its comments kept.
  - `--agent`, `--project` and `--hooks-only` work as they do for setup. `verfy setup --system --undo --write` (as administrator, or with sudo) takes out the machine-wide hooks.
- **`verfy posture --fix` shows the edit that takes each finding away, and `--write` makes it.** Each fix is the smallest one: a key set or removed, or one entry taken out of a list. For example `bypassPermissions` becomes `default`, `disableAllHooks` is removed, and Codex's `approval_policy = "never"` becomes `"on-request"`. The old file is kept next to each changed one (`*.verfy-posture-backup`). `--min high` fixes only the high findings.
  - A JSON file with comments is not rewritten, because the comments would be lost. Codex's `config.toml` is edited line by line and only written when the edited file says exactly what was meant. In both cases the finding is shown for you to change by hand.
- **`verfy posture` reads GitHub Copilot's and Devin's settings too:**
  - Copilot in VS Code (`settings.json`, also with comments): `chat.tools.global.autoApprove`, and `chat.permissions.default` set to `autoApprove` or `autopilot`;
  - Copilot CLI (`~/.copilot/settings.json`): `disableAllHooks`;
  - Devin CLI (`config.json`): `permission_mode` set to `dangerous`, and a blanket `exec` allow rule.
- **The config rules run in the browser.** The JavaScript engine has `checkServer` and `checkConfig`: how an MCP server is launched (no pinned version, `curl | sh`, a privileged container, plain http, a key written into the config), the same rules as `verfy scan` (VFY-CFG-001 to 007). Both engines are tested against one fixture, `tests/fixtures/config.json`. [verfy.dev/check](https://verfy.dev/check) uses it: paste a config and see the findings, with nothing sent anywhere.
- **The editor extension** has two new commands: *Fix risky agent settings* (`verfy posture --fix`) and *Take Verfy out of every agent* (`verfy setup --undo`). Both show the changes first and make them only after you agree.
- **The research runs every week.** The workflow that records what popular MCP servers serve now runs every Monday, and each result says what its pins cover, so [verfy.dev/servers](https://verfy.dev/servers) can keep one history per server across runs.

## 0.20.0 (2026-11-11)

- **Start in a minute.** `verfy posture` shows what is risky in your agents before you change anything. A ready workflow, [`examples/ci/verfy.yml`](https://github.com/verfy-dev/verfy-releases/blob/main/examples/ci/verfy.yml), fails a pull request when an MCP tool changes; copy it to `.github/workflows/`. The [Verfy GitHub Action](https://github.com/verfy-dev/verfy-action) now installs 0.20.0 and has the `require-pinned` and `sarif` inputs that 0.19.0 announced but the published action did not have yet.
- **Machine-wide hooks: `verfy setup --system --write`** (run as administrator, or with sudo). It puts the Claude Code and Cursor hooks in the files an administrator deploys for the whole computer: `managed-settings.d/50-verfy.json` next to Claude Code's managed settings, and Cursor's enterprise `hooks.json`. An agent runs as you and cannot change those files, so even a script the agent writes and runs can no longer take Verfy's hook out. That was a known limit until now. Claude Code does not let user or project settings override a managed value. Verfy's own user-level hook is then taken out, so no call is checked twice; a backup of each file is kept. Verfy writes a drop-in file of its own, so an organisation's `managed-settings.json` is left as it is. Changes to these files are denied to the agent too.
- **Secrets in prompts are stopped before they are sent.** In Claude Code, Codex (UserPromptSubmit) and Cursor (beforeSubmitPrompt), a prompt that contains what looks like an API key, token or private key is blocked with the rule and a short reason, and gets a signed receipt (VFY-PROMPT-001). The secret itself is not shown or stored. Turn it off with `"prompt_secrets": "off"` in your policy.
- **Cursor: file writes, deletes and every other tool are checked.** Cursor's preToolUse hook now goes to Verfy too. File edits, which were the main gap in Cursor, get the same rules as Claude Code: for example, writing to `~/.bashrc` or deleting a hook file is denied. Terminal commands, file reads and MCP calls stay with their own hooks, so nothing is checked twice. MCP results are also cleaned of keys and tokens before the agent reads them (postToolUse), including those from remote servers that sign in with OAuth and so cannot go behind the gateway. `verfy setup --write` adds the new hooks to an existing install.
- **`verfy posture` shows risky settings in each agent's own config** and changes nothing. It covers:
  - Claude Code: `bypassPermissions`, `disableAllHooks`, a blanket `Bash` allow rule, `enableAllProjectMcpServers`;
  - Codex: `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`, also in profiles, and `hooks = false`;
  - Gemini CLI: hooks switched off or Verfy's hook disabled, `auto_edit`;
  - Cursor: a Verfy hook that does not fail closed.
  
  It exits 2 when something high is found. `verfy doctor` shows the summary, and counts a setting that switches Verfy's hook off as a problem.
- **`verfy setup` sets Verfy up for every coding agent on the machine at once.** It finds Claude Code, Cursor, Codex CLI, Gemini CLI, GitHub Copilot (CLI and VS Code), Devin Desktop (Windsurf) and Claude Desktop by their folders and commands, then shows what it would change. For each agent that has hooks, it adds Verfy's hook. It puts the MCP servers in that agent's own config behind the gateway, which gives them scan, lock, pre-check, receipts and secrets taken out of answers. `verfy setup --write` makes the changes and keeps a backup of every file. Run it again after installing another agent. `--agent NAME` picks agents, `--project` works on this folder's files, and `--hooks-only` leaves the MCP configs alone. A remote server that signs in with OAuth is left as it is, because the gateway cannot sign in yet. In a terminal, `verfy init` now offers the same setup for every agent it finds; `--hook` still means yes.
- **Verfy for VS Code, Cursor and Windsurf (beta): an editor extension.** Each release now has `verfy-vscode.vsix`. Install it in the editor with Extensions > ... > Install from VSIX. It finds the Verfy CLI, or offers to install it in a terminal you can see. It shows what `verfy setup` would change and runs it after you agree. It shows in the status bar whether the agents here are guarded, and runs `doctor` and `ledger show`. The extension changes no file itself and makes no network call.
- **The editor's terminal inside the sandbox (beta).** The editor itself cannot run inside the sandbox, but its AI agent runs commands in the editor's terminal. `verfy setup --sandbox-terminal on` (or the extension) makes that terminal open inside `verfy run --sandbox` in VS Code, Cursor and Windsurf, so the agent's commands can write only in the project and reach only the hosts your policy allows. On Windows it goes through WSL2. `off` takes it away. A settings file with comments is not rewritten; Verfy prints the profile to add by hand.
- **`verfy wrap` edits Codex CLI's `config.toml`** (Python 3.11 or newer) in place. Comments and everything else in the file stay as they were, and the result is read back and compared before anything is written. Remote servers in it are left for `verfy proxy --url`.
- **`verfy run --sandbox --agent -- codex`** (or `gemini`, `copilot`) gives that agent its own key, service and folder inside the sandbox. It used to get Claude Code's. A command that is none of these still gets Claude Code's, as before. The new hook files in a project are closed to sandboxed commands.
- `verfy lock files` also watches the new hook files, Copilot CLI's MCP config and Windsurf's global rules, and `verfy scan --discover` reads `~/.copilot/mcp-config.json`.
- **Hooks for Codex CLI, Gemini CLI, GitHub Copilot, Devin Desktop (Windsurf) and Devin CLI.** `verfy hook install --codex`, `--gemini`, `--copilot`, `--devin` or `--windsurf` (or `verfy setup`) adds `verfy hook codex|gemini|copilot|devin|windsurf`. It checks each tool call with the same rules as the Claude Code hook and signs a receipt tagged with the agent. Codex's `apply_patch` is checked file by file. Input a hook cannot read is never allowed. Changes to these hook files are denied to the agent, and changes to `~/.codex/config.toml` need approval. How far each one was checked:
  - **Gemini CLI:** run through Gemini CLI 0.68.0's own hook runner on Windows, where Gemini runs hooks through PowerShell (`scripts/e2e_gemini_hooks.mjs`). Where Verfy would ask, Gemini asks you.
  - **Codex CLI:** checked against Codex's source: the hook input, the output schema, `apply_patch` and MCP tool names, hooks on by default, and trust in `/hooks`. Codex does not support "ask" from a hook (it would run the tool), so there Verfy blocks and tells the agent to ask you.
  - **Copilot (CLI and VS Code), Devin Desktop and Devin CLI (beta):** written from their documentation; their code is closed. Copilot asks you where Verfy would ask, and treats that as deny where nobody can answer. Devin has no "ask", so Verfy blocks with exit code 2. Windsurf has been called Devin Desktop since 2 June 2026. `--windsurf` remains for older Windsurf releases, and `verfy setup` adds both. Devin also reads Claude Code's settings, so a Devin call that reaches `verfy hook pre-tool-use` gets Devin's answer, or is left to `verfy hook devin` when that is installed.
- `verfy doctor` shows these hooks too.
- `--pub` takes a public key that starts with `-`. argparse used to read it as a flag.

## 0.19.0 (2026-11-10)

- **`verfy.lock` pins the server's code, not only its tools.** For a server that npx, bunx, pnpm dlx, yarn dlx, uvx or pipx starts with an exact version, `verfy lock check --update` records the package and the registry's hash of that release: npm's `dist.integrity` (sha512), or on PyPI the sha256 of every file of the release. `verfy lock check` fails with exit 2 when the config starts another version, drops the version, or the registry now reports other files for the locked version, even when every tool definition is unchanged. **After you upgrade, run `verfy lock check --update` once** to record the hashes; until then the check passes and says they are missing.
- **`verfy lock pin`** gives every server started as `pkg` or `pkg@latest` an exact version: the one in `verfy.lock` when the lock has the package, else the registry's latest today. It prints the change; `--write` saves it with a backup.
- **`verfy lock check --require-pinned`** exits 1 when a server is started with no exact version. Without it, such a server is a warning.
- **`verfy lock check --sarif FILE`** also writes the result as SARIF 2.1.0, so GitHub code scanning shows each changed tool, package or agent file. The GitHub Action has `sarif` and `require-pinned` inputs.

## 0.18.0 (2026-11-09)

- **`verfy doctor` checks this machine's setup and changes nothing.** It shows the signing key, how many receipts the ledger holds and when the last one was written, whether the Claude Code and Cursor hooks are in place, and how many tools `verfy.lock` pins. It exits 1 when Claude Code is installed without the Verfy hook or a settings file is not valid JSON, so a removed hook can be caught by a script. A removed hook still cannot report itself; with Verfy Cloud, a device that stops sending receipts shows in Dashboard > Devices.
- **`verfy proxy --url` starts its bridge with this same Verfy.** It used to run the first `verfy` found on PATH, which could be another version or another program. It now uses the standalone build itself or the Python that runs the proxy.
- The package lists its author, and issues go to [verfy-releases](https://github.com/verfy-dev/verfy-releases/issues) everywhere.

## 0.17.0 (2026-11-06)

A second internal attack test found these. The [report](https://github.com/verfy-dev/verfy-releases/blob/main/docs/SECURITY_TEST_2026-11.md) has the numbers, including what a fresh list still got through. It was not an independent test.

- **A `verfy.policy.json` that came with a repository can no longer switch Verfy off.** It used to replace your policy and your team's, so a cloned repo could disable every rule. Now it can only make Verfy stricter: anything that would loosen it is left out, and `verfy check` says so. If the file is yours, read it and run `verfy policy trust`; if it changes, you trust it again. `verfy policy use --project` trusts what it writes. A team policy is never loosened by a file in a folder. **If you rely on a project policy that loosens something, run `verfy policy trust` after you upgrade.**
- **Rules that guard Verfy itself cannot be disabled**, by any policy.
- **The guard reads Windows commands.** `Get-Content ~\.ssh\id_rsa`, `%USERPROFILE%`, `$env:USERPROFILE`, `rd /s /q`, `powershell -c`, `cmd /c` and encoded commands were mostly allowed. Registry run keys, scheduled tasks, Defender settings and download tools now need a person.
- **Shell structure no longer hides a command:** `if`, `for`, functions, `alias`, variables, `$(...)`, brace expansion, `find -exec`, `flock`, `strace`, `chroot`, `parallel` and `script -c`. A key file is noticed wherever the command names it.
- **More ways to read a key or run code need a person:** inline code in more languages, `LD_PRELOAD` and `GIT_SSH_COMMAND`, printing stored tokens (`gh auth token`, `aws secretsmanager`, `kubectl get secrets`), browser and keychain files, tunnels, the Docker socket, installing from a URL, wiping a database, removing logs, and skipping git hooks.
- **A sensitive path is seen under any argument name**, also nested, and whatever its case, because macOS and Windows ignore case.
- **SQL and URLs:** comments inside SQL, `COPY ... TO PROGRAM`, `pg_read_file`, `INTO OUTFILE`; `gopher:` and `dict:` URLs, metadata behind `nip.io`, the AWS IPv6 and ECS metadata addresses. Private network addresses need a person; `localhost` does not.
- **MCP prompts are pinned like tools,** as `prompt:<name>` in `verfy.lock`, and a changed one is hidden. Their text is scanned when fetched, and resources that fail the scan are hidden. **After you upgrade, servers with prompts show new entries once:** review them and run `verfy lock check --update`.
- **The scanner sees through disguises:** invisible characters, Unicode tags, leet, spaced letters, base64, other languages, annotations and output schemas, parameter names, look-alike tool names, and a fixed email address.
- **Secrets:** unquoted settings such as `DB_PASSWORD=...`, passwords in URLs, bearer tokens, JWTs, and keys from AWS, GitLab, npm, PyPI, Supabase, SendGrid, Hugging Face, Azure and others are now recognised.
- **`verfy wrap` no longer prints the values in `env` and `headers`,** and writes `verfy`, not a path on your machine, into a config in the project.
- **`verfy update` on a standalone build downloads the install script and then runs it,** instead of piping it into a shell.
- **`verfy verify --ledger FILE` on an empty file says so and exits 1.** A hook input with no tool name needs a person. A `VERFY_HOME` elsewhere gets the same protection as `~/.verfy`. Bad input gives a short error, not a Python traceback.
- **The hook accepts a byte order mark,** which Windows PowerShell adds when its output encoding is UTF-8.

## 0.16.1 (2026-11-06)

- **A sandboxed command can no longer create a missing `verfy.lock`, policy, `.mcp.json`, agent settings or git hooks on Linux.** 0.16.0 closed these only when they already existed there, so a command could write a new `.mcp.json` that runs later, outside the sandbox. A review found this. They are now closed on every system whether they exist or not, with a test for each.
- **The `.claude` and `.cursor` folders are closed as a whole in the sandbox,** so a command cannot add a skill, a rule or a hook script there either.
- **Verfy reads an empty policy or lock as a missing one.** On Linux the runtime leaves an empty placeholder while a sandboxed command runs, and a hook outside it in the same folder has to keep working.
- **The installers say what a checksum shows:** that the download is whole, not who built it. `SECURITY.md` and verfy.dev/security show how to check a file on PyPI and a standalone build.

## 0.16.0 (2026-11-05)

An internal attack test found these, and the [report](https://github.com/verfy-dev/verfy-releases/blob/main/docs/SECURITY_TEST_2026-11.md) lists them all. It was not an independent test.

- **`$HOME` no longer walks around a path check.** `cat $HOME/.ssh/id_rsa` was allowed while `cat ~/.ssh/id_rsa` was stopped.
- **The cloud metadata address is caught however it is written:** as a decimal, in hex or octal, or inside IPv6.
- **`file:` URLs are read as files,** and a tool that runs commands is checked when it takes them as `args`.
- **More shell tricks are stopped or need a person:** `busybox`, a computed command name, a here-string into a shell, inline code that deletes, fetches or names a key, download then run, `crontab`, `systemctl enable`, git settings that run a command, a new git remote, a container given the host's disk, and `pipx run verfy` or `uvx verfy`.
- **The gateway forwards only what it could read.** A line that is not strict JSON and a `tools/call` without an id are dropped, and a malformed message no longer stops it.
- **The lock also covers `title`, `annotations` and `outputSchema`** when a server sends them, because clients act on annotations. **After you upgrade, tools that have these fields show as changed once:** review them with `verfy lock diff` and approve. Verfy Cloud accepts the new fields.
- **A sandboxed command cannot change `verfy.lock`, the policy, `.mcp.json`, Claude Code's or Cursor's settings, git hooks or `.git/config` in its own folder,** because those decide what runs later, outside the sandbox. On Linux this covers the files that exist when it starts.

## 0.15.0 (2026-11-05)

- **API keys in your environment no longer reach a sandboxed command.** `verfy run --sandbox` closed `~/.aws` but still handed over `AWS_SECRET_ACCESS_KEY`. Now only `PATH`, `HOME` and other basics go in, and `--allow-env NAME` adds one. With `--agent`, its own `ANTHROPIC_*` and `CLAUDE_*` variables go in too. If a sandboxed MCP server needs a key, name it with `--allow-env`.
- `SECURITY.md` now says how long a fix may take: 90 days, then an advisory either way.

## 0.14.0 (2026-11-05)

- **Remote servers on the older SSE transport.** `verfy proxy --url`, `verfy wrap`, `verfy lock check` and `verfy scan --live` now fall back to HTTP+SSE when a server refuses the first POST the way the MCP specification describes. The address the server names for its messages must be on the same server, so a key does not go anywhere else. OAuth sign-in is still not supported.
- **The installers check more.** With a signed-in GitHub CLI they verify the build attestation before installing, because a checksum from the same release shows only that the download is whole. They refuse a version that does not look like 1.2.3 before it reaches `rm -rf`, and the shell installer no longer writes a `VERFY_BIN_DIR` with unsafe characters to your shell profile.
- `SECURITY.md` and `/.well-known/security.txt` now give an email address next to GitHub's private reporting.

## 0.13.0 (2026-11-05)

- **Cursor hook (beta).** `verfy hook install --cursor --write` adds `verfy hook cursor` to `~/.cursor/hooks.json`, so Cursor's terminal commands, file reads and MCP calls are checked before they run and each gets a signed receipt. Verfy sets `failClosed`, because by default Cursor lets an action through when a hook crashes, and `.cursor/hooks.json` is now protected from the agent. A file read cannot wait for a person, so `ask` becomes `deny` there. Cursor's file edits and web search are not covered. This follows Cursor's documentation and has not yet been run inside Cursor itself.
- **The sandbox from Windows.** On native Windows, `verfy run --sandbox` now hands over to `verfy run` inside WSL2. It needs verfy and `srt` installed there; without them the command does not run (exit 3). Native Windows itself still has no sandbox runtime.
- **Inside WSL, the Windows user's keys are closed too.** The sandbox denied `~/.ssh` but not `/mnt/c/Users/you/.ssh`, which Linux can read. Every credential folder is now closed for each Windows user it finds.
- **Fewer false alarms in the scanner.** `summary` and `metadata` no longer count as side channels: they are ordinary required fields in Jira and HubSpot tools. On the newest release of the 34 servers from the October research (532 tools), the scanner now reports no high or critical findings and one medium; version 0.5.1 reported 163 high or critical.
- The sandbox workflow now also runs on Windows: the full end-to-end test inside real WSL2, and a new one from native Windows, with a control next to every refusal.

## 0.12.0 (2026-11-05)

- **`verfy run --sandbox -- COMMAND`.** Starts one command inside Anthropic's sandbox runtime (`srt`), a separate open source tool, with settings written from your Verfy policy: no network except `network.allow` and `--allow-host`, writes only in this folder and `--allow-write` paths, and no reading credential paths, `~/.verfy` or what `files.sensitive` lists. This covers what Claude Code's sandbox leaves out, because it can hold an MCP server: `verfy proxy --name fs -- verfy run --sandbox -- npx ...`. The command does not run if `srt` is missing or sits in a folder the command could write to. It works on macOS and Linux and refuses on native Windows. `srt` is a research preview and you install it yourself.
- **`--agent` runs the agent itself in it.** The Verfy hook then runs inside the sandbox too, so Verfy's folder stays open to it, and the guard, not the sandbox, keeps the agent out of the signing key. Credentials stay unreadable. It opens `api.anthropic.com` and Claude Code's own files.
- **Receipts say when a call ran in a sandbox:** `"sandbox": "srt"` from `verfy run`, or `"claude-code"` when Claude Code's sandbox is on in the settings the hook can see. It is what this machine states, not a proof. Older receipts have no such field and stay valid.
- A new workflow runs all of this on real Linux and macOS and checks what the system refuses, including a real MCP server, the hook signing from inside, and that a command never runs unsandboxed. The scanner and `verfy lock rollback` see through `verfy run`, so a sandboxed server is still checked and pinned.

## 0.11.0 (2026-11-05)

- **`verfy proxy --name NAME --url https://...`.** Puts a remote server behind the gateway in one command. `--bearer-env VAR` reads a bearer token from the environment, so it is not on the command line, in `verfy.lock`, in receipts or in logs, and Verfy refuses to send it over plain http. Scans and `verfy lock check` treat the entry as the remote server it is. OAuth is not supported yet.
- **The package in the lock.** `verfy lock check --update` writes the pinned package (`pkg@1.2.3`) next to the version the server reports, and `verfy lock rollback` goes back to that package, because a server's own version number is often not its package's.
- **`verfy scan` checks the sandbox.** With Claude Code on the machine, `--config` and `--discover` add what `verfy sandbox status` finds, without changing the exit code. Two new findings: the Docker socket is open (VFY-SBX-007), and allowed domains reach most of the internet, such as `*` or `*.com` (VFY-SBX-008).
- **Session rules follow the list more closely.** After outside text, `git push`, reading a key file and writing outside the project now wait for a person too. A request to a site on `network.allow` no longer does. Both engines share the new cases.

## 0.10.0 (2026-11-04)

- **Work with Claude Code's sandbox.** Verfy is not a sandbox, and the two cover different ground: Claude Code's sandbox wraps shell commands at the operating system level, so it holds a script the agent wrote, and it leaves out MCP servers, hooks and the built-in file and web tools, which Verfy watches. It is off by default, and when on it still lets commands read most of the machine. `verfy sandbox status` reports what the settings leave open, and `verfy sandbox sync --write` turns it on, closes the retry outside it, blocks credential paths and `~/.verfy` from reads, and allows the hosts in your Verfy policy. It adds and never removes, and keeps a backup. The sandbox does not run on native Windows. The guard denies `verfy sandbox sync --write` when the agent runs it.
- **Rules that follow the session.** A web page or a tool's answer can carry instructions for the agent. With `"session": {"after_outside_text": "ask"}` (or `deny`, which the `strict` template uses), once a session has read outside text, what can do harm from then on needs a person: the network, messages, payments and deletes (VFY-SESSION-001). Ordinary work such as editing files and running tests goes on. It looks only at the order of events, so no model judges the text, and it does not prove the agent obeyed anything. It is off by default. The hook keeps this per session in `~/.verfy/sessions` (the tool's name only, never its arguments); each gateway keeps it for its own connection, and the two do not share it. Both engines share the new cases.
- **`verfy lock rollback SERVER`.** When a tool changed, go back to a release that matches the lock instead of stopping work. It starts that release, compares its tools with `verfy.lock`, and only if they all match pins the version in your MCP config (`--write`, with a backup). The default is the version the server reported when it was locked, which `verfy lock check --update` now records; `--to VERSION` picks another. It works for servers started through npx, bunx, uvx and pipx. A remote server cannot be rolled back: it runs whatever its owner deployed. The guard denies `verfy lock rollback --write` when the agent runs it.
- **The gateway guards remote MCP servers too.** `verfy wrap` now puts a remote server (a `url` in the config) behind the gateway, through a new `verfy bridge` that speaks stdio on one side and Streamable HTTP on the other, so rules, the lock, redaction and receipts apply to it as they do to a local server. Headers move to the server's `env`, so a key is not on a command line; `${VAR}` is filled in when the bridge starts. Verfy does not follow redirects. Not covered yet: the older SSE transport (`verfy wrap` leaves those servers alone and says so), servers that sign in with OAuth in your MCP client (the bridge has only the headers in the config), and messages a server sends outside an answer to a request.

## 0.9.0 (2026-11-04)

- **Salted hashes in receipts.** Receipts hold a hash of a call's arguments and result, not the values, and that is what reaches Verfy Cloud. A plain SHA-256 of a short argument such as `{"command": "ls"}` can be guessed by hashing likely values, so anyone with the database could have read it back. From this version the hash is SHA-256 of the value together with a secret salt that stays in `~/.verfy/key.json`, so it says nothing without that file. The format is unchanged (`args_sha256` and `result_sha256`, still `sha256:…`), signatures and chains work as before, and a key file without a salt gets one the first time it signs. Receipts written before this version keep their plain hashes. Hashes sent to the approval queue are salted too.
- `verfy ledger hash JSON` prints the hash this machine records for a value, so you can still match known arguments to a receipt. Someone without your `key.json` cannot.

## 0.8.1 (2026-11-04)

- The website moved to https://verfy.dev. `verfy update`, the installers, the package links and the docs use it. The old address leads there, and Verfy Cloud's API still answers at it, so devices enrolled there keep working.

## 0.8.0 (2026-11-01)

- **Set up a machine with one command.** `verfy init --url … --code …` creates the signing key and policy as before, prints one line about the MCP servers in your Claude Code, Cursor and Claude Desktop configs (it reads the files and starts nothing), offers to add the Claude Code hook when Claude Code is installed and you are in a terminal (`--hook` / `--no-hook`; never added without asking), and connects the machine to Verfy Cloud. Until now this took `verfy init`, `verfy hook install --write`, `verfy team enroll` and a `verfy sync` after every session.
- **Receipts upload on their own.** On a device enrolled with this version, after the hook or the gateway writes a receipt, Verfy starts `verfy sync` as a separate background process, at most every five minutes; the hook itself still never goes online, and a failed upload never affects the guard. What happened goes to `~/.verfy/sync.log`. `verfy team auto-sync off` goes back to uploading only with `verfy sync`; devices enrolled before this version stay that way until `verfy team auto-sync on`. `verfy team status` shows which.
- The guard denies `verfy team enroll`, `verfy init` with `--url` or `--code`, and `verfy team auto-sync off` when the agent runs them, so an agent cannot send this device's receipts to another Verfy Cloud or stop them from reaching your team. Five new cases, shared by both engines.

## 0.7.0 (2026-10-28)

- **Remote MCP servers.** `verfy lock check` and `verfy scan --live` now read the tools of remote servers (a `url` in the config) over Streamable HTTP instead of skipping them, so a CI check covers hosted servers too. Headers come from the config: `headers` (Claude Code, Cursor, VS Code and others) or Codex CLI's `http_headers`, `env_http_headers` and `bearer_token_env_var`, with `${VAR}` and `${VAR:-default}` filled in from the environment, so a key can come from a CI secret. A missing variable fails the check and names the variable, never a value. Verfy does not follow redirects, so a key only goes to the address in the config. Servers that only speak the older SSE transport are reported, not supported yet. The MCP gateway still runs in front of stdio servers only.
- Tested with a local fake server (sessions, server-sent events, pages of tools, a refused key, a redirect, a missing variable) and by hand against two public remote servers, DeepWiki and Context7.
- Fixed: inside GitHub Actions, `verfy lock check --json` printed annotations after the JSON, so the output did not parse. With `--json` there are no annotations now; the step summary is still written.
- The GitHub Action works again now that the source repository is public: `uses: verfy-dev/verfy@cli-v0.7.0`. It checks remote servers too.

## 0.6.3 (2026-10-26)

- **Security: the agent can no longer read Verfy's signing key or device token.** Up to 0.6.2 an agent could read `~/.verfy/key.json` (for example with `cat` or Claude Code's Read tool), and with it sign receipts of its own, or read the device token in `~/.verfy/team.json`. Now reading either file, listing, searching or copying `~/.verfy`, or naming the folder and one of those files in one command is denied (VFY-SELF-006), including `$HOME`, `%USERPROFILE%`, quoted, globbed and `cd`-then-read forms; archiving, copying or searching a folder that holds it, such as the home folder, or looking for files with those names needs approval (VFY-SELF-007). Both engines (Python and JavaScript) share the 26 new test cases. A program the agent writes and runs can still read the file: see [SECURITY_LIMITATIONS.md](docs/SECURITY_LIMITATIONS.md). If an agent may have read your key, create a new one yourself with `verfy init --force` (it starts a new receipt chain) and, with Verfy Cloud, revoke the device and enroll it again. Found while reviewing a contribution.
- The end-to-end test also checks that the hook denies reading the signing key with `cat` and with the Read tool.
- Website (27 October): Verfy Advisories have `VERFY-YYYY-NNNN` ids. The old ids (such as ATLS-2025-0001) stay in `aliases`, and links to them lead to the new pages.
- **[verfy-releases](https://github.com/verfy-dev/verfy-releases) is the home for installing Verfy**: the standalone builds, the Claude Code plugin (`claude plugin marketplace add verfy-dev/verfy-releases`, then `claude plugin install verfy@verfy`), the security policy (report vulnerabilities and bypasses there), the advisories, the research and this changelog. The source is in [verfy-dev/verfy](https://github.com/verfy-dev/verfy), under the MIT license. The GitHub Action is replaced by two steps, `pip install "verfy==0.6.3"` and `verfy lock check`, with the same annotations and step summary.

## 0.6.2 (2026-10-26)

- **Verfy Registry sends only pins.** `verfy team registry report` now sends only the SHA-256 pin of each locked tool definition, no longer the local server and tool names, which can be private. Verfy Cloud stores only the pins and when each was reported, and no longer has a place for names. Owners and admins can delete all of their team's pins in Dashboard → Locks, and a pin not reported for 180 days stops counting and is deleted. What is sent and what is not: https://verfy.dev/docs#registry
- **End-to-end test before every release.** The built wheel is installed on clean Linux, macOS and Windows runners and `scripts/e2e.py` runs `verfy init`, `lock files`, `lock check` (a changed CLAUDE.md and a rug pull must fail it), Snyk and Cisco imports, the Claude Code hook and the Claude Code plugin. Nothing goes to PyPI unless it passes; it also runs on every push.
- The GitHub Action example in the README pins this release (`@cli-v0.6.2`). `python scripts/bump.py X.Y.Z` sets the version in every file that carries it, and a test fails when one of them falls behind.

## 0.6.1 (2026-10-26)

- **Verfy Registry** (Verfy Cloud): `verfy team registry report` shares the pins in your `verfy.lock` (server name, tool name and SHA-256; never definitions), and `verfy team registry lookup` shows how many teams reported each pin, including a changed definition you have not approved yet. A change that few other teams have seen can be very new, or served only to you. Counts are shown only when at least 3 organizations reported a pin.
- Verfy Cloud (website): Dashboard → Reports, a compliance summary for a date range (checked calls by verdict, the rules behind denied and asked calls, lock and approval decisions, policy versions, devices, audit activity) with the SOC 2 and ISO/IEC 42001 controls it relates to. It points an auditor to the evidence; it does not certify anything.

## 0.6.0 (2026-10-26)

- **Lock explains what changed.** `verfy lock check`, `lock diff`, `lock approve` and `lock check --update` now say in words what changed in a tool and how risky it looks (low, medium or high): a new sentence that orders the model to send data somewhere, a new link, a new or newly required parameter, a new hidden-instruction pattern, or only a rewording. The GitHub annotations and step summary carry the same explanation. It is deterministic; no model is involved. On the 342 real tool changes from our October research it rated none high.
- **Lock the files an agent loads, not only MCP tools.** `verfy lock files` pins CLAUDE.md, AGENTS.md, GEMINI.md, Cursor and Windsurf rules, `.claude` skills, agents, commands and hook settings, and MCP configs in the `files` section of `verfy.lock`; `verfy lock check` then fails CI when one changes without a reviewed lock update. `verfy lock files --user` does the same for user-level instructions, skills and installed Claude Code plugins on your machine (`~/.verfy/agent-files.lock`).
- **Claude Code plugin.** This repository is now a plugin marketplace: `claude plugin marketplace add verfy-dev/verfy` and `claude plugin install verfy@verfy` install the guard hook and a skill for checking locks. It needs the CLI (`pip install verfy`).
- **More agents.** `verfy scan --discover` also reads Codex CLI (`~/.codex/config.toml`, Python 3.11+), Gemini CLI (`.gemini/settings.json`), VS Code (`.vscode/mcp.json` and the user `mcp.json`) and Windsurf (`~/.codeium/windsurf/mcp_config.json`).
- **Import other scanners' findings.** `verfy import FILE` reads Snyk Agent Scan (`--json`) and Cisco MCP Scanner (`--format raw`) output. With `--save`, the Verfy gateway hides the tools they rate high and denies calls to them (VFY-IMP-001).
- Self-protection: an agent may not run `verfy lock files --update` or `verfy import --save`, or edit `~/.verfy/agent-files.lock`, `~/.verfy/imported/` or the installed Verfy plugin.

## 0.5.5 (2026-10-25)

- The hosted service has one name, Verfy Cloud: `verfy team` and `verfy sync` say so in their help. The commands are unchanged.
- This repository is now the MIT CLI only; the website and the dashboard are developed separately as Verfy Cloud. The CLI is MIT and will stay MIT.
- Verfy Advisories are open data in [`advisories/`](https://github.com/verfy-dev/verfy-releases/tree/main/advisories): anyone can add a public, sourced advisory by pull request, checked by `node advisories/validate.mjs`.
- Contributors sign the [CLA](https://github.com/verfy-dev/verfy-releases/blob/main/CLA.md) once, by commenting on their first pull request.
- There is no 0.5.4: that tag was never published, because the package metadata still said 0.5.3 and PyPI refused it. A test and the release workflow now check that both version numbers match.

## 0.5.3 (2026-10-24)

- One tag now does the whole release in one workflow: tests, PyPI with attestations, then the GitHub release from this changelog with the same files, SHA256SUMS and Sigstore signatures. Only the newest version is marked "Latest".
- PyPI page links: Repository, Changelog and Releases.
- Verfy Cloud (website): Slack and Telegram notifications for calls that wait for approval, changed tool definitions, denied calls and devices that stop uploading receipts for a day (Dashboard → Notifications).

## 0.5.2 (2026-10-24)

Scanner fixes, found by scanning the newest releases of 34 popular MCP servers ([the research](https://github.com/verfy-dev/verfy-releases/blob/main/docs/research/2026-10-mcp-tool-changes.md)). Version 0.5.1 raised 163 high or critical findings there, all false alarms; 0.5.2 raises none.

- A tool that mentions another tool on the same server is no longer flagged as tool shadowing.
- A match right after a negation ("Do not include API keys") is skipped. Before, this hid tools from Context7, Apify and Sentry behind the gateway.
- "tokens" and "conversation" only count in their sensitive senses (access tokens, the conversation history).
- "silently" no longer counts as "secretly"; mentioning a file such as `.env` is medium instead of high.

## 0.5.1 (2026-10-24)

Fixes found while scanning public `.mcp.json` files and recording the demo video.

- `verfy lock check` and the gateway no longer crash with a traceback when a server's command cannot be started (for example an empty command). They report it and exit 3 (lock check) or 126 (gateway).
- Config scan: an unpinned package launched through `cmd /c` or `sh -c` is now reported.
- Config scan: `npx` of a package declared in the `package.json` next to the config is no longer reported, because the lockfile pins it.
- Config scan: VFY-CFG-007 (a remote server without credentials in the config) is now `info`. The client signs in with OAuth when the server asks, so a missing header is not a weakness.

## 0.5.0 (2026-10-24)

- Approval queue for teams. With `"on_ask": "team"`, a gateway call that needs approval waits in Dashboard → Approvals until an owner or admin decides, for up to `approval_timeout` seconds. Only the SHA-256 of the arguments leaves the machine.

## 0.4.0 (2026-10-24)

- The gateway replaces API keys, tokens and private keys in MCP tool results with `[REDACTED:<rule>]` before the agent reads them. Turn it off with `"redact_output": false`.
- Policy templates: `verfy policy use strict | read-only | ci`, and `verfy init --template`.
- Fixed: redaction of stored arguments hid only the first secret of each kind.
- Website: Next.js 16.4.3, which fixes two critical advisories.

## 0.3.0 (2026-10-22)

- Self-protection: the agent cannot switch Verfy off with its own tools (VFY-SELF-001 to 005).
- `verfy update`, and a choice between manual and automatic updates at `verfy init`.
- Windows paths are compared without regard to case, in the `/c/...` form.
- One-line installers that need no Python (standalone builds for Windows, macOS and Linux, checked against SHA256SUMS).

## 0.2.0 (2026-10-21)

- First release on PyPI as `verfy`: the Claude Code hook, the MCP gateway, `verfy scan`, `verfy lock` (including `lock check` and the GitHub Action for CI), signed receipts and SCITT export.

## Before PyPI (2026-10-14 to 2026-10-20)

- 2026-10-18: the website leads with Verfy Lock, with a rug-pull demo you can run in the browser.
- 2026-10-15: the project got its name, Verfy; Google and GitHub sign-in.
- 2026-10-14: first version of the guard, scanner, lock, signed receipts and the Team web app.
