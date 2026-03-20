# Learnings Log

## [LRN-20260320-001] best_practice

**Logged**: 2026-03-20T17:30:00Z
**Priority**: critical
**Status**: resolved
**Area**: backend

### Summary
WhisperKit `base` model is too slow for iPhone 13 — use `tiny` model and warm up on app launch.

### Details
WhisperKit `openai_whisper-base` took 35+ seconds to load and transcribe on iPhone 13. The model re-loads internal components (encoder, decoder, tokenizer) on first transcription even if `WhisperKit()` init completed. Switching to `openai_whisper-tiny` and running a warm-up transcription (1 second of silence) at app startup forces all components into memory. Result: transcription completes in 1-3 seconds.

### Suggested Action
Always use `tiny` for mobile. Always warm up with a silent transcription after init. Pre-load at app startup (SceneDelegate), not on viewDidLoad.

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

### Details
Attempted to downsample 48kHz stereo to 16kHz mono int16 using AVAudioConverter inside an installTap callback. The converter produced buffers that crashed on AVAudioFile.write() with EXC_BREAKPOINT. Root cause: AVAudioConverter's input callback pattern doesn't work reliably in a tap context with format changes across both sample rate and bit depth simultaneously.

### Suggested Action
Never use AVAudioConverter with pcmFormatInt16 interleaved in audio tap callbacks. For format conversion, either: (1) record in native format and convert after recording stops, or (2) use AVAssetExportSession for compression. For Whisper specifically, just send native format — it handles any sample rate.

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

### Details
When M4A encoding produced a corrupted audio file, OpenAI Whisper API returned Korean text as transcription. This is a well-documented Whisper behavior — it hallucinates in Korean (and sometimes other languages) when receiving silence or garbage audio. The user had no Korean language settings.

### Suggested Action
Always validate audio file integrity before sending to Whisper. If transcription returns unexpected languages not in the user's language pair, treat it as a failed transcription and retry or show an error.

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

### Details
User could select French/Chinese/etc in the host app, and the keyboard showed the correct flag and labels, but translations always came back in Spanish. Root causes: (1) refineTranslation targetLang used `langCode == "es" ? "en" : "es"` instead of actual targetCode, (2) updateNotes had same hardcoded flip, (3) all GPT prompts in TalkSwitchAPI.swift referenced "Mexican Spanish" instead of using dynamic language names.

### Suggested Action
Never hardcode language codes in translation logic. Always read from App Group UserDefaults (`talkswitch_target_lang`). Use `languageName(for:)` in all GPT prompts.

### Metadata
- Source: user_feedback
- Related Files: TranslateHelperKeyboard/KeyboardViewController.swift, TranslateHelperKeyboard/Services/TalkSwitchAPI.swift
- Tags: localization, hardcoded, spanish
- Pattern-Key: i18n.hardcoded_language

---
