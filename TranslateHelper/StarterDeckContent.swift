//
//  StarterDeckContent.swift
//  TranslateHelper
//
//  Pre-written static starter deck cards for every supported language.
//  Adding a language here removes the AI generation wait on first launch.
//
//  ADDING A NEW LANGUAGE:
//  1. Add a case to StarterDeckContent.cardsFor(lang:type:)
//  2. Return 20–30 DeckCard entries (targetLang: set to the language code)
//  3. Update StarterDeckSeeder.seed() to include the new code in staticLanguages set
//

import Foundation

struct StarterDeckContent {

    /// Returns static cards for a language+type combo, or nil to fall back to AI.
    static func cardsFor(lang: String, type deckType: StarterDeckType) -> [DeckCard]? {
        switch lang {
        // Tier 1 — already existed
        case "fr": return french(deckType)
        case "pt": return portuguese(deckType)
        case "it": return italian(deckType)
        case "de": return german(deckType)
        // Batch 1
        case "es": return spanish(deckType)
        case "ja": return japanese(deckType)
        case "ko": return korean(deckType)
        case "ar": return arabic(deckType)
        case "zh": return chinese(deckType)
        case "ru": return russian(deckType)
        case "nl": return dutch(deckType)
        // Batch 2
        case "pl": return polish(deckType)
        case "tr": return turkish(deckType)
        case "uk": return ukrainian(deckType)
        case "cs": return czech(deckType)
        case "ro": return romanian(deckType)
        case "bg": return bulgarian(deckType)
        case "el": return greek(deckType)
        // Batch 3
        case "sv": return swedish(deckType)
        case "da": return danish(deckType)
        case "no": return norwegian(deckType)
        case "fi": return finnish(deckType)
        case "hu": return hungarian(deckType)
        case "sk": return slovak(deckType)
        case "id": return indonesian(deckType)
        // Batch 4
        case "vi": return vietnamese(deckType)
        case "he": return hebrew(deckType)
        case "hr": return croatian(deckType)
        case "hi": return hindi(deckType)
        case "bn": return bengali(deckType)
        case "ur": return urdu(deckType)
        case "sw": return swahili(deckType)
        // Batch 5
        case "th": return thai(deckType)
        case "fa": return persian(deckType)
        case "ms": return malay(deckType)
        case "tl": return filipino(deckType)
        case "af": return afrikaans(deckType)
        case "ta": return tamil(deckType)
        case "ca": return catalan(deckType)
        default:   return nil
        }
    }

    // MARK: - French

