# Orbit — Architecture & Intelligence Visualizations

## 1. User Opens Sol — Decision Tree

```
USER OPENS SOL
    |
    +-- Scripts remaining? (79 curated openers)
    |   +-- YES -> Pick best unused script
    |   |         +-- Layer 1: Status match (party opener, settling, local, etc.)
    |   |         +-- Layer 2: Interest match (food, outdoors, music, etc.)
    |   |         +-- Layer 3: City transition (new city detected)
    |   |         +-- Layer 4: Slang discovery (status-aware)
    |   |
    |   +-- NO -> Personalized Topic Generator
    |             |
    |             +-- 1. Pick TOPIC CATEGORY (weighted by status)
    |             |     |
    |             |     +-- Just arrived / Visiting:
    |             |     |   HEAVY: practical life, hidden gems, social, lifestyle
    |             |     |   LIGHT: opinions, nostalgia, personal growth
    |             |     |
    |             |     +-- Getting settled (1-6mo):
    |             |     |   HEAVY: social, culture, language moments, lifestyle
    |             |     |   LIGHT: practical, nostalgia
    |             |     |
    |             |     +-- I live here (6mo+):
    |             |         HEAVY: culture, opinions, nostalgia, current events, growth
    |             |         LIGHT: practical, hidden gems
    |             |
    |             +-- 2. Apply PERSONAL LENS (from SolMemoryStore)
    |             |     +-- Silently shapes the angle — doesn't announce it
    |             |         "How do you get home late?" not "As a chef..."
    |             |
    |             +-- 3. ANTI-REPETITION filters
    |             |     +-- Recent topic tags (last 5)
    |             |     +-- Topic history (last 50 summaries)
    |             |     +-- Mentioned places blocklist (last 100 names)
    |             |     +-- Conversation pool rotation (lastServed tracking)
    |             |
    |             +-- 4. Generate via GPT-4o-mini
    |
    |
SOL RESPONDS TO USER
    |
    +-- Conversation prompt includes:
    |   +-- Discovery phase (if <5 facts known)
    |   +-- Level-specific behavior (A1-A2 / B1-B2 / C1+)
    |   +-- Personal boundaries (follow, don't probe)
    |   +-- Code-switching support (English insertions)
    |   +-- Location flex (follows user to other cities)
    |   +-- Curiosity rule ("go sideways, not just forward")
    |   +-- Variety rule (never same topic/opener twice)
    |   +-- Place repetition guard (never same place twice)
    |
    +-- Background processes (parallel):
    |   +-- Local phrasing call (dedicated GPT for corrections)
    |   +-- Gemini live enrichment (deeper knowledge for next turn)
    |   +-- High-signal fact detection -> immediate Gemini call
    |   +-- Interest refinements (likes/dislikes tracking)
    |   +-- Mistake logging (target areas)
    |   +-- Place name extraction (anti-repetition)
    |
    +-- User facts saved to SolMemoryStore
        +-- Feeds back into next session's personal lens
```

---

## 2. Sol's Intelligence Stack

```
+----------------------------------------------------------+
|                    SOL'S BRAIN                            |
+----------------------------------------------------------+
|                                                           |
|  +-------------+  +-------------+  +-------------+       |
|  |   MEMORY    |  |   CONTEXT   |  |  ENRICHMENT |       |
|  |             |  |             |  |             |       |
|  | User facts  |  | City        |  | Gemini      |       |
|  | Preferences |  | Status      |  | Live lookup |       |
|  | Past convos |  | Interests   |  | Pool refs   |       |
|  | Refinements |  | Level       |  | High-signal |       |
|  +------+------+  +------+------+  +------+------+       |
|         |                |                |               |
|         +----------------+----------------+               |
|                          |                                |
|              +-----------+-----------+                    |
|              |    GPT-4o-mini        |                    |
|              |  Conversation Engine  |                    |
|              +-----------+-----------+                    |
|                          |                                |
|         +----------------+----------------+               |
|         |                |                |               |
|  +------+------+  +-----+-------+  +-----+-------+      |
|  |  Sol speaks  |  |  Slang tips |  | User facts  |      |
|  |  in target   |  |  extracted  |  |  saved      |      |
|  |  language    |  |  & saved    |  |  to memory  |      |
|  +-------------+  +-------------+  +-------------+      |
|                                                           |
|  +---------------------------------------------------+   |
|  |          PARALLEL: Local Phrasing Call             |   |
|  |    "How a native would say what YOU said"          |   |
|  |         Ready by double-tap time                   |   |
|  +---------------------------------------------------+   |
+----------------------------------------------------------+
```

