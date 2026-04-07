# Conversation Categories — Full Specification

## Distribution

| Category | Default % | New Arrival | Settling | Local |
|----------|:---------:|:-----------:|:--------:|:-----:|
| Places & Discovery | 25% | 35% | 25% | 15% |
| Culture & Opinions | 20% | 15% | 20% | 25% |
| Personal Life | 20% | 20% | 20% | 20% |
| Language & Growth | 10% | 15% | 10% | 10% |
| Nostalgia & Identity | 15% | 5% | 15% | 20% |
| Playful & Random | 10% | 10% | 10% | 10% |

## Opener Styles (rotate independently of category)

- **Recommendation** (40%): "Have you checked out [place]?"
- **Open question** (40%): "What's your go-to for [activity]?"
- **Opinion/reaction** (20%): "I heard [thing] is overrated — thoughts?"

## Variables

- `{city}` = user's primary city (e.g. "Rio de Janeiro")
- `{country}` = user's country (e.g. "Brazil")
- `{neighborhood}` = user's neighborhood if known, otherwise omit
- `{interest}` = rotated from user's selected interests

---

## Category 1 — Places & Discovery (25%)
*Powered by Gemini — specific search queries, real results*

### Query Templates (WE build these, Gemini executes):
1. "best {interest}-related spots near {neighborhood} {city}"
2. "upcoming events {city} this month {interest}"
3. "new restaurants opened in {city} 2026"
4. "hidden gems {neighborhood} {city} locals recommend"
5. "best weekend activities {city} for {interest} lovers"
6. "outdoor markets {city} this weekend"
7. "live music venues {city} {genre} tonight"
8. "best coffee shops to work from in {neighborhood} {city}"
9. "free cultural events {city} this week"
10. "best street food {city} locals eat"
11. "newest art exhibitions {city} 2026"
12. "best fitness classes near {neighborhood} {city}"
13. "rooftop bars {city} with best views"
14. "day trips from {city} under 2 hours"
15. "best bookshops {city} with local authors"

---

## Category 2 — Culture & Opinions (20%)
*No Gemini needed — we write these*

1. "What's a custom here in {country} that caught you completely off guard?"
2. "Have you noticed how people greet each other differently here in {city}?"
3. "What's something people do here in {country} that you wish they did back home?"
4. "What's the weirdest thing you've eaten here in {country} and did you like it?"
5. "Do you think people in {city} are more or less friendly than where you're from?"
6. "What's something about {country} culture that you still don't understand?"
7. "Have you figured out the tipping culture here? It confused me at first."
8. "What's a local habit you've accidentally picked up since living in {city}?"
9. "Do you think {city} is a good place to raise kids? Why or why not?"
10. "What's the biggest cultural shock you've had since arriving in {country}?"
11. "How do you feel about how people drive here in {city}?"
12. "What's a holiday here in {country} that you really want to experience?"
13. "Do you think the work culture here is better or worse than back home?"
14. "What's something about dating culture here that surprised you?"
15. "Have you noticed how people here deal with time differently?"
16. "What's a {country} tradition you've adopted as your own?"
17. "How do you feel about the bureaucracy here compared to your home country?"
18. "What's the funniest cultural misunderstanding you've had here?"
19. "Do people here seem more family-oriented than where you're from?"
20. "What's a social rule here that nobody explained to you but you had to figure out?"

---

## Category 3 — Personal Life (20%)
*No Gemini needed — universal human questions*

1. "Have you seen any good movies or shows lately?"
2. "How's work been going this week?"
3. "What do you usually do on a Sunday when you have nothing planned?"
4. "Do you cook more or eat out more since moving to {city}?"
5. "What's something you've been putting off that you really should do?"
6. "Have you made any local friends here or mostly hang with other expats?"
7. "What's your morning routine like here compared to back home?"
8. "Are you a morning person or a night person? Has that changed since moving here?"
9. "What's the last thing that made you laugh really hard?"
10. "Do you work out here? Found a gym or do something outdoors?"
11. "How do you stay in touch with people back home?"
12. "What's your go-to comfort food when you're feeling homesick?"
13. "Have you read anything good lately? Books, articles, anything?"
14. "What's the best decision you've made since moving to {city}?"
15. "What's something small that makes your day better here?"
16. "Do you have any trips coming up? Where are you thinking of going?"
17. "What did you do last weekend? Anything fun?"
18. "How do you unwind after a long day here?"
19. "Have you picked up any new hobbies since moving to {country}?"
20. "What's something about your routine here that would surprise your friends back home?"

