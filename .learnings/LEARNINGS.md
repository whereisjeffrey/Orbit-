# Learnings Log

## [LRN-20260321-001] correction

**Logged**: 2026-03-21T08:00:00Z
**Priority**: critical
**Status**: pending
**Area**: process

### Summary
Stop declaring fixes before verifying them. Map ALL variables before attempting ANY fix.

### Details
Spent 8+ iterations trying to fix Portuguese language detection in WhisperKit. Each time, identified ONE possible cause, "fixed" it, told user it should work, and it didn't. The actual root cause (warm-up crash preventing WhisperKit from loading at all) was variable #2 or #3 on a list that should have been created BEFORE the first fix attempt.

Pattern: diagnose one thing → claim it's fixed → user tests → fails → diagnose next thing → repeat. This is wasteful, frustrating, and erodes trust.

### Correct Approach
1. **Enumerate ALL variables** that could cause the problem before touching code
2. **Add diagnostic logging** for every variable in one pass
3. **Ask user to test ONCE** and report the logs
4. **Read the logs** to identify the actual root cause
5. **Fix the root cause** (not a guess)
6. **Say "this should address it based on the logs" not "it's fixed"**
7. **Verify** with the user before moving on

### Suggested Action
Follow the Engineering Protocol below for every non-trivial bug. Never say "it's fixed" — say "I've made a change that addresses [specific log evidence]. Let's verify."

### Metadata
- Source: user_feedback
- Tags: process, debugging, trust, communication
- Pattern-Key: process.premature_fix_declaration
- Recurrence-Count: 1
- First-Seen: 2026-03-21

---

## [LRN-20260321-002] best_practice

**Logged**: 2026-03-21T08:00:00Z
**Priority**: critical
**Status**: pending
**Area**: backend

### Summary
WhisperKit warm-up transcription of silence crashes on base model, silently disabling the entire pipeline.

### Details
WhisperKit `base` model initialized successfully (9.4s) but `pipe.transcribe(audioArray: silentSamples)` with 16000 zero-valued floats (1 second of silence) threw an exception. Because `sharedWhisperReady` was set AFTER the warm-up in the same try block, the catch set it to `false`, causing every subsequent recording to fall back to Whisper API. User tested 8+ times thinking WhisperKit was running — it never was.

### Suggested Action
Always set critical state (ready flags) immediately after the essential step succeeds. Wrap optional follow-up steps (warm-up) in their own do/catch so they can't take down the main pipeline.

### Metadata
- Source: error
- Related Files: TranslateHelper/DictateViewController.swift
- Tags: whisperkit, initialization, silent-failure
- Pattern-Key: init.warmup_crash_disables_pipeline
- See Also: LRN-20260320-001

---

## [LRN-20260320-001] best_practice

**Logged**: 2026-03-20T17:30:00Z
**Priority**: critical
**Status**: resolved
**Area**: backend

### Summary
WhisperKit `base` model is too slow for iPhone 13 — use `tiny` model and warm up on app launch.

### Details
UPDATE 2026-03-21: `tiny` model cannot handle Portuguese at all — produces garbage for non-English. `base` is the minimum viable model for multilingual. The speed issue was actually caused by the warm-up crash (see LRN-20260321-002) which forced API fallback, not by the model itself being slow.

### Metadata
- Source: error
- Related Files: TranslateHelper/DictateViewController.swift, TranslateHelper/SceneDelegate.swift
- Tags: whisperkit, performance, on-device-ml
- Pattern-Key: perf.whisperkit_model_selection

---

## [LRN-20260320-002] correction

**Logged**: 2026-03-20T17:30:00Z
**Priority**: high
**Status**: resolved
**Area**: backend

### Summary
AVAudioConverter buffer format mismatch crashes when converting to int16 interleaved in audio tap callback.

### Suggested Action
Never use AVAudioConverter with pcmFormatInt16 interleaved in audio tap callbacks. For Whisper, just send native format — it handles any sample rate.

### Metadata
- Source: error
- Related Files: TranslateHelper/DictateViewController.swift
- Tags: avfoundation, audio, crash
- Pattern-Key: audio.converter_tap_crash

---

## [LRN-20260320-003] best_practice

**Logged**: 2026-03-20T17:30:00Z
**Priority**: high
**Status**: resolved
**Area**: backend

### Summary
Whisper API hallucinates Korean text when receiving corrupted or silent audio.

### Metadata
- Source: error
- Related Files: TranslateHelper/DictateViewController.swift
- Tags: whisper, hallucination, audio
- Pattern-Key: whisper.korean_hallucination

---

## [LRN-20260320-004] correction

**Logged**: 2026-03-20T17:30:00Z
**Priority**: high
**Status**: resolved
**Area**: frontend

### Summary
Keyboard translation pipeline was hardcoded to Spanish in multiple places despite supporting language selection.

### Metadata
- Source: user_feedback
- Related Files: TranslateHelperKeyboard/KeyboardViewController.swift, TranslateHelperKeyboard/Services/TalkSwitchAPI.swift
- Tags: localization, hardcoded, spanish
- Pattern-Key: i18n.hardcoded_language

---
