# Errors Log

## [ERR-20260320-001] AVAudioConverter

**Logged**: 2026-03-20T17:30:00Z
**Priority**: high
**Status**: resolved
**Area**: backend

### Summary
EXC_BREAKPOINT crash in downsampleForWhisper() when writing converted int16 buffer to AVAudioFile.

### Error
```
Thread 3: EXC_BREAKPOINT (code=1, subcode=0x2ad6217b4)
at: try dstFile.write(from: outBuf)
in: DictateViewController.downsampleForWhisper()
```

### Context
- Attempted to convert 48kHz float32 stereo → 16kHz int16 mono using AVAudioConverter
- Converter produced buffers with mismatched format metadata
- AVAudioFile.write() crashed on format validation

### Suggested Fix
Removed manual downsampling. Record in native format, send as-is to WhisperKit (on-device) which handles resampling internally.

### Metadata
- Reproducible: yes
- Related Files: TranslateHelper/DictateViewController.swift
- See Also: LRN-20260320-002

---