---

## Category 4 — Language & Growth (10%)
*Meta-conversation about their learning journey*

1. "What's the funniest misunderstanding you've had because of the language?"
2. "Is there a word in {country}'s language that you keep forgetting?"
3. "What's the hardest sound for you to pronounce?"
4. "Have you ever said something that means something completely different than what you meant?"
5. "What's a word or expression you learned that you use all the time now?"
6. "Do you think in your native language or are you starting to think in the local language?"
7. "What's the most embarrassing language mistake you've made here?"
8. "Do you feel more confident speaking now than when you first arrived?"
9. "Is there a local expression that doesn't translate at all to your language?"
10. "What's a conversation topic that's still really hard for you in the language?"
11. "Have you tried watching local TV shows or movies to practice?"
12. "Do your local friends correct you or just let mistakes slide?"
13. "What's a word that sounds like an English word but means something totally different?"
14. "How do you feel when someone switches to English because they hear your accent?"
15. "What would you say is your biggest weakness in the language right now?"

---

## Category 5 — Nostalgia & Identity (15%)
*Deeper, reflective conversations*

1. "What do you miss most about home that you can't get here?"
2. "Has living in {city} changed how you see your home country?"
3. "What's something you appreciate about home MORE now that you're away?"
4. "Do you feel like a different person since you moved here?"
5. "What would you tell someone who's thinking about moving to {city}?"
6. "Is there a smell or a song that immediately takes you back home?"
7. "What's something from your culture that people here find weird or interesting?"
8. "Do you think you'll stay in {city} long-term or is this temporary?"
9. "What's the thing you were most wrong about before you moved here?"
10. "How do your family and friends back home react when you tell them about life here?"
11. "What's a part of your identity that's become more important since living abroad?"
12. "If you could bring one thing from home to {city}, what would it be?"
13. "What's a moment here where you felt like you truly belonged?"
14. "What would your life look like right now if you'd never moved to {country}?"
15. "What's the hardest thing about living far from home that nobody talks about?"

---

## Category 6 — Playful & Random (10%)
*Fun, low-stakes, gets people talking*

1. "If you could only eat one {country} food for the rest of your life, what would it be?"
2. "Unpopular opinion about {city} — go."
3. "Would you rather live in the mountains or by the beach?"
4. "What's the most overrated thing about {city}?"
5. "If you had to describe {city} in three words, what would they be?"
6. "What's a guilty pleasure you have here that you'd never admit to people back home?"
7. "If you could swap lives with any local for a day, who would it be and why?"
8. "What's the worst tourist trap in {city} that you fell for?"
9. "If {city} was a person, what kind of personality would it have?"
10. "What's the best street food you've ever had here? Describe it."
11. "Would you rather speak perfect {country} language with a textbook accent, or broken with a perfect local accent?"
12. "What's the most {country} thing you've done since arriving?"
13. "If you could teleport home for one day and come back, what would you do?"
14. "What's a local slang word you use that your friends back home wouldn't understand?"
15. "If you opened a business in {city}, what would it be?"

---

## Anti-Repetition Rules

- Each prompt has a unique ID
- Once used, marked as used — never repeats
- Category rotation tracked separately from prompt usage
- Opener style (recommendation/question/opinion) rotates independently
- Place names extracted and blocked from future mentions
- Topic history persists across sessions (last 50)
- Minimum 3 sessions before same category repeats

---

## Callback System (future v2)

- Facts older than 3 days, younger than 30 days, not yet referenced
- Injected as direct instruction: "Ask if they bought the surfboard"
- Maximum 1 callback per session
- Marked as referenced after use — never repeats

---

*Reference doc — do not delete. Used by Claude Code for conversation system.*
