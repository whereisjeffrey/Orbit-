# Feature Requests Log

## [FEAT-20260320-001] streaming_upload_fallback

**Logged**: 2026-03-20T17:30:00Z
**Priority**: low
**Status**: pending
**Area**: backend

### Requested Capability
Stream audio chunks to Whisper API while recording (for older iPhones without WhisperKit support), so upload is mostly complete by the time user stops speaking.

### User Context
Users on pre-iPhone 13 devices fall back to Whisper API which requires uploading the full audio file. This adds 3-5 seconds of network latency. Streaming would reduce post-recording wait to ~1 second.

### Complexity Estimate
complex

### Suggested Implementation
Requires a server-side proxy to buffer audio chunks and forward to OpenAI Whisper once recording stops. Not needed unless user feedback from older device users indicates speed is a problem.

### Metadata
- Frequency: first_time
- Related Features: WhisperKit on-device transcription

---