    private static func french(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages:
            return [
                DeckCard(english: "The early bird catches the worm", spanish: "L'avenir appartient à ceux qui se lèvent tôt", notes: "Lit: The future belongs to those who get up early. Said to encourage proactivity.", targetLang: "fr"),
                DeckCard(english: "Better late than never", spanish: "Mieux vaut tard que jamais", notes: "Direct equivalent. Often said with mild sarcasm when someone finally shows up.", targetLang: "fr"),
                DeckCard(english: "Practice makes perfect", spanish: "C'est en forgeant qu'on devient forgeron", notes: "Lit: It's by forging that one becomes a blacksmith. Said to encourage persistence.", targetLang: "fr"),
                DeckCard(english: "Every cloud has a silver lining", spanish: "Après la pluie, le beau temps", notes: "Lit: After the rain, good weather. A classic comfort phrase.", targetLang: "fr"),
                DeckCard(english: "Nothing ventured, nothing gained", spanish: "Qui ne risque rien n'a rien", notes: "Lit: He who risks nothing has nothing. Said to push someone to take a chance.", targetLang: "fr"),
                DeckCard(english: "The dogs bark but the caravan moves on", spanish: "Les chiens aboient, la caravane passe", notes: "Ignore critics and keep moving. Said when haters try to slow you down.", targetLang: "fr"),
                DeckCard(english: "No one is a prophet in their own land", spanish: "Nul n'est prophète en son pays", notes: "You're never valued as much at home as abroad. Very commonly used.", targetLang: "fr"),
                DeckCard(english: "Sleep on it", spanish: "La nuit porte conseil", notes: "Lit: The night brings counsel. Said before a big decision — wait before acting.", targetLang: "fr"),
                DeckCard(english: "Don't count your chickens", spanish: "Il ne faut pas vendre la peau de l'ours avant de l'avoir tué", notes: "Lit: Don't sell the bearskin before killing the bear. Used as a warning against overconfidence.", targetLang: "fr"),
                DeckCard(english: "The road to hell is paved with good intentions", spanish: "L'enfer est pavé de bonnes intentions", notes: "Direct equivalent. Said when someone means well but causes harm.", targetLang: "fr"),
                DeckCard(english: "Walls have ears", spanish: "Les murs ont des oreilles", notes: "Be careful what you say — someone might be listening.", targetLang: "fr"),
                DeckCard(english: "Like father, like son", spanish: "Tel père, tel fils", notes: "Direct equivalent. Said when a child mirrors their parent's behaviour.", targetLang: "fr"),
                DeckCard(english: "Don't put all your eggs in one basket", spanish: "Il ne faut pas mettre tous ses œufs dans le même panier", notes: "Direct equivalent. Diversify your bets.", targetLang: "fr"),
                DeckCard(english: "He who laughs last, laughs longest", spanish: "Rira bien qui rira le dernier", notes: "Said after proving a doubter wrong. Mild triumph.", targetLang: "fr"),
                DeckCard(english: "You can't judge a book by its cover", spanish: "Il ne faut pas se fier aux apparences", notes: "Lit: One shouldn't trust appearances. Classic caution against snap judgements.", targetLang: "fr"),
                DeckCard(english: "Out of sight, out of mind", spanish: "Loin des yeux, loin du cœur", notes: "Lit: Far from the eyes, far from the heart. More poetic than the English version.", targetLang: "fr"),
                DeckCard(english: "All that glitters is not gold", spanish: "Tout ce qui brille n'est pas or", notes: "Direct equivalent. Don't be fooled by shiny surfaces.", targetLang: "fr"),
                DeckCard(english: "Greed is its own punishment", spanish: "La cupidité est la racine de tous les maux", notes: "The love of money is the root of all evil. Said when greed backfires.", targetLang: "fr"),
                DeckCard(english: "When in Rome", spanish: "Il faut vivre avec son temps", notes: "Lit: One must live with one's times. Adapt to your environment.", targetLang: "fr"),
                DeckCard(english: "A friend in need is a friend indeed", spanish: "C'est dans le besoin qu'on reconnaît ses amis", notes: "Lit: It's in need that you recognise your friends. Said after someone shows up when it matters.", targetLang: "fr"),
            ]
        case .euphemisms:
            return [
                DeckCard(english: "To have sex", spanish: "Faire la bête à deux dos", notes: "Lit: To make the beast with two backs. Shakespeare used it too — timeless.", targetLang: "fr"),
                DeckCard(english: "To get great pleasure / orgasm", spanish: "Prendre son pied", notes: "Lit: To take your foot. Said about intense enjoyment of any kind, but wink-wink understood.", targetLang: "fr"),
                DeckCard(english: "To French kiss", spanish: "Rouler une pelle", notes: "Lit: To roll a shovel. Very common teen/young adult slang. Sounds harmless, means making out.", targetLang: "fr"),
                DeckCard(english: "To turn someone on / flirt aggressively", spanish: "Allumer quelqu'un", notes: "Lit: To light someone up. 'Elle l'allumait depuis le début' = She was teasing him the whole time.", targetLang: "fr"),
                DeckCard(english: "To be well-endowed (woman)", spanish: "Avoir du monde au balcon", notes: "Lit: To have people on the balcony. Said about a woman's chest. Sounds innocent in isolation.", targetLang: "fr"),
                DeckCard(english: "To be very drunk", spanish: "Être rond comme une queue de pelle", notes: "Lit: Round as a shovel handle. Said about someone absolutely hammered.", targetLang: "fr"),
                DeckCard(english: "To drink heavily", spanish: "Lever le coude", notes: "Lit: To raise the elbow. 'Il lève le coude tous les soirs' = He drinks every night.", targetLang: "fr"),
                DeckCard(english: "To be hungover", spanish: "Avoir la gueule de bois", notes: "Lit: To have a wooden face/mouth. One of the most-used expressions by any French speaker.", targetLang: "fr"),
                DeckCard(english: "To go crazy / lose it", spanish: "Péter les plombs", notes: "Lit: To blow the fuses. 'Il a pété les plombs' = He completely lost it.", targetLang: "fr"),
                DeckCard(english: "To be depressed / down", spanish: "Avoir le cafard", notes: "Lit: To have the cockroach. Said when feeling low. Sounds odd until you know it.", targetLang: "fr"),
                DeckCard(english: "To faint", spanish: "Tomber dans les pommes", notes: "Lit: To fall into the apples. 'Elle est tombée dans les pommes' = She fainted.", targetLang: "fr"),
                DeckCard(english: "To be broke", spanish: "Être à sec", notes: "Lit: To be dry. 'Je suis complètement à sec' = I'm completely broke.", targetLang: "fr"),
                DeckCard(english: "To be very attracted to someone", spanish: "En pincer pour quelqu'un", notes: "Lit: To pinch for someone. 'J'en pince pour elle' = I'm really into her.", targetLang: "fr"),
                DeckCard(english: "To seduce / put the moves on", spanish: "Mettre le grappin sur quelqu'un", notes: "Lit: To throw the hook on someone. Implies a deliberate, determined seduction.", targetLang: "fr"),
                DeckCard(english: "To be tipsy", spanish: "Être pompette", notes: "A gentle, affectionate way to say slightly drunk. 'Elle était un peu pompette' = She was a bit tipsy.", targetLang: "fr"),
                DeckCard(english: "To drunkenly flirt / fool around", spanish: "Flirter", notes: "From English but fully absorbed into French. Lighter than draguer. Common among younger speakers.", targetLang: "fr"),
                DeckCard(english: "To dress up / look sharp", spanish: "Se mettre sur son 31", notes: "Lit: To put yourself on your 31st. Used when someone is dressed up for an occasion.", targetLang: "fr"),
                DeckCard(english: "To have a one-night stand", spanish: "Une aventure d'un soir", notes: "Lit: A one-evening adventure. Said matter-of-factly. No judgment implied.", targetLang: "fr"),
                DeckCard(english: "To sleep in", spanish: "Faire la grasse matinée", notes: "Lit: To make a fat morning. Said when someone sleeps past normal hours. Completely innocent but very French.", targetLang: "fr"),
                DeckCard(english: "To have a crush on someone", spanish: "Avoir le béguin pour quelqu'un", notes: "Lit: To have the béguin (a type of cap). Old origin, still very much in use today.", targetLang: "fr"),
            ]
        case .datingAndRomance:
            return [
                DeckCard(english: "Love at first sight", spanish: "Le coup de foudre", notes: "Lit: The lightning bolt. The most iconic French romantic expression. Still used daily.", targetLang: "fr"),
                DeckCard(english: "To flirt / pick someone up", spanish: "Draguer", notes: "'Il m'a dragué toute la soirée' = He was hitting on me all evening. Standard verb for flirting.", targetLang: "fr"),
                DeckCard(english: "I like you (romantically)", spanish: "Tu me plais", notes: "More direct than it sounds. 'Tu me plais' is how you tell someone you're into them.", targetLang: "fr"),
                DeckCard(english: "I love you", spanish: "Je t'aime", notes: "The classic. Used for romantic love — not as casually as English 'love you'.", targetLang: "fr"),
                DeckCard(english: "I'm crazy about you", spanish: "Je suis fou/folle de toi", notes: "Fou (m) / folle (f). Said when feelings are intense.", targetLang: "fr"),
                DeckCard(english: "You're beautiful", spanish: "Tu es magnifique", notes: "Stronger and more sincere than 'jolie'. Said to someone you truly find stunning.", targetLang: "fr"),
                DeckCard(english: "I miss you", spanish: "Tu me manques", notes: "Note: French structure is reversed — lit: 'You are missing from me.' Don't mix it up.", targetLang: "fr"),
                DeckCard(english: "My darling", spanish: "Mon chéri / Ma chérie", notes: "Mon chéri (to a man), ma chérie (to a woman). The classic French term of endearment.", targetLang: "fr"),
                DeckCard(english: "My heart", spanish: "Mon cœur", notes: "Used as an endearment — 'Bonjour, mon cœur' is perfectly natural.", targetLang: "fr"),
                DeckCard(english: "To fall in love", spanish: "Tomber amoureux / amoureuse", notes: "Amoureux (m) / amoureuse (f). 'Je suis tombé amoureux' = I fell in love.", targetLang: "fr"),
                DeckCard(english: "To be in a relationship", spanish: "Être en couple", notes: "Standard way to say you're with someone. 'Ils sont en couple depuis 2 ans.'", targetLang: "fr"),
                DeckCard(english: "To go out with someone", spanish: "Sortir avec quelqu'un", notes: "'Je sors avec lui' = I'm going out with him. Equivalent to 'dating'.", targetLang: "fr"),
                DeckCard(english: "Can I have your number?", spanish: "Tu peux me donner ton numéro?", notes: "Casual form. Formal: 'Pourriez-vous me donner votre numéro?' — but that's weird on a date.", targetLang: "fr"),
                DeckCard(english: "You have beautiful eyes", spanish: "Tu as de beaux yeux", notes: "Legendary French flirt line — famously used in old cinema. Still works.", targetLang: "fr"),
                DeckCard(english: "I have a crush on you", spanish: "J'ai le béguin pour toi", notes: "Warmer and more specific than 'tu me plais'. Implies ongoing feelings.", targetLang: "fr"),
                DeckCard(english: "You occupy all my thoughts", spanish: "Tu occupes toutes mes pensées", notes: "Said when someone can't stop thinking about their person. Heartfelt, not cheesy.", targetLang: "fr"),
                DeckCard(english: "To break up", spanish: "Rompre / Se séparer", notes: "'Ils ont rompu' = They broke up. Rompre is more definitive; se séparer softer.", targetLang: "fr"),
                DeckCard(english: "Unrequited love", spanish: "L'amour non partagé", notes: "Lit: Love not shared. Less painful when it has such an elegant name.", targetLang: "fr"),
                DeckCard(english: "To make up after a fight", spanish: "Se réconcilier", notes: "'On s'est réconciliés' = We made up. More formal but very commonly used.", targetLang: "fr"),
                DeckCard(english: "I'm under your spell", spanish: "Je suis sous ton charme", notes: "'Je suis complètement sous ton charme' = I'm completely charmed by you. Smooth and sincere.", targetLang: "fr"),
            ]
        }
    }

    // MARK: - Portuguese

    private static func portuguese(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages:
            return [
                DeckCard(english: "Every cloud has a silver lining", spanish: "Não há mal que sempre dure", notes: "Lit: There's no evil that lasts forever. Classic comfort — things will improve.", targetLang: "pt"),
                DeckCard(english: "Better late than never", spanish: "Antes tarde do que nunca", notes: "Direct equivalent. Said with acceptance when something finally happens.", targetLang: "pt"),
                DeckCard(english: "Actions speak louder than words", spanish: "Quem tem boca vai a Roma", notes: "Lit: He who has a mouth goes to Rome. Ask and you shall find — don't just wait.", targetLang: "pt"),
                DeckCard(english: "Practice makes perfect", spanish: "A prática leva à perfeição", notes: "Direct equivalent. Encouragement to keep going.", targetLang: "pt"),
                DeckCard(english: "You reap what you sow", spanish: "Quem semeia vento colhe tempestade", notes: "Lit: He who sows wind reaps a storm. You get back what you put out.", targetLang: "pt"),
                DeckCard(english: "Don't count your chickens", spanish: "Não venda a pele do urso antes de o matar", notes: "Lit: Don't sell the bear skin before killing it. Very similar to French/Spanish versions.", targetLang: "pt"),
                DeckCard(english: "A rolling stone gathers no moss", spanish: "Pedra que muito rola não cria limo", notes: "Lit: A stone that rolls a lot doesn't grow moss. Said about restless people.", targetLang: "pt"),
                DeckCard(english: "Empty vessels make the most noise", spanish: "Muito barulho por nada", notes: "Lit: Much noise for nothing. Said about people who talk big but deliver little.", targetLang: "pt"),
                DeckCard(english: "The early bird catches the worm", spanish: "Deus ajuda quem cedo madruga", notes: "Lit: God helps those who rise early. Same religious flavour as the Spanish version.", targetLang: "pt"),
                DeckCard(english: "Easier said than done", spanish: "É mais fácil falar do que fazer", notes: "Direct equivalent. Said when someone promises something difficult.", targetLang: "pt"),
                DeckCard(english: "Silence is golden", spanish: "Em boca fechada não entra mosca", notes: "Lit: Flies don't enter a closed mouth. Borrowed from Spanish — used identically.", targetLang: "pt"),
                DeckCard(english: "All that glitters is not gold", spanish: "Nem tudo que reluz é ouro", notes: "Direct equivalent. Classic caution against shiny exteriors.", targetLang: "pt"),
                DeckCard(english: "Out of sight, out of mind", spanish: "Longe dos olhos, longe do coração", notes: "Lit: Far from the eyes, far from the heart. Poetic and widely used.", targetLang: "pt"),
                DeckCard(english: "Where there's smoke, there's fire", spanish: "Não há fumaça sem fogo", notes: "Direct equivalent. Used when a rumour turns out to have some basis.", targetLang: "pt"),
                DeckCard(english: "You live and learn", spanish: "Errando se aprende", notes: "Lit: By erring, one learns. Said after making a mistake.", targetLang: "pt"),
                DeckCard(english: "One hand washes the other", spanish: "Uma mão lava a outra", notes: "Direct equivalent. Said about mutual favours and reciprocal relationships.", targetLang: "pt"),
                DeckCard(english: "A friend in need is a friend indeed", spanish: "Na necessidade se conhece o amigo", notes: "Lit: In need you recognise a friend. Said after someone proved loyal in hard times.", targetLang: "pt"),
                DeckCard(english: "Don't put all your eggs in one basket", spanish: "Não ponha todos os ovos no mesmo cesto", notes: "Direct equivalent. Financial and romantic advice alike.", targetLang: "pt"),
                DeckCard(english: "The grass is always greener", spanish: "A grama do vizinho é sempre mais verde", notes: "Direct equivalent. Said when someone envies what they don't have.", targetLang: "pt"),
                DeckCard(english: "Rome wasn't built in a day", spanish: "Roma não foi construída em um dia", notes: "Direct equivalent. Patience for big things.", targetLang: "pt"),
            ]
        case .euphemisms:
            return [
                DeckCard(english: "To have sex", spanish: "Comer alguém", notes: "Lit: To eat someone. Very common Brazilian slang. Bold but widely understood.", targetLang: "pt"),
                DeckCard(english: "To hook up", spanish: "Ficar com alguém", notes: "Lit: To stay with someone. Classic Brazilian term for a casual hookup or makeout session.", targetLang: "pt"),
                DeckCard(english: "To be very drunk", spanish: "Estar de porre", notes: "Lit: To be in the pour. 'Ele estava de porre' = He was absolutely wasted.", targetLang: "pt"),
                DeckCard(english: "To drink heavily", spanish: "Encher a cara", notes: "Lit: To fill your face. 'Foram encher a cara' = They went to get hammered.", targetLang: "pt"),
                DeckCard(english: "To be hungover", spanish: "Estar de ressaca", notes: "Lit: To be in the undertow. 'Estou de ressaca' is said every Sunday morning in Brazil.", targetLang: "pt"),
                DeckCard(english: "To flirt boldly", spanish: "Dar em cima de alguém", notes: "Lit: To go on top of someone. 'Ele ficou dando em cima de mim' = He was all over me.", targetLang: "pt"),
                DeckCard(english: "To have a one-night stand", spanish: "Uma noite de prazer", notes: "Lit: A night of pleasure. Said matter-of-factly in Brazilian culture.", targetLang: "pt"),
                DeckCard(english: "To be broke", spanish: "Estar na lona", notes: "Lit: To be on the canvas (knocked down, like a boxer). 'Estou na lona' = I'm flat broke.", targetLang: "pt"),
                DeckCard(english: "To lose your mind", spanish: "Pirar", notes: "To go crazy, lose it. 'Ele pirou' = He lost it completely. Very casual.", targetLang: "pt"),
                DeckCard(english: "To be sexually attractive", spanish: "Ser gostoso/gostosa", notes: "Lit: To be delicious/tasty. The standard compliment for physical attraction in Brazil.", targetLang: "pt"),
                DeckCard(english: "To get lucky", spanish: "Dar sorte na cama", notes: "Lit: To get lucky in bed. Used with a knowing look.", targetLang: "pt"),
                DeckCard(english: "To be tipsy / merry", spanish: "Estar alegre", notes: "Lit: To be merry. The polite way to say someone has had a few drinks.", targetLang: "pt"),
                DeckCard(english: "To fool around romantically", spanish: "Fazer molecagem", notes: "Lit: To do rascal things. Implies playful, flirtatious, slightly naughty behaviour.", targetLang: "pt"),
                DeckCard(english: "To be obsessed with someone", spanish: "Estar fissurado/a", notes: "Lit: To be cracked/fissured. 'Estou fissurado nela' = I'm obsessed with her.", targetLang: "pt"),
                DeckCard(english: "To go all out / give it everything", spanish: "Dar o tudo por tudo", notes: "Lit: To give everything for everything. Used for effort in any context.", targetLang: "pt"),
                DeckCard(english: "To be in a bad mood", spanish: "Estar de mau humor", notes: "Direct but used constantly. 'Ela está de mau humor hoje' = She's in a foul mood today.", targetLang: "pt"),
                DeckCard(english: "To party hard", spanish: "Arrebentar", notes: "Lit: To burst. 'Vamos arrebentar essa festa' = We're going to destroy this party (in the best way).", targetLang: "pt"),
                DeckCard(english: "To hit on someone persistently", spanish: "Colar em alguém", notes: "Lit: To glue yourself to someone. Said about persistent, unwanted or wanted attention.", targetLang: "pt"),
                DeckCard(english: "To have nerve / audacity", spanish: "Ter cara de pau", notes: "Lit: To have a wooden face. 'Que cara de pau!' = What nerve! Said with admiration or disgust.", targetLang: "pt"),
                DeckCard(english: "To make out", spanish: "Beijar na boca", notes: "Lit: To kiss on the mouth. More direct than the English equivalent, but that's Brazil.", targetLang: "pt"),
            ]
        case .datingAndRomance:
            return [
                DeckCard(english: "Love at first sight", spanish: "Amor à primeira vista", notes: "Direct equivalent. Said about instant, overwhelming attraction.", targetLang: "pt"),
                DeckCard(english: "To flirt / hook up casually", spanish: "Ficar", notes: "Uniquely Brazilian. Fibring = a casual romantic encounter with no commitment implied.", targetLang: "pt"),
                DeckCard(english: "I like you", spanish: "Eu gosto de você", notes: "The Brazilian standard for 'I like you' romantically. Less intense than 'te amo'.", targetLang: "pt"),
                DeckCard(english: "I love you", spanish: "Eu te amo", notes: "Reserved for deep love. 'Te amo' is serious in Brazil — not thrown around casually.", targetLang: "pt"),
                DeckCard(english: "I'm crazy about you", spanish: "Sou louco/louca por você", notes: "Louco (m) / louca (f). Said when feelings are intense and undeniable.", targetLang: "pt"),
                DeckCard(english: "You're beautiful", spanish: "Você é linda/lindo", notes: "Linda (f) / lindo (m). The go-to compliment. Natural and sincere.", targetLang: "pt"),
                DeckCard(english: "I miss you", spanish: "Estou com saudade de você", notes: "Saudade is untranslatable — it's a longing with love. Saying this carries real emotional weight.", targetLang: "pt"),
                DeckCard(english: "My love", spanish: "Meu amor", notes: "The standard term of endearment. Used constantly between couples.", targetLang: "pt"),
                DeckCard(english: "Babe / sweetheart", spanish: "Mozão", notes: "Casual affectionate term. 'Oi, mozão' = Hey babe. Very Brazilian, very warm.", targetLang: "pt"),
                DeckCard(english: "Do you want to go out with me?", spanish: "Quer sair comigo?", notes: "Direct and common. No games — just ask.", targetLang: "pt"),
                DeckCard(english: "Can I have your number?", spanish: "Posso te pedir o número?", notes: "Lit: Can I ask for your number? Polite, warm, natural.", targetLang: "pt"),
                DeckCard(english: "You make me happy", spanish: "Você me faz feliz", notes: "Simple and sincere. Said between couples.", targetLang: "pt"),
                DeckCard(english: "To be dating / going out", spanish: "Estar namorando", notes: "'Estamos namorando' = We're dating/in a relationship. Namorar implies commitment.", targetLang: "pt"),
                DeckCard(english: "Boyfriend / girlfriend", spanish: "Namorado / namorada", notes: "Namorado (m) / namorada (f). The committed partner — not a casual date.", targetLang: "pt"),
                DeckCard(english: "I fell in love with you", spanish: "Me apaixonei por você", notes: "Apaixonar = to become passionate/in love. 'Me apaixonei' = I fell in love.", targetLang: "pt"),
                DeckCard(english: "To break up", spanish: "Terminar o relacionamento", notes: "'A gente terminou' = We broke up. Said with sadness (or relief).", targetLang: "pt"),
                DeckCard(english: "To make up after a fight", spanish: "Fazer as pazes", notes: "Direct equivalent. 'Já fizemos as pazes' = We already made up.", targetLang: "pt"),
                DeckCard(english: "You're my person", spanish: "Você é a pessoa certa pra mim", notes: "Lit: You're the right person for me. Said with sincerity in a serious relationship.", targetLang: "pt"),
                DeckCard(english: "I think about you all the time", spanish: "Fico pensando em você o tempo todo", notes: "Natural and heartfelt. Said early in a relationship.", targetLang: "pt"),
                DeckCard(english: "Will you be my girlfriend/boyfriend?", spanish: "Quer ser minha namorada/namorado?", notes: "The official ask. A big deal in Brazilian dating culture.", targetLang: "pt"),
            ]
        }
    }

    // MARK: - Italian

    private static func italian(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages:
            return [
                DeckCard(english: "Every cloud has a silver lining", spanish: "Non tutto il male vien per nuocere", notes: "Lit: Not all evil comes to harm. Said to comfort someone after bad news.", targetLang: "it"),
                DeckCard(english: "Better late than never", spanish: "Meglio tardi che mai", notes: "Direct equivalent. Said with acceptance or mild sarcasm.", targetLang: "it"),
                DeckCard(english: "The early bird catches the worm", spanish: "Chi dorme non piglia pesci", notes: "Lit: He who sleeps doesn't catch fish. Said to encourage getting up and acting.", targetLang: "it"),
                DeckCard(english: "All that glitters is not gold", spanish: "Non è tutto oro quel che luccica", notes: "Direct equivalent. Classic caution.", targetLang: "it"),
                DeckCard(english: "Practice makes perfect", spanish: "L'appetito vien mangiando", notes: "Lit: Appetite comes with eating. The desire/skill grows as you do the thing.", targetLang: "it"),
                DeckCard(english: "Out of sight, out of mind", spanish: "Lontano dagli occhi, lontano dal cuore", notes: "Lit: Far from the eyes, far from the heart. Said about long-distance relationships.", targetLang: "it"),
                DeckCard(english: "Nothing ventured, nothing gained", spanish: "Chi non risica non rosica", notes: "Lit: He who doesn't risk doesn't gnaw. Rhymes in Italian — very memorable.", targetLang: "it"),
                DeckCard(english: "You reap what you sow", spanish: "Chi la fa l'aspetti", notes: "Lit: He who does it should expect it back. Karma in Italian form.", targetLang: "it"),
                DeckCard(english: "A friend in need is a friend indeed", spanish: "Il vero amico si vede nel momento del bisogno", notes: "Lit: The true friend is seen in the moment of need. Said after loyalty is demonstrated.", targetLang: "it"),
                DeckCard(english: "Don't judge a book by its cover", spanish: "L'abito non fa il monaco", notes: "Lit: The habit does not make the monk. Appearances are deceiving.", targetLang: "it"),
                DeckCard(english: "Easier said than done", spanish: "Tra il dire e il fare c'è di mezzo il mare", notes: "Lit: Between saying and doing there's a sea in between. More vivid than the English version.", targetLang: "it"),
                DeckCard(english: "When in Rome", spanish: "Paese che vai, usanza che trovi", notes: "Lit: Country you go, custom you find. Adapt to where you are.", targetLang: "it"),
                DeckCard(english: "Where there's smoke, there's fire", spanish: "Non c'è fumo senza arrosto", notes: "Lit: There's no smoke without a roast. Used when rumours turn out to be true.", targetLang: "it"),
                DeckCard(english: "Silence is golden", spanish: "Il silenzio è d'oro", notes: "Direct equivalent. Said when talking less is clearly the better move.", targetLang: "it"),
                DeckCard(english: "Rome wasn't built in a day", spanish: "Roma non è stata costruita in un giorno", notes: "Direct equivalent. Patience for great things.", targetLang: "it"),
                DeckCard(english: "The grass is always greener", spanish: "L'erba del vicino è sempre più verde", notes: "Direct equivalent. Said about envy for what others have.", targetLang: "it"),
                DeckCard(english: "Don't cry over spilled milk", spanish: "Non piangere sul latte versato", notes: "Direct equivalent. Said when someone is dwelling on what can't be changed.", targetLang: "it"),
                DeckCard(english: "Walls have ears", spanish: "I muri hanno orecchie", notes: "Direct equivalent. Be careful what you say.", targetLang: "it"),
                DeckCard(english: "Blood is thicker than water", spanish: "Il sangue non è acqua", notes: "Lit: Blood is not water. Family first — very resonant in Italian culture.", targetLang: "it"),
                DeckCard(english: "Every man for himself", spanish: "Ognuno per sé e Dio per tutti", notes: "Lit: Each for himself and God for all. Said when self-interest kicks in.", targetLang: "it"),
            ]
        case .euphemisms:
            return [
                DeckCard(english: "To have sex", spanish: "Fare l'amore", notes: "Lit: To make love. The common, non-vulgar way to say it.", targetLang: "it"),
                DeckCard(english: "To be very drunk", spanish: "Essere sbronzo/a", notes: "The standard word for drunk. 'Era completamente sbronzo' = He was completely wasted.", targetLang: "it"),
                DeckCard(english: "To drink heavily", spanish: "Alzare il gomito", notes: "Lit: To raise the elbow. 'Alza il gomito ogni sera' = He drinks every evening.", targetLang: "it"),
                DeckCard(english: "To be hungover", spanish: "Avere i postumi della sbornia", notes: "Lit: To have the aftermath of the drunkenness. Said Sunday mornings everywhere.", targetLang: "it"),
                DeckCard(english: "To flirt / hit on someone", spanish: "Fare il filo a qualcuno", notes: "Lit: To spin thread for someone. 'Mi stava facendo il filo' = He was hitting on me.", targetLang: "it"),
                DeckCard(english: "To have a crush", spanish: "Avere una cotta per qualcuno", notes: "Lit: To have a crust for someone. 'Ho una cotta per lui' = I have a crush on him.", targetLang: "it"),
                DeckCard(english: "To be broke", spanish: "Essere al verde", notes: "Lit: To be at the green. Old origin (bottom of a candle). 'Sono al verde' = I'm broke.", targetLang: "it"),
                DeckCard(english: "To lose your mind", spanish: "Perdere la testa", notes: "Lit: To lose your head. Also means to fall hard for someone — context is everything.", targetLang: "it"),
                DeckCard(english: "To get lucky / have great luck", spanish: "Avere la fortuna dalla propria parte", notes: "Said when things go unexpectedly well, romantically or otherwise.", targetLang: "it"),
                DeckCard(english: "To be hot / attractive", spanish: "Essere un gran figo / una gran figa", notes: "Figo (m) / figa (f). Very common Italian slang for being hot. Used casually.", targetLang: "it"),
                DeckCard(english: "To make out", spanish: "Sbaciucchiarsi", notes: "To kiss a lot. Sounds sweet but implies serious making out.", targetLang: "it"),
                DeckCard(english: "To be in a bad mood", spanish: "Essere di malumore", notes: "Standard phrase. 'È di malumore oggi' = She's in a foul mood today.", targetLang: "it"),
                DeckCard(english: "To party hard", spanish: "Far baldoria", notes: "Lit: To make merry-noise. 'Hanno fatto baldoria fino all'alba' = They partied till dawn.", targetLang: "it"),
                DeckCard(english: "To faint", spanish: "Svenire", notes: "Direct verb. 'È svenuta' = She fainted. No euphemism needed — Italian is dramatic enough.", targetLang: "it"),
                DeckCard(english: "To be obsessed with someone", spanish: "Andare matto/a per qualcuno", notes: "Lit: To go crazy for someone. 'Vado matto per lei' = I'm crazy about her.", targetLang: "it"),
                DeckCard(english: "To go crazy", spanish: "Impazzire", notes: "To go crazy/lose it. 'Mi fai impazzire' = You drive me crazy — romantic or exasperated!", targetLang: "it"),
                DeckCard(english: "To have nerve / audacity", spanish: "Avere una bella faccia tosta", notes: "Lit: To have a nice hard face. 'Che faccia tosta!' = What nerve!", targetLang: "it"),
                DeckCard(english: "To sleep around", spanish: "Fare le corna", notes: "Lit: To make the horns — but this means to cheat on someone. Universal Italian gesture.", targetLang: "it"),
                DeckCard(english: "To pick someone up / seduce", spanish: "Rimorchiare", notes: "Lit: To tow (like a car). 'L'ha rimorchiata in discoteca' = He picked her up at the club.", targetLang: "it"),
                DeckCard(english: "To be tipsy", spanish: "Essere brillo/a", notes: "Lit: To be shiny. A gentler version of drunk. 'Era un po' brilla' = She was a little tipsy.", targetLang: "it"),
            ]
        case .datingAndRomance:
            return [
                DeckCard(english: "Love at first sight", spanish: "Colpo di fulmine", notes: "Lit: Lightning bolt. The Italian version — same as French coup de foudre.", targetLang: "it"),
                DeckCard(english: "I like you", spanish: "Mi piaci", notes: "Direct and common. How you tell someone you're into them.", targetLang: "it"),
                DeckCard(english: "I love you", spanish: "Ti amo", notes: "For deep romantic love. 'Ti voglio bene' is warmer/familial but less intense.", targetLang: "it"),
                DeckCard(english: "You're beautiful", spanish: "Sei bellissima / bellissimo", notes: "Bellissima (f) / bellissimo (m). Over-the-top Italian — and they mean it.", targetLang: "it"),
                DeckCard(english: "I miss you", spanish: "Mi manchi", notes: "Lit: You are missing from me. Same reversed structure as French. 'Mi manchi tanto' = I miss you so much.", targetLang: "it"),
                DeckCard(english: "My love", spanish: "Amore mio", notes: "Classic Italian endearment. Said constantly between couples.", targetLang: "it"),
                DeckCard(english: "Darling / sweetheart", spanish: "Tesoro mio", notes: "Lit: My treasure. Warm, affectionate, very Italian.", targetLang: "it"),
                DeckCard(english: "To fall in love", spanish: "Innamorarsi", notes: "'Mi sono innamorato/a di te' = I fell in love with you. Innamorato (m) / innamorata (f).", targetLang: "it"),
                DeckCard(english: "To be in a relationship", spanish: "Stare insieme", notes: "'Stiamo insieme' = We're together. Simple, standard.", targetLang: "it"),
                DeckCard(english: "Boyfriend / girlfriend", spanish: "Ragazzo / ragazza", notes: "Ragazzo (m) / ragazza (f). 'Il mio ragazzo' = my boyfriend.", targetLang: "it"),
                DeckCard(english: "Can I have your number?", spanish: "Posso avere il tuo numero?", notes: "Direct and polite. Works every time.", targetLang: "it"),
                DeckCard(english: "Do you want to go out with me?", spanish: "Vuoi uscire con me?", notes: "The standard ask. No games.", targetLang: "it"),
                DeckCard(english: "I'm thinking about you", spanish: "Penso a te", notes: "Simple and sincere. 'Penso sempre a te' = I always think about you.", targetLang: "it"),
                DeckCard(english: "You make me happy", spanish: "Mi rendi felice", notes: "Said between couples. Sincere and sweet.", targetLang: "it"),
                DeckCard(english: "I'm crazy about you", spanish: "Sono pazzo/pazza di te", notes: "Pazzo (m) / pazza (f). Intense — said when feelings overwhelm.", targetLang: "it"),
                DeckCard(english: "To break up", spanish: "Lasciarsi", notes: "'Ci siamo lasciati' = We broke up. Said with sadness or relief.", targetLang: "it"),
                DeckCard(english: "To make up after a fight", spanish: "Fare pace", notes: "'Abbiamo fatto pace' = We made up. Very common.", targetLang: "it"),
                DeckCard(english: "My heart", spanish: "Cuore mio", notes: "Cuore mio = my heart. Used as an endearment.", targetLang: "it"),
                DeckCard(english: "You drive me crazy (in a good way)", spanish: "Mi fai impazzire", notes: "Said in admiration, desire, or exasperation — context is everything.", targetLang: "it"),
                DeckCard(english: "I only have eyes for you", spanish: "Ho occhi solo per te", notes: "Said to express devotion and fidelity. Poetic but said in everyday speech.", targetLang: "it"),
            ]
        }
    }

    // MARK: - German

    private static func german(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages:
            return [
                DeckCard(english: "Every cloud has a silver lining", spanish: "Auf Regen folgt Sonnenschein", notes: "Lit: After rain comes sunshine. Said to comfort someone in hard times.", targetLang: "de"),
                DeckCard(english: "Better late than never", spanish: "Besser spät als nie", notes: "Direct equivalent. Said with acceptance.", targetLang: "de"),
                DeckCard(english: "Actions speak louder than words", spanish: "Taten sagen mehr als Worte", notes: "Direct equivalent. Said when proof is needed, not promises.", targetLang: "de"),
                DeckCard(english: "Nothing ventured, nothing gained", spanish: "Wer wagt, gewinnt", notes: "Lit: He who dares wins. Clean, confident. Very German.", targetLang: "de"),
                DeckCard(english: "Practice makes perfect", spanish: "Übung macht den Meister", notes: "Lit: Practice makes the master. Said to encourage persistence.", targetLang: "de"),
                DeckCard(english: "All that glitters is not gold", spanish: "Es ist nicht alles Gold, was glänzt", notes: "Direct equivalent. Classic caution against superficiality.", targetLang: "de"),
                DeckCard(english: "The early bird catches the worm", spanish: "Morgenstund hat Gold im Mund", notes: "Lit: The morning hour has gold in its mouth. Beautiful German version.", targetLang: "de"),
                DeckCard(english: "Out of sight, out of mind", spanish: "Aus den Augen, aus dem Sinn", notes: "Lit: Out of the eyes, out of the mind. Direct and unsentimental.", targetLang: "de"),
                DeckCard(english: "Where there's a will, there's a way", spanish: "Wo ein Wille ist, ist auch ein Weg", notes: "Direct equivalent. Said to motivate someone.", targetLang: "de"),
                DeckCard(english: "You reap what you sow", spanish: "Wie man in den Wald ruft, so schallt es heraus", notes: "Lit: As you call into the forest, so it echoes back. Very uniquely German.", targetLang: "de"),
                DeckCard(english: "Easier said than done", spanish: "Das ist leichter gesagt als getan", notes: "Direct equivalent. Said when promises are easy but delivery is hard.", targetLang: "de"),
                DeckCard(english: "A friend in need is a friend indeed", spanish: "In der Not erkennt man seine Freunde", notes: "Lit: In need you recognise your friends. Said after loyalty is proven.", targetLang: "de"),
                DeckCard(english: "Don't judge a book by its cover", spanish: "Man soll den Tag nicht vor dem Abend loben", notes: "Lit: Don't praise the day before evening. Don't judge too early.", targetLang: "de"),
                DeckCard(english: "Every man for himself", spanish: "Jeder ist sich selbst der Nächste", notes: "Lit: Everyone is their own neighbour first. Self-interest is human.", targetLang: "de"),
                DeckCard(english: "Rome wasn't built in a day", spanish: "Rom wurde auch nicht an einem Tag erbaut", notes: "Direct equivalent. Patience for great things.", targetLang: "de"),
                DeckCard(english: "Walls have ears", spanish: "Die Wände haben Ohren", notes: "Direct equivalent. Be careful what you say around here.", targetLang: "de"),
                DeckCard(english: "Silence is golden", spanish: "Reden ist Silber, Schweigen ist Gold", notes: "Lit: Speaking is silver, silence is gold. The full German version.", targetLang: "de"),
                DeckCard(english: "Many hands make light work", spanish: "Viele Hände machen schnell ein Ende", notes: "Lit: Many hands bring a quick end. Teamwork is better.", targetLang: "de"),
                DeckCard(english: "Don't cry over spilled milk", spanish: "Was geschehen ist, ist geschehen", notes: "Lit: What has happened, has happened. Move on.", targetLang: "de"),
                DeckCard(english: "Blood is thicker than water", spanish: "Blut ist dicker als Wasser", notes: "Direct equivalent. Family first — very resonant in German culture.", targetLang: "de"),
            ]
        case .euphemisms:
            return [
                DeckCard(english: "To have sex", spanish: "Es treiben", notes: "Lit: To drive it. Very common German slang. 'Sie treiben es' = They're doing it.", targetLang: "de"),
                DeckCard(english: "To be very drunk", spanish: "Sturzbetrunken sein", notes: "Lit: To be crash-drunk. Said when completely hammered.", targetLang: "de"),
                DeckCard(english: "To drink heavily", spanish: "Einen heben", notes: "Lit: To lift one (a glass). 'Er hebt gerne einen' = He likes to drink.", targetLang: "de"),
                DeckCard(english: "To be hungover", spanish: "Einen Kater haben", notes: "Lit: To have a tomcat. 'Ich habe einen Kater' = I'm hungover. Universally understood.", targetLang: "de"),
                DeckCard(english: "To flirt", spanish: "Schäkern", notes: "To flirt playfully. 'Sie schäkerte mit ihm' = She was flirting with him.", targetLang: "de"),
                DeckCard(english: "To lose your mind", spanish: "Den Verstand verlieren", notes: "To lose one's mind. Also: 'Du machst mich wahnsinnig' = You're driving me crazy.", targetLang: "de"),
                DeckCard(english: "To go all out", spanish: "Auf die Kacke hauen", notes: "Lit: To hit the sh**. Said when going all-in at a party or situation.", targetLang: "de"),
                DeckCard(english: "To be broke", spanish: "Pleite sein", notes: "Standard word for broke. 'Ich bin total pleite' = I'm completely broke.", targetLang: "de"),
                DeckCard(english: "To be attractive", spanish: "Knackig sein", notes: "Lit: To be crisp/crunchy. Said about someone looking very good physically.", targetLang: "de"),
                DeckCard(english: "To pick someone up", spanish: "Jemanden aufgabeln", notes: "Lit: To fork someone up. 'Er hat sie in der Bar aufgegabelt' = He picked her up at the bar.", targetLang: "de"),
                DeckCard(english: "To have a crush", spanish: "Verknallt sein", notes: "'Ich bin total verknallt in sie' = I have a massive crush on her. Very casual.", targetLang: "de"),
                DeckCard(english: "To party hard", spanish: "Auf den Putz hauen", notes: "Lit: To beat the plaster. 'Wir werden heute auf den Putz hauen' = We're going to party hard.", targetLang: "de"),
                DeckCard(english: "To be tipsy", spanish: "Angeheitert sein", notes: "Lit: To be a little heated. A polite way to say someone's had a few.", targetLang: "de"),
                DeckCard(english: "To have nerve", spanish: "Unverschämt sein", notes: "Lit: Unshameable. 'Das ist unverschämt' = That's outrageous/audacious.", targetLang: "de"),
                DeckCard(english: "To make out", spanish: "Knutschen", notes: "To kiss passionately. 'Sie knutschten auf der Straße' = They were making out in the street.", targetLang: "de"),
                DeckCard(english: "To be obsessed with someone", spanish: "Besessen von jemandem sein", notes: "Said when someone can't stop thinking about another person.", targetLang: "de"),
                DeckCard(english: "To faint", spanish: "Umkippen", notes: "Lit: To tip over. 'Sie ist umgekippt' = She fainted.", targetLang: "de"),
                DeckCard(english: "To go crazy (good)", spanish: "Ausflippen", notes: "To flip out with excitement. 'Das Publikum ist ausgeflippt' = The crowd went wild.", targetLang: "de"),
                DeckCard(english: "To sleep around", spanish: "Herumschlafen", notes: "Lit: To sleep around. Direct but euphemistic enough to use in polite conversation.", targetLang: "de"),
                DeckCard(english: "To be in a bad mood", spanish: "Einen schlechten Tag haben", notes: "Direct: to have a bad day. Said as explanation for someone's grumpiness.", targetLang: "de"),
            ]
        case .datingAndRomance:
            return [
                DeckCard(english: "Love at first sight", spanish: "Liebe auf den ersten Blick", notes: "Lit: Love at the first glance. Direct equivalent.", targetLang: "de"),
                DeckCard(english: "I like you", spanish: "Ich mag dich", notes: "Casual and warm. How you say you like someone without deep declaration.", targetLang: "de"),
                DeckCard(english: "I love you", spanish: "Ich liebe dich", notes: "The real declaration. Used seriously — not thrown around casually in German culture.", targetLang: "de"),
                DeckCard(english: "You're beautiful", spanish: "Du bist wunderschön", notes: "Wunderschön = wonderfully beautiful. Said sincerely.", targetLang: "de"),
                DeckCard(english: "I miss you", spanish: "Ich vermisse dich", notes: "Direct equivalent. Said with genuine longing.", targetLang: "de"),
                DeckCard(english: "My love", spanish: "Mein Liebling", notes: "Lit: My favourite. Standard term of endearment between couples.", targetLang: "de"),
                DeckCard(english: "Darling / sweetheart", spanish: "Schatz", notes: "Lit: Treasure. The most common German term of endearment — used constantly.", targetLang: "de"),
                DeckCard(english: "To fall in love", spanish: "Sich verlieben", notes: "'Ich habe mich in dich verliebt' = I fell in love with you.", targetLang: "de"),
                DeckCard(english: "Boyfriend / girlfriend", spanish: "Freund / Freundin", notes: "Freund (m) / Freundin (f). Context distinguishes friend vs partner.", targetLang: "de"),
                DeckCard(english: "Can I have your number?", spanish: "Darf ich deine Nummer haben?", notes: "Polite and direct. Works perfectly.", targetLang: "de"),
                DeckCard(english: "Do you want to go out with me?", spanish: "Magst du mit mir ausgehen?", notes: "Standard ask. Said before a first date.", targetLang: "de"),
                DeckCard(english: "I think about you all the time", spanish: "Ich denke die ganze Zeit an dich", notes: "Heartfelt and sincere.", targetLang: "de"),
                DeckCard(english: "I'm crazy about you", spanish: "Ich bin verrückt nach dir", notes: "Lit: I'm crazy after you. Said when strongly attracted.", targetLang: "de"),
                DeckCard(english: "You make me happy", spanish: "Du machst mich glücklich", notes: "Simple, sincere, said in relationships.", targetLang: "de"),
                DeckCard(english: "To be in a relationship", spanish: "Zusammen sein", notes: "Lit: To be together. 'Wir sind zusammen' = We're together.", targetLang: "de"),
                DeckCard(english: "To break up", spanish: "Schluss machen", notes: "Lit: To make an end. 'Er hat mit ihr Schluss gemacht' = He broke up with her.", targetLang: "de"),
                DeckCard(english: "To make up after a fight", spanish: "Sich versöhnen", notes: "To reconcile. 'Wir haben uns versöhnt' = We made up.", targetLang: "de"),
                DeckCard(english: "You have beautiful eyes", spanish: "Du hast wunderschöne Augen", notes: "Classic compliment. Always works.", targetLang: "de"),
                DeckCard(english: "Will you be my girlfriend/boyfriend?", spanish: "Willst du meine Freundin/mein Freund sein?", notes: "The official ask. A big deal in German dating culture.", targetLang: "de"),
                DeckCard(english: "I only have eyes for you", spanish: "Ich habe nur Augen für dich", notes: "Said to express devotion. Direct and sincere.", targetLang: "de"),
            ]
        }
    }
}
