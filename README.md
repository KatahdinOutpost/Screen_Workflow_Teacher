# Screen Workflow Teacher

A desktop workflow recorder and replay assistant for repeatable productivity tasks.

This MVP lets a user:

- record clicks and keystrokes
- capture active window context
- capture a screenshot around each click
- optionally OCR the clicked region
- convert the recording into editable workflow steps
- replay the workflow with pause/stop safety controls
- save workflows as JSON for GitHub-friendly versioning

## Intended use

This project is intended for accessibility support, productivity workflows, QA testing, and repeatable administrative tasks.

It is not intended for cheating in games, bypassing anti-cheat systems, bypassing software protections, or automating activity where you do not have permission.

## Current status

This is an MVP starter repo. It focuses on a clean architecture and a usable first version, not a polished commercial product.


## Quick start

### Windows

Double-click `run.bat`, or run:

```powershell
py -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
$env:PYTHONPATH="src"
python -m overlay_teacher.app
```

### macOS/Linux

```bash
./run.sh
```

## Profiles

Profiles let you keep separate instructions, variables, allowed apps, OCR settings, and workflow folders for each scenario. Example: one profile for a dealer portal, another for CRM updates, another for QA testing.

## Requirements

- Windows, macOS, or Linux desktop
- Python 3.10+
- Optional: Tesseract OCR installed locally if OCR is enabled

## Setup

```bash
python -m venv .venv
source .venv/bin/activate  # macOS/Linux
# .venv\Scripts\activate  # Windows PowerShell
pip install -r requirements.txt
```

For OCR:

- Install Tesseract from your OS package manager or Windows installer.
- Make sure `tesseract` is available on your PATH.

## Run

```bash
python -m overlay_teacher.app
```

## Safety controls

- `Esc` stops replay.
- Replay runs one step at a time with a small delay.
- Coordinates are used as a fallback only.
- Workflows are plain JSON and can be reviewed before running.

## Roadmap

1. Add Windows UI Automation target detection.
2. Add visual step editor UI.
3. Add confidence scores before each action.
4. Add dry-run mode.
5. Add app allowlist.
6. Add variable detection for typed values.
7. Add Playwright integration for browser workflows.

## Profile support

This version supports separate profiles for different scenarios or apps.

A profile can store:

- scenario-specific instructions
- app/window allowlist
- OCR preference
- confirmation-before-replay preference
- step delay
- variables such as `customer_name`, `vin`, or `stock_number`
- its own workflow folder

Profile data is stored locally:

```text
profiles/<ProfileName>/profile.json
profiles/<ProfileName>/workflows/<WorkflowName>/workflow.json
```

Use profiles when you want different behavior for different contexts, such as:

- Dealer Portal workflows
- CRM updates
- report generation
- QA testing
- accessibility helpers

See `docs/profiles.md` and `examples/profiles/dealer-portal-profile.json`.

## Target detection

Replay is no longer limited to raw coordinates. Click steps are resolved using:

1. Windows UI Automation, when available
2. OCR text matching
3. Screenshot region similarity
4. Saved coordinates as the last fallback

See `docs/target-detection.md` for details.

## Completed-app additions

This build adds the features needed to make the app usable across different scenarios:

- profile-specific instructions and variables
- profile allowlist enforcement
- editable workflow JSON inside the app
- preview / dry-run mode
- target detection during replay
- wait-before and verify-after conditions
- JSONL replay logs
- emergency stop with `Esc`

See:

- `docs/workflow-json.md`
- `docs/target-detection.md`
- `docs/completion-roadmap.md`

## Production build helpers

This package includes a point-and-click step editor and Windows build assets.

- `build/build_windows.ps1` builds a PyInstaller Windows executable.
- `installer/ScreenWorkflowTeacher.iss` is an Inno Setup installer script.
- `docs/visual-step-editor.md` explains the step editor.
- `docs/installer.md` explains executable and installer creation.

Use the visual editor inside the app with **Open Point-and-Click Step Editor** after opening or recording a workflow.

## Xbox 360 controller workflows

This build supports controller-based profiles. Enable **Record/replay Xbox 360 controller input** in a profile, select the target window, then record. The recorder stores button, axis, D-pad, and timing data. Replay uses a virtual Xbox 360 controller on Windows through `vgamepad`; install ViGEmBus if your system does not already have the virtual gamepad driver.

See `docs/controller-input.md` for setup and workflow JSON examples.

## LM Studio Action Assist

Profiles can optionally use a local LM Studio model to read OCR/screen context and propose or run the next action inside the assigned target window. See `docs/lmstudio-action-assist.md`.

Keep approval enabled and `Max AI actions per run` set to `1` while testing.

## Launcher troubleshooting

If `run.bat` closes immediately, use this updated package. The launcher now keeps the window open and writes details to `launcher.log`.

Common fixes:

1. Install Python 3.11+ from python.org and check **Add Python to PATH**.
2. Run from an extracted folder, not directly inside the ZIP.
3. If optional controller replay dependencies fail, the app can still open. Install ViGEmBus before using virtual Xbox 360 replay through `vgamepad`.
4. Open `launcher.log` and look for the first line that starts with `ERROR:`.

## Controller Profiles

Profiles now include controller-specific settings for Xbox 360 style workflows. You can disable noisy axes, tune deadzones, and replay button-down events as timed taps. See `docs/controller-profiles.md`.


## Window-scoped triggers

This build supports conditional trigger steps scoped to the selected target window. Trigger types include `pixel_color`, `timer_elapsed`, `screen_contains`, `all`, and `any`. See `docs/window-pixel-triggers.md` and `examples/pixel-trigger-workflow.json`.

Pixel coordinates are window-relative, not full-screen absolute.


## Desktop UI Redesign Build

This package now uses a desktop-first sidebar layout designed for non-technical users. The old tab-heavy interface has been replaced with pages for Home, First Run, My Workflows, Create Workflow, Workflow Editor, Run Workflow, Assistant, Diagnostics, Settings, and Advanced Mode.

The UI uses the Toyota palette requested for the mockup: Toyota Red `#EB0A1E`, White `#FFFFFF`, Black `#000000`, and Gray `#58595B`.

Raw workflow JSON is now grouped under **Advanced Mode**. Normal users should use the visual Workflow Editor and Step Builder. See `docs/desktop-ui-redesign.md`.

## Legacy UI note

Earlier builds used a tabbed layout with a separate Assistant tab. This desktop redesign keeps the same Assistant and LM Studio capabilities, but presents them through sidebar pages and plain-language labels.

## Profile-specific Assistant chat memory

The Assistant page can remember conversations per workspace across restarts. Chat memory is saved locally in each profile folder as `assistant_chat_history.json`. User messages are color-coded separately from assistant responses, and the Assistant page includes a clear-memory button.

## Adaptive Logic Build

This package adds an adaptive logic builder and behavior-tree engine for adaptive workflows.

New capabilities:

- Build adaptive logic from plain-English prompts using LM Studio.
- Use behavior-tree nodes: `sequence`, `selector`, `condition`, `action`, `retry`, `wait`, `ask_user`, and `stop`.
- Combine OCR, pixel, timer, and normal workflow actions.
- Preview logic trees in dry-run mode before adding them to a workflow.
- Add generated logic as a normal workflow step with `action: "logic"`.

See `docs/adaptive-logic.md` and `examples/adaptive-logic-workflow.json`.
