# Orbit — Featured Decks Spec
> Last updated: 2026-04-09

---

## Overview

Featured decks are AI-generated on tap, cached after first generation.
Organized in tiers that unlock with engagement. Interest-weighted suggestions.

---

## Tier System

### Tier 1: Available Day 1
| Deck | Notes |
|------|-------|
| Flirting & Banter | High curiosity, universal |
| Nightlife & Going Out | Ordering, meeting people |
| Street Slang 101 | Basics everyone hears |
| Texting & WhatsApp | How locals actually text |

### Tier 2: Unlocked after 3 days of activity
| Deck | Notes |
|------|-------|
| Local Slang ({city}) | AI-generated, city-specific — the carrot |
| Food & Ordering | Restaurants, street food |
| Work & Professional | Office, emails, meetings |
| Getting Around | Uber, directions, transit |

### Tier 3: Unlocked after 7 days of activity
| Deck | Notes |
|------|-------|
| Humor & Sarcasm | Double meanings, jokes |
| Arguments & Boundaries | Saying no, complaining |
| Medical & Emergencies | Doctor, pharmacy, urgent |
| Real Estate & Renting | Apartment hunting |

---

## Interest-Based Promotion

Surface relevant decks higher based on onboarding interests:
- `outdoors` → add Hiking & Nature deck
- `food` → promote Food & Ordering
- `nightlife` → promote Nightlife & Going Out
- `remote_work` → promote Work & Professional
- `wellness` → add Gym & Wellness deck
- `dating` → promote Flirting to slot #1

---

## Build Strategy

- Don't pre-build decks. Show tiles with names/icons/lock state.
- Tap → AI generates on the spot (~5s with GPT-4o-mini)
- Cache after first generation (stored in DeckStore)
- Local Slang deck passes user's city to the prompt
- All decks are language-aware (use target language, not hardcoded)

---

## Carrot Mechanics

- Locked decks show with lock icon + "3 more days" or "Active 5/7 days"
- Preview: show 2-3 sample phrases from the deck description (not generated yet)
- Local Slang is the big carrot — city-specific, personal, behind 3 days
- Activity = any engagement (keyboard translation, Sol conversation, study cards)

---

## Post-Trial (Day 14+)

| Tier | Free | Pro |
|------|------|-----|
| Tier 1 | 15 cards per deck | Full deck |
| Tier 2 | Locked | Full access |
| Tier 3 | Locked | Full access |

- Progress on generated decks is preserved (locked, not deleted)
- User can see their progress but can't start new study sessions

---

## Open Questions

- Max number of decks per user (free vs pro)?
- Should generated decks refresh periodically with new content?
- Should Tier 2/3 decks be visible but locked, or hidden until unlocked?

---

*Spec for tomorrow's build session.*
