# Target Areas — Format Specification

## Overview
Each of the 8 mistake categories has its own quiz mechanic tailored to the type of mistake. Entries must be short, scannable, and bite-sized. No full sentences.

---

## Category Formats

### 1. Gender
- **Show:** `viagem`
- **User guesses:** `o` or `a`?
- **Reveal:** `a viagem` — words ending in '-agem' are feminine
- **Fragment format:** just the noun, no article

### 2. Conjugation
- **Show:** `comer, eu, present`
- **User recalls** the conjugated form
- **Reveal:** `eu como` — regular -er verb: como, come, comemos
- **Fragment format:** infinitive + pronoun + tense

### 3. Preposition
- **Show:** `pensar ___`
- **User guesses** the preposition
- **Reveal:** `pensar em` — penso em você, acreditar em, confiar em
- **Fragment format:** verb + blank

### 4. Grammar
- **Show:** `eu gosto tacos`
- **User spots** what's missing/wrong
- **Reveal:** `eu gosto de tacos` — verbs of preference need 'de'
- **Fragment format:** the broken phrase (2-4 words max)

### 5. Word Order
- **Show:** `um muito bom lugar`
- **User rearranges** mentally
- **Reveal:** `um lugar muito bom` — adjectives go after the noun
- **Fragment format:** the incorrectly ordered phrase

### 6. Vocabulary
- **Show:** `excitado`
- **User recalls** the real meaning
- **Reveal:** means "sexually aroused" — for "excited" say `empolgado`
- **Fragment format:** the false friend word

### 7. Pronunciation
- **Show:** `coração`
- **User practices** the sound
- **Reveal:** the 'ão' nasal — tongue back, jaw drops, air through nose
- **Fragment format:** the word with the difficult sound

### 8. Idiom
- **Show:** `pagar o pato`
- **User guesses** the meaning
- **Reveal:** "take the blame for something you didn't do"
- **Fragment format:** the expression (2-4 words)

---

## Rules for Data Quality

### Ingestion Validation
- `user_fragment`: max 15 characters, 1-4 words, no full sentences, no arrows, no "null"
- `correct_fragment`: same constraints
- `rule`: one sentence in user's native language, max 100 chars, pattern + 2-3 examples
- Reject any entry that fails these checks — bad data is worse than no data

### Display Rules
- Collapsed row: show only the fragment (what the user got wrong)
- Expanded: show correction + rule + Got it / Still learning buttons
- No strikethrough, no "you said" duplication
- Keep it scannable — if you can't read it in 2 seconds, it's too long

### SRS Tracking
- "Got it" → markCorrect (advances SRS interval)
- "Still learning" → markIncorrect (resets interval, collapses card)
- Both collapse the card for next visit
- After 3+ occurrences: show pattern reinforcement warning

---

*Reference doc — do not delete. Used by Claude Code for target areas implementation.*