---

## 3. User Journey — First 30 Days

```
DAY 1                    DAY 7                   DAY 14                  DAY 30
  |                        |                       |                       |
  v                        v                       v                       v
+----------+          +----------+           +----------+          +----------+
|ONBOARDING|          | SETTLING |           | GROWING  |          |  LOCAL   |
|          |          |          |           |          |          |          |
|Language  |          |Sol knows |           |Target    |          |Profile   |
|Level     |          |5+ facts  |           |areas     |          |complete  |
|City      |          |Discovery |           |filling   |          |Topics    |
|Status    |          |phase     |           |Scripts   |          |rotate    |
|Interests |          |ends      |           |rotating  |          |by status |
|          |          |          |           |Streak    |          |Engagement|
|Party     |          |Personali-|           |building  |          |drives    |
|opener    |          |zed topics|           |          |          |content   |
|fires     |          |begin     |           |Graduated |          |          |
+----+-----+          +----+-----+           |mistakes  |          |Sol feels |
     |                     |                 |appear    |          |like a    |
     v                     v                 +----+-----+          |friend    |
 "What brings          "How do you                |                +----------+
  you here?"            get home                  v
                        late at               Weekly report
                        night?"               shows real data
```

---

## 4. The Correction Pipeline

```
USER SPEAKS
     |
     v
+------------------+
|  Whisper API     |---- Transcribes speech to text
|  (Cloud)         |     Hint: city names for accuracy
+--------+---------+
         |
         v
+------------------+     +------------------+
|  GPT-4o-mini     |---->|  LOCAL PHRASING  |
|  Sol responds    |     |  (Separate call) |
|                  |     |                  |
|  * Conversation  |     |  "Rewrite as a   |
|  * Translation   |     |   native from    |
|  * Slang notes   |     |   [city] would   |
|  * User facts    |     |   say it"        |
+--------+---------+     +--------+---------+
         |                         |
         v                         v
+------------------+     +------------------+
|  Sol's message   |     |  LOCAL card      |
|  appears + audio |     |  ready for       |
|                  |     |  double-tap      |
|  Single tap:     |     |                  |
|  replay audio    |     |  Long-press:     |
|                  |     |  word lookup     |
|  Double-tap:     |     |                  |
|  English         |     |  -> Gemini       |
|  translation     |     |  -> Save to      |
|                  |     |     Library       |
+------------------+     +--------+---------+
                                   |
                                   v
                         +------------------+
                         |  TARGET AREAS    |
                         |  (Background)    |
                         |                  |
                         |  Mistake logged  |
                         |  SRS tracking    |
                         |  Got it / Still  |
                         |  learning        |
                         +------------------+
```

---

## 5. API Cost Architecture

```
+-----------------------------------------------------+
|              COST PER USER SESSION                    |
|              (20 messages average)                    |
+-----------------------------------------------------+
|                                                       |
|  GPT-4o-mini (Sol conversation)     $0.02  ||||      |
|  GPT-4o-mini (Local phrasing x10)   $0.01  ||        |
|  Gemini Flash (Enrichment)          $0.001 |         |
|  Gemini Flash (Word lookups x3)     $0.001 |         |
|  Google TTS (Sol's voice x10)       $0.004 |         |
|  Whisper (Transcription x10)        $0.006 |         |
|  DeepL (Keyboard, separate)         $0.00  free      |
|                                                       |
|  TOTAL PER SESSION:                 ~$0.04            |
|  MONTHLY (daily user):              ~$1.20            |
|  MONTHLY (power user, 3x/day):      ~$3.60            |
|                                                       |
|  +-----------------------------------------------+   |
|  |  $7.99/mo subscription                         |   |
|  |  Margin: $4.39 - $6.79 per user                |   |
|  |  ||||||||||||||||||||||..........               |   |
|  |  55% - 85% gross margin                        |   |
|  +-----------------------------------------------+   |
+-----------------------------------------------------+
```

