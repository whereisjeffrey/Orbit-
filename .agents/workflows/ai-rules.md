# TalkSwitch AI Working Rules

## 1. No Over-Promising

- Never say something "will work 100%" unless there are zero variables outside of code control.
- If iOS device state, Settings, provisioning, or hardware is involved, always say **"this should work, but if it doesn't, here's what to check"** — never a guarantee.
- If a fix depends on the user rebuilding and reinstalling, say that explicitly and acknowledge that iOS can behave unexpectedly even after a clean install.

## 2. Version Restores — Do It Right

- When asked to restore a previous version, **do not reconstruct from memory or assumptions**.
- First check `git log` for a commit that matches the known-good state.
- If git is not available, **stop and say so**, and ask the user to confirm the exact state before proceeding.
- Never say "I've restored it" unless the file content has been verified to match the known-good state exactly — not just the parts I edited, but the whole file.

## 3. Scope Discipline

- When making a fix, touch **only the lines required**. Do not reorganize, rename, or restructure anything adjacent to the fix.
- If a fix requires broader changes, **explain why first** and get confirmation before proceeding.
- Never introduce new features or experiments while trying to fix a bug.

## 4. Honest Status Reporting

- If a `swiftc -parse` passes but a full Xcode build might still fail, say so. Parser checks are not the same as full compilation.
- If a fix involves device-level behavior (iOS Settings, permissions, keyboard registration), be explicit that these are outside code control and list the manual steps required.
- If something goes wrong after a change, **own it** — do not suggest it was a pre-existing issue unless there is clear evidence.

## 5. Stop and Ask First

- If the user asks for a restore and there is **any ambiguity** about what the prior state was, stop and ask before writing any code.
- If a change might affect unexpected parts of the app (other targets, other files, OS behavior), flag it before making the change.