---

## 6. Data Flow Ecosystem

```
                    +---------------+
                    |   ONBOARDING  |
                    |               |
                    |  Language     |
                    |  Level        |
                    |  City         |
                    |  Status       |
                    |  Interests    |
                    +-------+-------+
                            |
              +-------------+-------------+
              v             v             v
      +--------------+ +--------+ +--------------+
      |CONVERSATION  | |KEYBOARD| |   GEMINI     |
      |   SCRIPTS    | |        | |   POOL       |
      |              | |Transla-| |              |
      | 79 curated   | |tion    | | Deep local   |
      | openers      | |Correct-| | references   |
      | Status-aware | |ions    | | City-specific|
      | Interest-    | |Tips    | | Interest-    |
      | matched      | |        | | matched      |
      +------+-------+ +---+----+ +------+-------+
             |              |             |
             +--------------+-------------+
                            v
                 +-------------------+
                 |   SOL MEMORY     |
                 |                  |
                 | User facts       |
                 | Interest refine- |
                 | ments            |
                 | Engagement data  |
                 | Place history    |
                 | Topic history    |
                 +--------+--------+
                          |
              +-----------+-----------+
              v           v           v
      +------------+ +--------+ +------------+
      |  TARGET    | | WEEKLY | |  STREAK    |
      |  AREAS     | | REPORT | |  TRACKER   |
      |            | |        | |            |
      | 8 mistake  | |Sessions| | Sol + Study|
      | categories | |Minutes | | + Keyboard |
      | SRS system | |Messages| |            |
      | Quiz mode  | |Wins    | | 3 sources  |
      | Graduation | |Focus   | | = 1 day    |
      +------------+ +--------+ +------------+
```

---

## 7. Topic Rotation — Status Weights

```
                    JUST ARRIVED        SETTLING          I LIVE HERE

Practical life      ||||| (5)           || (2)            | (1)
Culture             || (2)              |||| (4)          ||||| (5)
Social life         |||| (4)            ||||| (5)         ||| (3)
Language moments    ||| (3)             |||| (4)          |||| (4)
Current events      | (1)               ||| (3)           ||||| (5)
Nostalgia           | (1)               || (2)            ||||| (5)
Opinions            | (1)               || (2)            |||| (4)
Lifestyle           |||| (4)            ||||| (5)         ||| (3)
Hidden gems         ||||| (5)           ||| (3)           | (1)
Personal growth     | (1)               || (2)            ||||| (5)

                    Focus: Survive      Focus: Settle     Focus: Reflect
                    & Explore           & Connect         & Deepen
```

---

## 8. Gesture System

```
SOL'S MESSAGE BUBBLE
+------------------------------------------+
|                                          |
|  Oi! Voce ja experimentou a              |
|  caipirinha do Bar do Mineiro?            |
|                                          |
+------------------------------------------+
     |              |              |
     v              v              v
  SINGLE TAP    DOUBLE TAP    LONG PRESS
     |              |              |
     v              v              v
  +--------+   +----------+   +------------+
  | Play / |   | English  |   | Word Save  |
  | Stop   |   | transla- |   | Overlay    |
  | audio  |   | tion     |   |            |
  +--------+   +----------+   | Tap word   |
                               | or drag    |
                               | phrase     |
YOUR MESSAGE BUBBLE            |            |
+-------------------------+    | Gemini     |
|                         |    | lookup     |
| Eu gosto muito daqui    |    |            |
|                         |    | Save to    |
+-------------------------+    | Library    |
     |                         +------------+
     v
  DOUBLE TAP
     |
     v
  +----------+
  |  LOCAL   |
  | How a    |
  | native   |
  | would    |
  | say it   |
  +----+-----+
       |
       v
    LONG PRESS
       |
       v
  +------------+
  | Word Save  |
  | (flag      |
  |  colored)  |
  +------------+
```

---

*Generated for Orbit case study — April 2026*
