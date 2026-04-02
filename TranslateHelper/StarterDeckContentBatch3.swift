//
//  StarterDeckContentBatch3.swift
//  TranslateHelper
//
//  Static starter deck cards — Batch 3: Vietnamese, Hebrew, Croatian, Hindi, Bengali,
//  Urdu, Swahili, Thai, Persian, Malay, Filipino, Afrikaans, Tamil, Catalan.
//

import Foundation

extension StarterDeckContent {

    // MARK: - Vietnamese
    static func vietnamese(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "When eating fruit, remember who planted the tree", spanish: "Ăn quả nhớ kẻ trồng cây", notes: "Be grateful to those who helped you.", targetLang: "vi"),
            DeckCard(english: "Water flows, stone erodes", spanish: "Nước chảy đá mòn", notes: "Persistence beats everything.", targetLang: "vi"),
            DeckCard(english: "The buffalo that arrives late drinks muddy water", spanish: "Trâu chậm uống nước đục", notes: "If you're slow, you get the worst.", targetLang: "vi"),
            DeckCard(english: "One tree does not make a forest", spanish: "Một cây làm chẳng nên non", notes: "Unity is strength.", targetLang: "vi"),
            DeckCard(english: "Without a teacher you can't accomplish anything", spanish: "Không thầy đố mày làm nên", notes: "Respect for mentors.", targetLang: "vi"),
            DeckCard(english: "A good name is better than great wealth", spanish: "Tốt danh hơn lành áo", notes: "Reputation over possessions.", targetLang: "vi"),
            DeckCard(english: "A drop of blood is worth more than a pond of water", spanish: "Một giọt máu đào hơn ao nước lã", notes: "Family bonds are strongest.", targetLang: "vi"),
            DeckCard(english: "Problems start from the top", spanish: "Nhà dột từ nóc dột xuống", notes: "Leadership sets the example.", targetLang: "vi"),
            DeckCard(english: "Want to go far, go together", spanish: "Muốn đi xa thì đi cùng nhau", notes: "Popular in Vietnamese business.", targetLang: "vi"),
            DeckCard(english: "Our pond is still better", spanish: "Ta về ta tắm ao ta", notes: "Prefer your own roots.", targetLang: "vi"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Eating before the bell", spanish: "Ăn cơm trước kẻng", notes: "Having sex before marriage.", targetLang: "vi"),
            DeckCard(english: "Planting horns", spanish: "Cắm sừng", notes: "Cheating on your partner.", targetLang: "vi"),
            DeckCard(english: "Cruising after a football win", spanish: "Đi bão", notes: "Wild late-night antics.", targetLang: "vi"),
            DeckCard(english: "Slippery as an eel", spanish: "Trơn như lươn", notes: "Impossible to pin down.", targetLang: "vi"),
            DeckCard(english: "Sleeping with the moon", spanish: "Ngủ với trăng", notes: "Being single tonight.", targetLang: "vi"),
            DeckCard(english: "The dog that bites doesn't bark", spanish: "Chó cắn không sủa", notes: "Dangerous ones are quiet.", targetLang: "vi"),
            DeckCard(english: "Watering someone else's garden", spanish: "Tưới cây nhà người ta", notes: "Pursuing someone taken.", targetLang: "vi"),
            DeckCard(english: "Big boss", spanish: "Đại gia", notes: "Sugar daddy / wealthy patron.", targetLang: "vi"),
            DeckCard(english: "Eating slowly", spanish: "Ăn chậm", notes: "Taking things slow — with a wink.", targetLang: "vi"),
            DeckCard(english: "Drinking iced tea", spanish: "Uống trà đá", notes: "Hanging out doing nothing.", targetLang: "vi"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "Can I have your number?", spanish: "Cho anh xin số điện thoại được không?", notes: "Classic opener.", targetLang: "vi"),
            DeckCard(english: "You're really pretty", spanish: "Em xinh quá", notes: "Most common compliment.", targetLang: "vi"),
            DeckCard(english: "I miss you", spanish: "Anh nhớ em", notes: "Swap anh/em by gender.", targetLang: "vi"),
            DeckCard(english: "Want to grab coffee?", spanish: "Mình đi cà phê không?", notes: "The default Vietnamese date.", targetLang: "vi"),
            DeckCard(english: "I like you", spanish: "Anh thích em", notes: "Step before I love you.", targetLang: "vi"),
            DeckCard(english: "You make my heart flutter", spanish: "Em làm anh rung động", notes: "Genuinely falling for someone.", targetLang: "vi"),
            DeckCard(english: "Do you have a lover?", spanish: "Em có người yêu chưa?", notes: "Totally normal to ask directly.", targetLang: "vi"),
            DeckCard(english: "I love you", spanish: "Anh yêu em", notes: "Serious — implies commitment.", targetLang: "vi"),
            DeckCard(english: "Let's go for a walk", spanish: "Mình đi dạo đi", notes: "Classic Vietnamese date.", targetLang: "vi"),
            DeckCard(english: "You're the one I've been waiting for", spanish: "Em là người anh chờ đợi", notes: "Ready to get serious.", targetLang: "vi"),
        ]
        }
    }

    // MARK: - Hebrew
    static func hebrew(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "If I am not for myself, who will be?", spanish: "אם אין אני לי, מי לי?", notes: "From Hillel — Israelis quote this constantly.", targetLang: "he"),
            DeckCard(english: "It'll be fine", spanish: "יהיה בסדר", notes: "The unofficial Israeli motto.", targetLang: "he"),
            DeckCard(english: "What doesn't kill you makes you stronger", spanish: "מה שלא הורג, מחשל", notes: "Extremely common given military service.", targetLang: "he"),
            DeckCard(english: "There's no such thing as I can't", spanish: "אין דבר כזה לא יכול", notes: "Classic Israeli attitude.", targetLang: "he"),
            DeckCard(english: "The truth will come to light", spanish: "האמת יוצאת לאור", notes: "Liars will be exposed.", targetLang: "he"),
            DeckCard(english: "This too shall pass", spanish: "גם זה יעבור", notes: "Attributed to King Solomon.", targetLang: "he"),
            DeckCard(english: "Grab too much, catch nothing", spanish: "תופס מרובה לא תפס", notes: "From the Talmud.", targetLang: "he"),
            DeckCard(english: "Words from the heart enter the heart", spanish: "דברים שיוצאים מן הלב, נכנסים אל הלב", notes: "Sincerity is persuasive.", targetLang: "he"),
            DeckCard(english: "The end of a thief is the gallows", spanish: "סוף גנב לתלייה", notes: "Wrongdoers get caught.", targetLang: "he"),
            DeckCard(english: "Don't look a gift horse in the mouth", spanish: "לסוס מתנה אל תסתכל בשיניים", notes: "Be grateful.", targetLang: "he"),
        ]
        case .euphemisms: return [
            DeckCard(english: "To do a screwup", spanish: "לעשות פאדיחה", notes: "An embarrassing blunder.", targetLang: "he"),
            DeckCard(english: "To overthink", spanish: "לאכול סרט", notes: "To eat a movie — spiraling anxiously.", targetLang: "he"),
            DeckCard(english: "Went all the way", spanish: "הלך עד הסוף", notes: "Had sex.", targetLang: "he"),
            DeckCard(english: "He's set up well", spanish: "הוא מסודר", notes: "Has connections/money.", targetLang: "he"),
            DeckCard(english: "To ghost someone", spanish: "לזרוק מישהו", notes: "To throw someone.", targetLang: "he"),
            DeckCard(english: "To handle behind the scenes", spanish: "לסגור פינות", notes: "Bending rules.", targetLang: "he"),
            DeckCard(english: "Something terrible", spanish: "על הפנים", notes: "On the face — awful.", targetLang: "he"),
            DeckCard(english: "What a man/woman", spanish: "חתיכת", notes: "Intensifier before a noun.", targetLang: "he"),
            DeckCard(english: "A screw fell out", spanish: "נפל לו הבורג", notes: "Acting crazy.", targetLang: "he"),
            DeckCard(english: "To humiliate someone", spanish: "לעשות למישהו קטן", notes: "To make someone small.", targetLang: "he"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "You're gorgeous", spanish: "את יפהפייה", notes: "Feminine form — strong compliment.", targetLang: "he"),
            DeckCard(english: "Want to grab a drink?", spanish: "בא לך לשתות משהו?", notes: "Casual date invitation.", targetLang: "he"),
            DeckCard(english: "Can't stop thinking about you", spanish: "אני לא מפסיק לחשוב עלייך", notes: "Masculine speaker form.", targetLang: "he"),
            DeckCard(english: "Are you single?", spanish: "את פנויה?", notes: "Direct — Israelis don't beat around the bush.", targetLang: "he"),
            DeckCard(english: "Amazing eyes", spanish: "יש לך עיניים מדהימות", notes: "Classic compliment.", targetLang: "he"),
            DeckCard(english: "Had an amazing time", spanish: "היה לי מדהים איתך", notes: "Signals wanting to see them again.", targetLang: "he"),
            DeckCard(english: "My soul", spanish: "נשמה שלי", notes: "Call partners and even friends 'neshama'.", targetLang: "he"),
            DeckCard(english: "I'm falling for you", spanish: "אני נופל עלייך", notes: "Falling on you — passionate.", targetLang: "he"),
            DeckCard(english: "You drive me crazy", spanish: "את משגעת אותי", notes: "Irresistibly attractive.", targetLang: "he"),
            DeckCard(english: "I love you", spanish: "אני אוהב אותך", notes: "Israelis say it when they mean it.", targetLang: "he"),
        ]
        }
    }

    // MARK: - Croatian
    static func croatian(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "God helps those who help themselves", spanish: "Pomozi si sam, pa će ti i Bog pomoći", notes: "Self-reliance is valued.", targetLang: "hr"),
            DeckCard(english: "Apple doesn't fall far from tree", spanish: "Jabuka ne pada daleko od stabla", notes: "Children resemble parents.", targetLang: "hr"),
            DeckCard(english: "Who digs a pit falls in", spanish: "Tko drugome jamu kopa, sam u nju upada", notes: "Karma proverb.", targetLang: "hr"),
            DeckCard(english: "Silence is golden", spanish: "Šutnja je zlato", notes: "Restraint is wise.", targetLang: "hr"),
            DeckCard(english: "Who doesn't risk, doesn't profit", spanish: "Tko ne riskira, ne profitira", notes: "Encouragement to take chances.", targetLang: "hr"),
            DeckCard(english: "Don't praise the day before evening", spanish: "Ne hvali dana prije večeri", notes: "Wait for results.", targetLang: "hr"),
            DeckCard(english: "Without flour, no bread", spanish: "Bez brašna nema kruha", notes: "No results without work.", targetLang: "hr"),
            DeckCard(english: "Every beginning is hard", spanish: "Svaki je početak težak", notes: "Encouragement for new starts.", targetLang: "hr"),
            DeckCard(english: "A friend in need", spanish: "Prijatelj se u nevolji poznaje", notes: "True friends show up.", targetLang: "hr"),
            DeckCard(english: "Where there's a will, there's a way", spanish: "Gdje je volja, tu je i put", notes: "Motivational classic.", targetLang: "hr"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Had a few too many", spanish: "Popio je koju čašicu previše", notes: "Polite way to say drunk.", targetLang: "hr"),
            DeckCard(english: "Something under the sheet", spanish: "Imaju nešto pod plahtom", notes: "Implying sexual relationship.", targetLang: "hr"),
            DeckCard(english: "Carrying under the heart", spanish: "Nosi pod srcem", notes: "She's pregnant.", targetLang: "hr"),
            DeckCard(english: "Missing a plank in his head", spanish: "Fali mu daska u glavi", notes: "Not all there.", targetLang: "hr"),
            DeckCard(english: "Has a connection", spanish: "Ima vezu", notes: "Gets things done through nepotism.", targetLang: "hr"),
            DeckCard(english: "Fishing in troubled waters", spanish: "Lovi u mutnom", notes: "Taking advantage of chaos.", targetLang: "hr"),
            DeckCard(english: "Selling fog", spanish: "Prodaje maglu", notes: "All talk, no substance.", targetLang: "hr"),
            DeckCard(english: "Wearing horns", spanish: "Nosi rogove", notes: "Partner is cheating.", targetLang: "hr"),
            DeckCard(english: "Gone to eternal hunting grounds", spanish: "Otišao je na vječna lovišta", notes: "Poetic euphemism for death.", targetLang: "hr"),
            DeckCard(english: "Easy woman", spanish: "Laka žena", notes: "Judgmental — be aware this is offensive.", targetLang: "hr"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "Can I buy you a drink?", spanish: "Mogu li te počastiti pićem?", notes: "Polite classic.", targetLang: "hr"),
            DeckCard(english: "You're beautiful", spanish: "Prekrasna si", notes: "Prekrasna (f), prekrasan (m).", targetLang: "hr"),
            DeckCard(english: "I like you a lot", spanish: "Jako mi se sviđaš", notes: "Right level for early dating.", targetLang: "hr"),
            DeckCard(english: "Want to go out?", spanish: "Hoćeš li izaći sa mnom?", notes: "Clear and direct.", targetLang: "hr"),
            DeckCard(english: "Beautiful smile", spanish: "Imaš prekrasan osmijeh", notes: "Safe warm opener.", targetLang: "hr"),
            DeckCard(english: "Great time tonight", spanish: "Prekrasno sam se proveo večeras", notes: "Said at end of a date.", targetLang: "hr"),
            DeckCard(english: "Can't stop thinking about you", spanish: "Ne mogu prestati misliti na tebe", notes: "Serious interest.", targetLang: "hr"),
            DeckCard(english: "You're my everything", spanish: "Ti si moje sve", notes: "Committed relationships.", targetLang: "hr"),
            DeckCard(english: "I love you", spanish: "Volim te", notes: "Croatians don't say it lightly.", targetLang: "hr"),
            DeckCard(english: "Kiss me", spanish: "Poljubi me", notes: "Bold — when the moment is right.", targetLang: "hr"),
        ]
        }
    }

    // MARK: - Hindi
    static func hindi(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Patience bears sweet fruit", spanish: "सब्र का फल मीठा होता है", notes: "Most quoted Hindi proverb.", targetLang: "hi"),
            DeckCard(english: "An empty vessel makes the most noise", spanish: "थोथा चना बाजे घना", notes: "Those with little knowledge boast loudest.", targetLang: "hi"),
            DeckCard(english: "Where there's a will, there's a way", spanish: "जहाँ चाह वहाँ राह", notes: "Parents and teachers all say this.", targetLang: "hi"),
            DeckCard(english: "You reap what you sow", spanish: "जैसा बोओगे वैसा काटोगे", notes: "Karma in one line.", targetLang: "hi"),
            DeckCard(english: "Necessity is the mother of invention", spanish: "ज़रूरत ईजाद की माँ है", notes: "Used in motivational conversation.", targetLang: "hi"),
            DeckCard(english: "Do good, receive good", spanish: "कर भला हो भला", notes: "Hindi karma in four words.", targetLang: "hi"),
            DeckCard(english: "A drowning man catches at straws", spanish: "डूबते को तिनके का सहारा", notes: "Desperate people cling to any hope.", targetLang: "hi"),
            DeckCard(english: "Among the blind, one-eyed is king", spanish: "अंधों में काना राजा", notes: "Mediocre seems great in wrong crowd.", targetLang: "hi"),
            DeckCard(english: "A straw in the thief's beard", spanish: "चोर की दाढ़ी में तिनका", notes: "The guilty one looks nervous.", targetLang: "hi"),
            DeckCard(english: "The cat went on pilgrimage after 900 mice", spanish: "बिल्ली गई हज को, चूहे नौ सौ खा के", notes: "Hypocrites who act holy after wrongdoing.", targetLang: "hi"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Gone upstairs", spanish: "ऊपर चले गए", notes: "Euphemism for death.", targetLang: "hi"),
            DeckCard(english: "Her feet are heavy", spanish: "उनके पैर भारी हैं", notes: "She's pregnant.", targetLang: "hi"),
            DeckCard(english: "Both locked in a room", spanish: "दोनों एक कमरे में बंद थे", notes: "Implying sex.", targetLang: "hi"),
            DeckCard(english: "He's very switched on", spanish: "वो बड़ा चालू है", notes: "Sly, especially with women.", targetLang: "hi"),
            DeckCard(english: "Eating someone's brain", spanish: "दिमाग खाना", notes: "To nag relentlessly.", targetLang: "hi"),
            DeckCard(english: "He washed his hands", spanish: "उसने हाथ धो लिए", notes: "Gave up or took everything.", targetLang: "hi"),
            DeckCard(english: "Buttering up", spanish: "चापलूसी करना", notes: "Excessive flattery.", targetLang: "hi"),
            DeckCard(english: "Works from below", spanish: "नीचे से काम करता है", notes: "Takes bribes.", targetLang: "hi"),
            DeckCard(english: "Loose character", spanish: "उसका चरित्र ढीला है", notes: "Judgmental — use carefully.", targetLang: "hi"),
            DeckCard(english: "A screw is loose", spanish: "उसका कोई पेच ढीला है", notes: "Not mentally all there.", targetLang: "hi"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "You're very beautiful", spanish: "तुम बहुत ख़ूबसूरत हो", notes: "Works for any gender.", targetLang: "hi"),
            DeckCard(english: "Can we go for coffee?", spanish: "क्या हम कॉफ़ी पर चलें?", notes: "Modern urban dating.", targetLang: "hi"),
            DeckCard(english: "My heart beats for you", spanish: "मेरा दिल तुम्हारे लिए धड़कता है", notes: "Bollywood-level romantic.", targetLang: "hi"),
            DeckCard(english: "I miss you", spanish: "तुम्हारी बहुत याद आती है", notes: "Common in texts.", targetLang: "hi"),
            DeckCard(english: "You're one in a million", spanish: "तुम लाखों में एक हो", notes: "Beloved Bollywood phrase.", targetLang: "hi"),
            DeckCard(english: "Will you be mine?", spanish: "क्या तुम मेरी हो जाओगी?", notes: "Classic proposal line.", targetLang: "hi"),
            DeckCard(english: "I love you", spanish: "मैं तुमसे प्यार करता हूँ", notes: "Enormous weight in Hindi.", targetLang: "hi"),
            DeckCard(english: "You complete me", spanish: "तुम मुझे पूरा करते हो", notes: "Soulmate level.", targetLang: "hi"),
            DeckCard(english: "I can't live without you", spanish: "मैं तुम्हारे बिना नहीं रह सकता", notes: "Bollywood made this iconic.", targetLang: "hi"),
            DeckCard(english: "I like you", spanish: "तुम मुझे अच्छे लगते हो", notes: "Feminine speaking to masculine.", targetLang: "hi"),
        ]
        }
    }

    // MARK: - Bengali
    static func bengali(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Education is the light of the eye", spanish: "বিদ্যা হলো চোখের আলো", notes: "Bengali reverence for learning.", targetLang: "bn"),
            DeckCard(english: "The rope finds the too-clever one", spanish: "অতি চালাকের গলায় দড়ি", notes: "Overconfidence backfires.", targetLang: "bn"),
            DeckCard(english: "A stitch in time saves nine", spanish: "সময়ের এক ফোঁড় অসময়ের দশ ফোঁড়", notes: "Fix problems early.", targetLang: "bn"),
            DeckCard(english: "Where there's smoke, there's fire", spanish: "আগুন ছাড়া ধোঁয়া ওঠে না", notes: "Rumors have truth.", targetLang: "bn"),
            DeckCard(english: "You can't clap with one hand", spanish: "এক হাতে তালি বাজে না", notes: "It takes two.", targetLang: "bn"),
            DeckCard(english: "Health is wealth", spanish: "স্বাস্থ্যই সম্পদ", notes: "Universally quoted by grandmothers.", targetLang: "bn"),
            DeckCard(english: "The pen is mightier than the sword", spanish: "কলম তলোয়ারের চেয়ে শক্তিশালী", notes: "Cultural pride in literature.", targetLang: "bn"),
            DeckCard(english: "Still waters run deep", spanish: "শান্ত জলের গভীরতা বেশি", notes: "Quiet people have most depth.", targetLang: "bn"),
            DeckCard(english: "The eyes see, the mind consumes", spanish: "চোখের দেখা মনের খাওয়া", notes: "Desire starts with sight.", targetLang: "bn"),
            DeckCard(english: "Don't try to be someone you're not", spanish: "কাকের কাছে কোকিলের সুর মানায় না", notes: "Stay authentic.", targetLang: "bn"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Gone to no-return land", spanish: "সে না-ফেরার দেশে চলে গেছে", notes: "Poetic euphemism for death.", targetLang: "bn"),
            DeckCard(english: "They have something going on", spanish: "ওদের মধ্যে কিছু একটা আছে", notes: "Secret relationship.", targetLang: "bn"),
            DeckCard(english: "Eating for two", spanish: "সে দু'জনের জন্য খাচ্ছে", notes: "She's pregnant.", targetLang: "bn"),
            DeckCard(english: "No bridle on his mouth", spanish: "ওর মুখে লাগাম নেই", notes: "Talks too much.", targetLang: "bn"),
            DeckCard(english: "Honey on lips, poison in heart", spanish: "ও মুখে মধু, মনে বিষ", notes: "A charming deceiver.", targetLang: "bn"),
            DeckCard(english: "Playing with fire", spanish: "আগুন নিয়ে খেলা", notes: "Taking dangerous risks.", targetLang: "bn"),
            DeckCard(english: "Light hands", spanish: "ওর হাত খুব হালকা", notes: "Clumsy or implies stealing.", targetLang: "bn"),
            DeckCard(english: "Turned a blind eye", spanish: "সে চোখ বন্ধ করে রইলো", notes: "Deliberately ignoring wrong.", targetLang: "bn"),
            DeckCard(english: "Under the table work", spanish: "তলায় তলায় কাজ", notes: "Shady dealings.", targetLang: "bn"),
            DeckCard(english: "Roving eye", spanish: "ওর চোখ চলে খুব", notes: "Checking everyone out.", targetLang: "bn"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "You're so beautiful", spanish: "তুমি খুব সুন্দর", notes: "Most straightforward compliment.", targetLang: "bn"),
            DeckCard(english: "Shall we walk?", spanish: "একটু হাঁটতে যাবে?", notes: "Classic Bengali date.", targetLang: "bn"),
            DeckCard(english: "I think about you all the time", spanish: "আমি সারাক্ষণ তোমার কথা ভাবি", notes: "Common in texts.", targetLang: "bn"),
            DeckCard(english: "Beautiful eyes", spanish: "তোমার চোখ দুটো খুব সুন্দর", notes: "Carries literary weight.", targetLang: "bn"),
            DeckCard(english: "I like you very much", spanish: "তুমি আমার খুব ভালো লাগো", notes: "Step before I love you.", targetLang: "bn"),
            DeckCard(english: "You make me happy", spanish: "তুমি আমাকে খুশি করো", notes: "Simple and genuine.", targetLang: "bn"),
            DeckCard(english: "Have tea with me?", spanish: "আমার সাথে চা খাবে?", notes: "Tea is central to Bengali dating.", targetLang: "bn"),
            DeckCard(english: "I love you", spanish: "আমি তোমাকে ভালোবাসি", notes: "Definitive Bengali love declaration.", targetLang: "bn"),
            DeckCard(english: "My heart is yours", spanish: "আমার হৃদয় তোমার", notes: "Poetic and literary.", targetLang: "bn"),
            DeckCard(english: "You're the love of my life", spanish: "তুমি আমার জীবনের প্রেম", notes: "Not used casually.", targetLang: "bn"),
        ]
        }
    }

    // MARK: - Urdu
    static func urdu(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Patience bears sweet fruit", spanish: "صبر کا پھل میٹھا ہوتا ہے", notes: "Most quoted Urdu proverb.", targetLang: "ur"),
            DeckCard(english: "The tongue has no bones", spanish: "زبان کی کوئی ہڈی نہیں ہوتی", notes: "Words cause more damage than force.", targetLang: "ur"),
            DeckCard(english: "Drop by drop fills the ocean", spanish: "قطرہ قطرہ دریا بنتا ہے", notes: "Small efforts lead to great results.", targetLang: "ur"),
            DeckCard(english: "Where there's a will, there's a way", spanish: "جہاں چاہ وہاں راہ", notes: "Said by parents and teachers daily.", targetLang: "ur"),
            DeckCard(english: "Knowledge is light", spanish: "علم نور ہے", notes: "Short, powerful, universal.", targetLang: "ur"),
            DeckCard(english: "The fruitful tree bows down", spanish: "پھل دار درخت جھکتا ہے", notes: "Successful people stay humble.", targetLang: "ur"),
            DeckCard(english: "The pen is the tongue of the mind", spanish: "قلم ذہن کی زبان ہے", notes: "Writing reveals true thoughts.", targetLang: "ur"),
            DeckCard(english: "A friend in need is a friend indeed", spanish: "مصیبت میں کام آنے والا ہی اصلی دوست ہے", notes: "True friendship tested in hard times.", targetLang: "ur"),
            DeckCard(english: "The world is a traveler's inn", spanish: "دنیا ایک مسافر خانہ ہے", notes: "Life is temporary.", targetLang: "ur"),
            DeckCard(english: "Who digs a pit falls in it", spanish: "جو دوسروں کے لیے گڑھا کھودتا ہے وہ خود اس میں گرتا ہے", notes: "Karma.", targetLang: "ur"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Departed from this world", spanish: "وہ اس دنیا سے رخصت ہو گئے", notes: "Respectful euphemism for death.", targetLang: "ur"),
            DeckCard(english: "She is with hope", spanish: "وہ امید سے ہیں", notes: "Classic way to say pregnant.", targetLang: "ur"),
            DeckCard(english: "His gaze wanders", spanish: "اس کی نظر چلتی ہے", notes: "Checks everyone out.", targetLang: "ur"),
            DeckCard(english: "Things happen behind closed doors", spanish: "بند کمرے میں سب ہوتا ہے", notes: "Implying sexual activity.", targetLang: "ur"),
            DeckCard(english: "Eats from both sides", spanish: "وہ دونوں طرف سے کھاتا ہے", notes: "A double-dealer.", targetLang: "ur"),
            DeckCard(english: "Magic in his tongue", spanish: "اس کی زبان میں جادو ہے", notes: "Charming but possibly manipulative.", targetLang: "ur"),
            DeckCard(english: "Airing family secrets", spanish: "گھر کی بات باہر نکالنا", notes: "Strongly frowned upon.", targetLang: "ur"),
            DeckCard(english: "Under the table business", spanish: "میز کے نیچے کا کاروبار", notes: "Corruption or bribes.", targetLang: "ur"),
            DeckCard(english: "She's seen the world", spanish: "وہ دنیا دیکھ چکی ہے", notes: "Experienced — sometimes judgmental.", targetLang: "ur"),
            DeckCard(english: "He's derailed", spanish: "وہ پٹری سے اتر گیا", notes: "Lost his way morally.", targetLang: "ur"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "You're very beautiful", spanish: "آپ بہت خوبصورت ہیں", notes: "Formal aap shows respect.", targetLang: "ur"),
            DeckCard(english: "Your eyes are intoxicating", spanish: "آپ کی آنکھیں نشیلی ہیں", notes: "Classic Urdu poetic compliment.", targetLang: "ur"),
            DeckCard(english: "Shall we have tea?", spanish: "کیا ہم ساتھ چائے پیئیں؟", notes: "Universal social invitation.", targetLang: "ur"),
            DeckCard(english: "My heart beats for you", spanish: "میرا دل آپ کے لیے دھڑکتا ہے", notes: "Urdu poetry comes alive.", targetLang: "ur"),
            DeckCard(english: "You are my moon", spanish: "تم میرا چاند ہو", notes: "Highest beauty compliment.", targetLang: "ur"),
            DeckCard(english: "I can't live without you", spanish: "میں تمہارے بغیر نہیں رہ سکتا", notes: "Dramatic but genuinely said.", targetLang: "ur"),
            DeckCard(english: "You stole my heart", spanish: "تم نے میرا دل چرا لیا", notes: "Playful and flirtatious.", targetLang: "ur"),
            DeckCard(english: "I love you", spanish: "مجھے تم سے محبت ہے", notes: "Mohabbat is the deepest form.", targetLang: "ur"),
            DeckCard(english: "You are my life", spanish: "تم میری جان ہو", notes: "Jaan — most common endearment.", targetLang: "ur"),
            DeckCard(english: "I think about you day and night", spanish: "میں دن رات آپ کے بارے میں سوچتا ہوں", notes: "Deeply romantic.", targetLang: "ur"),
        ]
        }
    }

    // MARK: - Swahili
    static func swahili(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Unity is strength", spanish: "Umoja ni nguvu", notes: "Printed on Tanzanian currency.", targetLang: "sw"),
            DeckCard(english: "A patient person eats ripe fruit", spanish: "Mvumilivu hula mbivu", notes: "Patience pays off.", targetLang: "sw"),
            DeckCard(english: "Little by little fills the pot", spanish: "Haba na haba hujaza kibaba", notes: "Small efforts add up.", targetLang: "sw"),
            DeckCard(english: "He who doesn't travel praises mother's cooking", spanish: "Asiyesafiri, husifiu nyumbani", notes: "Experience the world.", targetLang: "sw"),
            DeckCard(english: "Education has no end", spanish: "Elimu haina mwisho", notes: "Learning is lifelong.", targetLang: "sw"),
            DeckCard(english: "A wise man sees, not told", spanish: "Mwenye akili haambiwi, huona", notes: "Smart people observe.", targetLang: "sw"),
            DeckCard(english: "Love has no conditions", spanish: "Penzi halina masharti", notes: "Unconditional love.", targetLang: "sw"),
            DeckCard(english: "The asker has no debt", spanish: "Atuliaye hana deni", notes: "Asking for help is wise.", targetLang: "sw"),
            DeckCard(english: "A debt is not forgotten", spanish: "Deni si mlango", notes: "Must be repaid.", targetLang: "sw"),
            DeckCard(english: "Don't throw dirty water before getting clean", spanish: "Usitupe maji machafu hujapata masafi", notes: "Don't abandon what you have.", targetLang: "sw"),
        ]
        case .euphemisms: return [
            DeckCard(english: "He has rested", spanish: "Amepumzika", notes: "Gentle way to say died.", targetLang: "sw"),
            DeckCard(english: "They're tasting each other", spanish: "Wanaonjana", notes: "Implying sexual relationship.", targetLang: "sw"),
            DeckCard(english: "She has a pregnancy", spanish: "Ana mimba", notes: "Softer way to say pregnant.", targetLang: "sw"),
            DeckCard(english: "Long hands", spanish: "Ana mikono mirefu", notes: "Steals or takes what isn't his.", targetLang: "sw"),
            DeckCard(english: "She's gone around a lot", spanish: "Amezunguka sana", notes: "Implying sexual experience.", targetLang: "sw"),
            DeckCard(english: "Eating from two plates", spanish: "Anakula sahani mbili", notes: "Cheating or being corrupt.", targetLang: "sw"),
            DeckCard(english: "Night business", spanish: "Biashara ya usiku", notes: "Euphemism for sex work.", targetLang: "sw"),
            DeckCard(english: "Has two tongues", spanish: "Ana ulimi mbili", notes: "A liar or double-dealer.", targetLang: "sw"),
            DeckCard(english: "They entered the room", spanish: "Waliingia chumbani", notes: "Obvious subtext.", targetLang: "sw"),
            DeckCard(english: "Playing with fire", spanish: "Anacheza na moto", notes: "Taking dangerous risks.", targetLang: "sw"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "You're beautiful", spanish: "Uko mzuri sana", notes: "Works for any gender.", targetLang: "sw"),
            DeckCard(english: "Can I get your number?", spanish: "Naweza kupata namba yako?", notes: "Direct — standard.", targetLang: "sw"),
            DeckCard(english: "I like you", spanish: "Ninakupenda kidogo", notes: "I love you a little.", targetLang: "sw"),
            DeckCard(english: "Let's go for a walk", spanish: "Twende kutembea", notes: "Casual romantic invitation.", targetLang: "sw"),
            DeckCard(english: "Beautiful smile", spanish: "Una tabasamu nzuri sana", notes: "Safe opener.", targetLang: "sw"),
            DeckCard(english: "I miss you", spanish: "Ninakukumbusha", notes: "Freely expressed.", targetLang: "sw"),
            DeckCard(english: "You make my heart happy", spanish: "Unafurahisha moyo wangu", notes: "Romantic and poetic.", targetLang: "sw"),
            DeckCard(english: "My darling", spanish: "Mpenzi wangu", notes: "Standard endearment.", targetLang: "sw"),
            DeckCard(english: "I love you", spanish: "Nakupenda", notes: "Said warmly and often.", targetLang: "sw"),
            DeckCard(english: "You are my everything", spanish: "Wewe ni kila kitu kwangu", notes: "Deep commitment.", targetLang: "sw"),
        ]
        }
    }

    // MARK: - Thai
    static func thai(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Still waters run deep", spanish: "น้ำนิ่งไหลลึก", notes: "Quiet but very capable.", targetLang: "th"),
            DeckCard(english: "Slow and steady wins", spanish: "ช้าๆ ได้พร้าเล่มงาม", notes: "Patience produces best results.", targetLang: "th"),
            DeckCard(english: "You reap what you sow", spanish: "ทำดีได้ดี ทำชั่วได้ชั่ว", notes: "Karmic principle — Thai Buddhist culture.", targetLang: "th"),
            DeckCard(english: "Enter city of blind, close your eyes", spanish: "เข้าเมืองตาหลิ่ว ต้องหลิ่วตาตาม", notes: "When in Rome.", targetLang: "th"),
            DeckCard(english: "A bird in hand", spanish: "สิบเบี้ยใกล้มือ", notes: "Value what you have.", targetLang: "th"),
            DeckCard(english: "One rotten fish spoils the basket", spanish: "ปลาเน่าตัวเดียวเหม็นทั้งข้อง", notes: "One bad person ruins the group.", targetLang: "th"),
            DeckCard(english: "Barking dogs don't bite", spanish: "หมาเห่าไม่กัด หมากัดไม่เห่า", notes: "Dangerous ones are quiet.", targetLang: "th"),
            DeckCard(english: "Seize the opportunity", spanish: "น้ำขึ้นให้รีบตัก", notes: "Don't hesitate.", targetLang: "th"),
            DeckCard(english: "Don't judge by cover", spanish: "อย่าดูถูกน้ำบ่อหน้า", notes: "Don't underestimate.", targetLang: "th"),
            DeckCard(english: "Using elephant to catch grasshopper", spanish: "ขี่ช้างจับตั๊กแตน", notes: "Excessive force for small task.", targetLang: "th"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Go water the flowers", spanish: "ไปรดน้ำต้นไม้", notes: "Going to the bathroom.", targetLang: "th"),
            DeckCard(english: "Eating outside", spanish: "กินข้าวนอกบ้าน", notes: "Cheating on partner.", targetLang: "th"),
            DeckCard(english: "Has a side dish", spanish: "มีกับข้าว", notes: "Lover on the side.", targetLang: "th"),
            DeckCard(english: "Sweet mouth", spanish: "ปากหวาน", notes: "Smooth-talks to get what they want.", targetLang: "th"),
            DeckCard(english: "Sells dreams", spanish: "ขายฝัน", notes: "Big romantic promises they won't keep.", targetLang: "th"),
            DeckCard(english: "Release the fish", spanish: "ปล่อยปลา", notes: "Letting someone go.", targetLang: "th"),
            DeckCard(english: "Close the lights early", spanish: "ปิดไฟเร็ว", notes: "Went to bed early — obvious reasons.", targetLang: "th"),
            DeckCard(english: "Go see the stars", spanish: "ไปดูดาว", notes: "Romantic rendezvous.", targetLang: "th"),
            DeckCard(english: "Sharpen the pencil", spanish: "เหลาดินสอ", notes: "Cheeky innuendo.", targetLang: "th"),
            DeckCard(english: "The house is flooding", spanish: "น้ำท่วม", notes: "Very attracted to someone.", targetLang: "th"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "I have a crush on you", spanish: "ฉันแอบชอบเธอ", notes: "Secretly like you.", targetLang: "th"),
            DeckCard(english: "Can I have your LINE?", spanish: "ขอไลน์ได้ไหม", notes: "LINE is Thailand's main app.", targetLang: "th"),
            DeckCard(english: "You're very cute", spanish: "เธอน่ารักมาก", notes: "Go-to compliment.", targetLang: "th"),
            DeckCard(english: "Are you seeing anyone?", spanish: "มีแฟนหรือยัง", notes: "Socially normal to ask.", targetLang: "th"),
            DeckCard(english: "I miss you", spanish: "คิดถึงเธอ", notes: "Think of you.", targetLang: "th"),
            DeckCard(english: "Want to grab food?", spanish: "ไปกินข้าวด้วยกันไหม", notes: "Food is the way in.", targetLang: "th"),
            DeckCard(english: "My heart is fluttering", spanish: "ใจเต้นแรง", notes: "Butterflies.", targetLang: "th"),
            DeckCard(english: "I like your smile", spanish: "ชอบรอยยิ้มของเธอ", notes: "Safe charming compliment.", targetLang: "th"),
            DeckCard(english: "You make me happy", spanish: "เธอทำให้ฉันมีความสุข", notes: "Sweet and sincere.", targetLang: "th"),
            DeckCard(english: "Be my girlfriend/boyfriend?", spanish: "เป็นแฟนกันไหม", notes: "The official DTR.", targetLang: "th"),
        ]
        }
    }

    // MARK: - Persian
    static func persian(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Patience is the key to relief", spanish: "صبر کلید فرج است", notes: "Most common Persian saying.", targetLang: "fa"),
            DeckCard(english: "Walls have mice, mice have ears", spanish: "دیوار موش داره، موش هم گوش داره", notes: "Be careful what you say.", targetLang: "fa"),
            DeckCard(english: "Drop by drop, a river forms", spanish: "قطره قطره جمع گردد وانگهی دریا شود", notes: "From poet Sa'di.", targetLang: "fa"),
            DeckCard(english: "This too shall pass", spanish: "این نیز بگذرد", notes: "Originally Persian — famous worldwide.", targetLang: "fa"),
            DeckCard(english: "One hand doesn't clap", spanish: "یک دست صدا نداره", notes: "Need cooperation.", targetLang: "fa"),
            DeckCard(english: "Every head has a different headache", spanish: "هر سری یه دردی داره", notes: "Everyone has problems.", targetLang: "fa"),
            DeckCard(english: "Apple doesn't fall far", spanish: "سیب که از درخت افتاد، دور نمی‌افته", notes: "Children resemble parents.", targetLang: "fa"),
            DeckCard(english: "A friend in need", spanish: "دوست آن باشد که گیرد دست دوست در پریشان‌حالی و درماندگی", notes: "From Sa'di's Golestan.", targetLang: "fa"),
            DeckCard(english: "Our problems come from ourselves", spanish: "از ماست که بر ماست", notes: "Self-accountability.", targetLang: "fa"),
            DeckCard(english: "Measure twice, cut once", spanish: "تا نبری نمی‌تونی بدوزی", notes: "Think before acting.", targetLang: "fa"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Big nose (arrogant)", spanish: "دماغش بزرگه", notes: "Not about actual nose.", targetLang: "fa"),
            DeckCard(english: "Hat screwed on tight (stingy)", spanish: "کلاهش سفته", notes: "Won't spend money.", targetLang: "fa"),
            DeckCard(english: "Watermelon under arm (flattery)", spanish: "زیر بغلش هندونه گذاشتن", notes: "Puffed up from flattery.", targetLang: "fa"),
            DeckCard(english: "Pepper is hot (feisty)", spanish: "فلفلش تنده", notes: "Easily angered.", targetLang: "fa"),
            DeckCard(english: "Eaten someone's brain", spanish: "مغزشو خورده", notes: "Nagged relentlessly.", targetLang: "fa"),
            DeckCard(english: "A screw is loose", spanish: "یه پیچش شله", notes: "A bit crazy.", targetLang: "fa"),
            DeckCard(english: "Oil well drilled", spanish: "چاه نفتش زدن", notes: "Suddenly got rich.", targetLang: "fa"),
            DeckCard(english: "Read someone's receipt", spanish: "رسیدشو خوندن", notes: "Exposed their nonsense.", targetLang: "fa"),
            DeckCard(english: "Strong antenna", spanish: "آنتنش قویه", notes: "Perceptive or nosy.", targetLang: "fa"),
            DeckCard(english: "Cat got their tongue", spanish: "گربه زبونشو خورده", notes: "Nothing to say.", targetLang: "fa"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "I'm crazy about you", spanish: "دیوونتم", notes: "I'm your crazy one.", targetLang: "fa"),
            DeckCard(english: "Light of my eyes", spanish: "نور چشممی", notes: "Deeply affectionate.", targetLang: "fa"),
            DeckCard(english: "I'd die for you", spanish: "فدات بشم", notes: "Not literal — common endearment.", targetLang: "fa"),
            DeckCard(english: "You stole my heart", spanish: "دلمو بردی", notes: "Completely captivated.", targetLang: "fa"),
            DeckCard(english: "Can I see you again?", spanish: "میتونم دوباره ببینمت؟", notes: "Polite and hopeful.", targetLang: "fa"),
            DeckCard(english: "You're very beautiful", spanish: "خیلی خوشگلی", notes: "Works for any gender.", targetLang: "fa"),
            DeckCard(english: "My heart beats for you", spanish: "قلبم برات میتپه", notes: "Romantic and poetic.", targetLang: "fa"),
            DeckCard(english: "Can't stop thinking about you", spanish: "نمیتونم بهت فکر نکنم", notes: "Early stages of falling.", targetLang: "fa"),
            DeckCard(english: "You warm my heart", spanish: "دلمو گرم میکنی", notes: "You bring comfort and joy.", targetLang: "fa"),
            DeckCard(english: "Will you go out with me?", spanish: "میای بریم بیرون؟", notes: "Casual date invitation.", targetLang: "fa"),
        ]
        }
    }

    // MARK: - Malay
    static func malay(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Calm water may have crocodiles", spanish: "Air tenang jangan disangka tiada buaya", notes: "Don't be deceived by appearances.", targetLang: "ms"),
            DeckCard(english: "Prepare umbrella before rain", spanish: "Sediakan payung sebelum hujan", notes: "Extremely common advice.", targetLang: "ms"),
            DeckCard(english: "United we stand", spanish: "Bersatu kita teguh, bercerai kita roboh", notes: "National-level proverb.", targetLang: "ms"),
            DeckCard(english: "Frog under coconut shell", spanish: "Bagai katak di bawah tempurung", notes: "Narrow-minded person.", targetLang: "ms"),
            DeckCard(english: "Where there's a will, there's a way", spanish: "Di mana ada kemahuan, di situ ada jalan", notes: "Motivational.", targetLang: "ms"),
            DeckCard(english: "One hand can't clap", spanish: "Bertepuk sebelah tangan", notes: "It takes two.", targetLang: "ms"),
            DeckCard(english: "Hold burning coal until charcoal", spanish: "Genggam bara api biar sampai jadi arang", notes: "Persevere through hardship.", targetLang: "ms"),
            DeckCard(english: "Already fell, ladder fell on you", spanish: "Sudah jatuh ditimpa tangga", notes: "When bad luck compounds.", targetLang: "ms"),
            DeckCard(english: "Nail that sticks up gets hammered", spanish: "Paku yang terkeluar akan dipukul", notes: "Don't stand out too much.", targetLang: "ms"),
            DeckCard(english: "Don't rely on other's fences", spanish: "Jangan mengharap pagar orang", notes: "Depend on yourself.", targetLang: "ms"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Go see flowers", spanish: "Pergi tengok bunga", notes: "Going to the bathroom.", targetLang: "ms"),
            DeckCard(english: "Eating outside", spanish: "Makan luar", notes: "Having an affair.", targetLang: "ms"),
            DeckCard(english: "Thick face", spanish: "Muka tebal", notes: "Shameless.", targetLang: "ms"),
            DeckCard(english: "Big head", spanish: "Kepala besar", notes: "Arrogant.", targetLang: "ms"),
            DeckCard(english: "Already kena", spanish: "Sudah kena", notes: "Got caught or in trouble.", targetLang: "ms"),
            DeckCard(english: "Throw smoke", spanish: "Lepas asap", notes: "Bluff or deceive.", targetLang: "ms"),
            DeckCard(english: "Warm like chicken poop", spanish: "Hangat-hangat tahi ayam", notes: "Enthusiasm that fades quickly.", targetLang: "ms"),
            DeckCard(english: "Crooked mouth (gossip)", spanish: "Mulut tempayan", notes: "Can't keep secrets.", targetLang: "ms"),
            DeckCard(english: "Big cannon", spanish: "Bawa meriam besar", notes: "Bragging excessively.", targetLang: "ms"),
            DeckCard(english: "Coconut shell has eyes", spanish: "Tempurung pun ada mata", notes: "Secrets come out.", targetLang: "ms"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "I like you", spanish: "Saya suka awak", notes: "Awak = affectionate 'you'.", targetLang: "ms"),
            DeckCard(english: "You're very pretty/handsome", spanish: "Awak cantik/kacak sangat", notes: "Cantik (f), kacak (m).", targetLang: "ms"),
            DeckCard(english: "Can I get your number?", spanish: "Boleh bagi nombor tak?", notes: "Casual and natural.", targetLang: "ms"),
            DeckCard(english: "Want to eat together?", spanish: "Nak pergi makan sama tak?", notes: "Food is the way.", targetLang: "ms"),
            DeckCard(english: "I miss you", spanish: "Saya rindu awak", notes: "Rindu carries deep longing.", targetLang: "ms"),
            DeckCard(english: "My heart is blooming", spanish: "Awak buat hati saya berbunga", notes: "Poetic romantic expression.", targetLang: "ms"),
            DeckCard(english: "Are you single?", spanish: "Awak single ke?", notes: "Malay-English mix is normal.", targetLang: "ms"),
            DeckCard(english: "Can't stop thinking about you", spanish: "Saya tak boleh berhenti fikir pasal awak", notes: "Earnest and sweet.", targetLang: "ms"),
            DeckCard(english: "You're the one in my heart", spanish: "Awak yang di hati saya", notes: "Serious declaration.", targetLang: "ms"),
            DeckCard(english: "I love you", spanish: "Saya sayang awak", notes: "Sayang = love and darling.", targetLang: "ms"),
        ]
        }
    }

    // MARK: - Filipino
    static func filipino(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Look back where you came from", spanish: "Ang hindi marunong lumingon sa pinanggalingan ay hindi makararating sa paroroonan", notes: "By José Rizal — most famous proverb.", targetLang: "tl"),
            DeckCard(english: "No hard task for someone who strives", spanish: "Walang mahirap sa taong may tiyaga", notes: "Persistence conquers all.", targetLang: "tl"),
            DeckCard(english: "What the tree is, so is the fruit", spanish: "Kung ano ang puno, siya ang bunga", notes: "Apple and tree equivalent.", targetLang: "tl"),
            DeckCard(english: "Better hurt by truth than comforted by lie", spanish: "Mas mabuti ang masakit na totoo kaysa matamis na kasinungalingan", notes: "Filipinos value honesty.", targetLang: "tl"),
            DeckCard(english: "Little finger pain felt by whole body", spanish: "Ang sakit ng kalingkingan ay ramdam ng buong katawan", notes: "Community matters.", targetLang: "tl"),
            DeckCard(english: "Don't put off tomorrow", spanish: "Huwag ipagpabukas ang magagawa ngayon", notes: "Classic productivity proverb.", targetLang: "tl"),
            DeckCard(english: "Better to bend than break", spanish: "Mabuti ang mag-inat kaysa mabali", notes: "Flexibility is a virtue.", targetLang: "tl"),
            DeckCard(english: "What use is grass if horse is dead", spanish: "Aanhin pa ang damo kung patay na ang kabayo", notes: "Don't act when it's too late.", targetLang: "tl"),
            DeckCard(english: "Shallow waters make most noise", spanish: "Mababaw ang tubig kung magkalat ang bula", notes: "Those who talk most know least.", targetLang: "tl"),
            DeckCard(english: "Broom strands bound tightly are sturdy", spanish: "Wala kang matatapang na walis kung walang magkakadikit na tingting", notes: "Unity makes strength.", targetLang: "tl"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Freshening up", spanish: "Magpapa-fresh lang", notes: "Going to the bathroom.", targetLang: "tl"),
            DeckCard(english: "Playing outside", spanish: "Naglalaro sa labas", notes: "Cheating on partner.", targetLang: "tl"),
            DeckCard(english: "Thick-skinned", spanish: "Makapal ang mukha", notes: "Most common put-down.", targetLang: "tl"),
            DeckCard(english: "Green mind", spanish: "May malaswang isip", notes: "Someone with dirty mind.", targetLang: "tl"),
            DeckCard(english: "Blood is hot", spanish: "Mainit ang dugo", notes: "Angry or hot-tempered.", targetLang: "tl"),
            DeckCard(english: "Swallowed by the earth", spanish: "Nilamon ng lupa", notes: "Disappeared without trace.", targetLang: "tl"),
            DeckCard(english: "Butterfly", spanish: "Mariposa", notes: "Player who goes person to person.", targetLang: "tl"),
            DeckCard(english: "Got bitten", spanish: "Nakagat", notes: "Got tricked or scammed.", targetLang: "tl"),
            DeckCard(english: "Riding the boat", spanish: "Sumasakay sa bangka", notes: "Going along or flirting.", targetLang: "tl"),
            DeckCard(english: "Roof is leaking", spanish: "Tumutulo ang bubong", notes: "Something scandalous happening.", targetLang: "tl"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "You're so beautiful/handsome", spanish: "Ang ganda/gwapo mo", notes: "Ganda (f), gwapo (m).", targetLang: "tl"),
            DeckCard(english: "Can I court you?", spanish: "Pwede ba kitang ligawan?", notes: "Traditional courtship gesture.", targetLang: "tl"),
            DeckCard(english: "I have a crush on you", spanish: "Na-crush kita", notes: "Taglish and natural.", targetLang: "tl"),
            DeckCard(english: "You make my heart flutter", spanish: "Kinikilig ako sa'yo", notes: "Kilig — untranslatable giddy thrill.", targetLang: "tl"),
            DeckCard(english: "Want to grab coffee?", spanish: "Gusto mo bang mag-coffee tayo?", notes: "Taglish is natural.", targetLang: "tl"),
            DeckCard(english: "I miss you so much", spanish: "Miss na miss na kita", notes: "Doubling intensifies longing.", targetLang: "tl"),
            DeckCard(english: "You're my type", spanish: "Type kita", notes: "Direct Taglish.", targetLang: "tl"),
            DeckCard(english: "I love you", spanish: "Mahal kita", notes: "Mahal = love and precious.", targetLang: "tl"),
            DeckCard(english: "Are you seeing anyone?", spanish: "May jowa ka na ba?", notes: "Jowa = boyfriend/girlfriend.", targetLang: "tl"),
            DeckCard(english: "Always on my mind", spanish: "Lagi kitang naiisip", notes: "Falling hard.", targetLang: "tl"),
        ]
        }
    }

    // MARK: - Afrikaans
    static func afrikaans(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Every pot finds its lid", spanish: "Elke pot kry sy deksel", notes: "Everyone finds their match.", targetLang: "af"),
            DeckCard(english: "A monkey in silk is still a monkey", spanish: "'n Aap bly 'n aap, al dra hy 'n goue ring", notes: "Can't change nature.", targetLang: "af"),
            DeckCard(english: "Barking dogs don't bite", spanish: "Blaffende honde byt nie", notes: "Threats rarely follow through.", targetLang: "af"),
            DeckCard(english: "Practice makes the master", spanish: "Oefening maak die meester", notes: "Used constantly.", targetLang: "af"),
            DeckCard(english: "What you sow, you reap", spanish: "Soos jy saai, so sal jy maai", notes: "Biblical but everyday.", targetLang: "af"),
            DeckCard(english: "Better a bird in hand", spanish: "Beter 'n voël in die hand as tien in die lug", notes: "Practical perspective.", targetLang: "af"),
            DeckCard(english: "Empty vessels make most noise", spanish: "Leë vate maak die meeste geraas", notes: "Least knowledge talks most.", targetLang: "af"),
            DeckCard(english: "Apple doesn't fall far", spanish: "Die appel val nie ver van die boom af nie", notes: "Most-used Afrikaans saying.", targetLang: "af"),
            DeckCard(english: "Morning hour has gold in its mouth", spanish: "Die môre-uur het goud in sy mond", notes: "Early risers succeed.", targetLang: "af"),
            DeckCard(english: "All roads lead to Rome", spanish: "Alle paaie lei na Rome", notes: "More than one way.", targetLang: "af"),
        ]
        case .euphemisms: return [
            DeckCard(english: "See a man about a dog", spanish: "Ek gaan vir 'n man oor 'n hond sien", notes: "Going to bathroom or pub.", targetLang: "af"),
            DeckCard(english: "Cheese slipped off cracker", spanish: "Sy kaas het van sy cracker gegly", notes: "Lost the plot.", targetLang: "af"),
            DeckCard(english: "They're baking", spanish: "Hulle bak", notes: "Making out or hooking up.", targetLang: "af"),
            DeckCard(english: "Thick lip (sulking)", spanish: "Dik lip", notes: "In a bad mood.", targetLang: "af"),
            DeckCard(english: "Lights on, nobody home", spanish: "Die ligte brand maar niemand is tuis nie", notes: "Zoned out.", targetLang: "af"),
            DeckCard(english: "Throwing eyes", spanish: "Oë gooi", notes: "Flirting with glances.", targetLang: "af"),
            DeckCard(english: "Baboon came off the mountain", spanish: "Die bobbejaan het van die berg afgekom", notes: "Acting wild.", targetLang: "af"),
            DeckCard(english: "Warm under the collar", spanish: "Warm onder die kraag", notes: "Getting flustered.", targetLang: "af"),
            DeckCard(english: "Hide and seek with truth", spanish: "Wegkruipertjie speel met die waarheid", notes: "Being evasive.", targetLang: "af"),
            DeckCard(english: "Under the weather", spanish: "Onder die weer", notes: "Sick or hungover.", targetLang: "af"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "I'm very fond of you", spanish: "Ek is baie lief vir jou", notes: "Between like and love.", targetLang: "af"),
            DeckCard(english: "You're gorgeous", spanish: "Jy is pragtig", notes: "Strong compliment.", targetLang: "af"),
            DeckCard(english: "Want to go for drinkies?", spanish: "Wil jy gaan drinkies drink?", notes: "Very Afrikaans diminutive.", targetLang: "af"),
            DeckCard(english: "You give me butterflies", spanish: "Jy gee my bottervlieë", notes: "That fluttery feeling.", targetLang: "af"),
            DeckCard(english: "Can't stop thinking about you", spanish: "Ek kan nie ophou aan jou dink nie", notes: "Properly smitten.", targetLang: "af"),
            DeckCard(english: "Can I take you out?", spanish: "Kan ek jou uit neem?", notes: "Traditional date invitation.", targetLang: "af"),
            DeckCard(english: "Beautiful eyes", spanish: "Jy het pragtige oë", notes: "Classic compliment.", targetLang: "af"),
            DeckCard(english: "I love you", spanish: "Ek het jou lief", notes: "Carries weight.", targetLang: "af"),
            DeckCard(english: "Are you single?", spanish: "Is jy enkellopend?", notes: "Walking alone.", targetLang: "af"),
            DeckCard(english: "You're my person", spanish: "Jy is my mens", notes: "Intimate and modern.", targetLang: "af"),
        ]
        }
    }

    // MARK: - Tamil
    static func tamil(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Even an ant can hurt an elephant", spanish: "எறும்பும் தன் கையால் எண்ணெய் வழிக்கும்", notes: "Never underestimate anyone.", targetLang: "ta"),
            DeckCard(english: "Words and arrows can't be taken back", spanish: "விட்ட அம்பும் சொன்ன சொல்லும் திரும்பாது", notes: "Think before you speak.", targetLang: "ta"),
            DeckCard(english: "Education is a boundless ocean", spanish: "கல்வி கரையில கடல்", notes: "Most valued Tamil proverb.", targetLang: "ta"),
            DeckCard(english: "Patience can dry up the ocean", spanish: "பொறுமை கடலையும் வற்றடிக்கும்", notes: "Extreme patience conquers all.", targetLang: "ta"),
            DeckCard(english: "One bad fish spoils the pond", spanish: "ஒரு கெட்ட மீன் குளத்தை கெடுக்கும்", notes: "One bad influence ruins the group.", targetLang: "ta"),
            DeckCard(english: "Those who seek will find", spanish: "தேடுவோர் கண்டு பிடிப்பார்", notes: "Persistence in searching.", targetLang: "ta"),
            DeckCard(english: "Thousand-mile journey starts with one step", spanish: "ஆயிரம் மைல் பயணம் ஒரு அடியில் தொடங்கும்", notes: "Tamil equivalent of Lao Tzu.", targetLang: "ta"),
            DeckCard(english: "Still water runs deep", spanish: "சும்மா இருக்கிற தண்ணீர் ஆழமா இருக்கும்", notes: "Quiet people have depth.", targetLang: "ta"),
            DeckCard(english: "You reap what you sow", spanish: "விதைத்ததை அறுப்பாய்", notes: "Karmic principle in Tamil culture.", targetLang: "ta"),
            DeckCard(english: "Even a crow is beautiful to its mother", spanish: "தன் குழந்தை காக்கையும் அழகுதான்", notes: "Universal parental love.", targetLang: "ta"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Long nose (nosy)", spanish: "நீளமான மூக்கு", notes: "Pokes into everyone's business.", targetLang: "ta"),
            DeckCard(english: "Eating someone's head", spanish: "தலையை சாப்பிடுறான்", notes: "Nagging relentlessly.", targetLang: "ta"),
            DeckCard(english: "Gone to the temple", spanish: "கோயிலுக்கு போயிருக்கு", notes: "Polite excuse for being away.", targetLang: "ta"),
            DeckCard(english: "Thick-skinned", spanish: "தோல் தடிச்சவன்", notes: "Doesn't care about criticism.", targetLang: "ta"),
            DeckCard(english: "Dancing on someone's head", spanish: "தலையில ஆடுறான்", notes: "Taking advantage.", targetLang: "ta"),
            DeckCard(english: "Showing teeth", spanish: "பல்லை காட்டுறான்", notes: "Grinning fakely.", targetLang: "ta"),
            DeckCard(english: "Pouring oil", spanish: "எண்ணெய் விடுறான்", notes: "Buttering up.", targetLang: "ta"),
            DeckCard(english: "The lamp is going out", spanish: "விளக்கு அணையப் போகுது", notes: "About to fall asleep.", targetLang: "ta"),
            DeckCard(english: "Twisted tongue", spanish: "நாக்கு சுளிக்குது", notes: "Gossips or lies.", targetLang: "ta"),
            DeckCard(english: "Eyes are rotating", spanish: "கண்ணு சுத்துது", notes: "Checking someone out.", targetLang: "ta"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "I like you", spanish: "நான் உன்னை விரும்புகிறேன்", notes: "Formal Tamil for sincere feelings.", targetLang: "ta"),
            DeckCard(english: "You're very beautiful", spanish: "நீ ரொம்ப அழகா இருக்க", notes: "Casual spoken Tamil.", targetLang: "ta"),
            DeckCard(english: "Can I see you again?", spanish: "மறுபடியும் உன்னை பார்க்கலாமா?", notes: "Polite and hopeful.", targetLang: "ta"),
            DeckCard(english: "Always on my mind", spanish: "நீ எப்பவும் என் நினைவுல இருக்க", notes: "Colloquial and romantic.", targetLang: "ta"),
            DeckCard(english: "My heart beats for you", spanish: "என் இதயம் உனக்காக துடிக்குது", notes: "Poetic and dramatic.", targetLang: "ta"),
            DeckCard(english: "Want to go for coffee?", spanish: "காபி குடிக்க போலாமா?", notes: "Coffee culture runs deep.", targetLang: "ta"),
            DeckCard(english: "You make me smile", spanish: "நீ என்னை சிரிக்க வைக்குற", notes: "Natural and warm.", targetLang: "ta"),
            DeckCard(english: "I love you", spanish: "நான் உன்னை காதலிக்கிறேன்", notes: "Kaadhal = romantic love.", targetLang: "ta"),
            DeckCard(english: "You stole my heart", spanish: "என் மனசை திருடிட்ட", notes: "Playful — Kollywood classic.", targetLang: "ta"),
            DeckCard(english: "Are you free this weekend?", spanish: "இந்த வார இறுதியில free-ஆ இருக்கியா?", notes: "Tanglish is the norm.", targetLang: "ta"),
        ]
        }
    }

    // MARK: - Catalan
    static func catalan(_ type: StarterDeckType) -> [DeckCard] {
        switch type {
        case .timelessAdages: return [
            DeckCard(english: "Slowly and with good handwriting", spanish: "A poc a poc i bona lletra", notes: "Take your time, do it right.", targetLang: "ca"),
            DeckCard(english: "No rose without thorns", spanish: "No hi ha rosa sense espines", notes: "Good things come with difficulties.", targetLang: "ca"),
            DeckCard(english: "Better alone than in bad company", spanish: "Més val sol que mal acompanyat", notes: "Most quoted Catalan proverb.", targetLang: "ca"),
            DeckCard(english: "Time puts everything in its place", spanish: "El temps ho posa tot al seu lloc", notes: "Commonly used as comfort.", targetLang: "ca"),
            DeckCard(english: "If you want fish, get your feet wet", spanish: "Qui vulgui peix, que es mulli el cul", notes: "Put in effort to get results.", targetLang: "ca"),
            DeckCard(english: "Bird in hand worth hundred flying", spanish: "Més val un ocell a la mà que cent que volen", notes: "Classic Catalan wisdom.", targetLang: "ca"),
            DeckCard(english: "Every house has its cross", spanish: "A cada casa hi ha la seva creu", notes: "Every family has problems.", targetLang: "ca"),
            DeckCard(english: "Words are carried by the wind", spanish: "Les paraules se les emporta el vent", notes: "Get it in writing.", targetLang: "ca"),
            DeckCard(english: "God helps those who help themselves", spanish: "Déu ajuda a qui s'ajuda", notes: "Deeply Catalan value.", targetLang: "ca"),
            DeckCard(english: "He who sleeps with children wakes wet", spanish: "Qui amb infants se colga, pixat s'aixeca", notes: "Associate with immature, get immature results.", targetLang: "ca"),
        ]
        case .euphemisms: return [
            DeckCard(english: "Change water for canary", spanish: "Anar a canviar l'aigua al canari", notes: "Going to the bathroom.", targetLang: "ca"),
            DeckCard(english: "Eating your brain", spanish: "Menjar-se el coco", notes: "Overthinking or worrying.", targetLang: "ca"),
            DeckCard(english: "Face of concrete", spanish: "Tenir la cara de ciment", notes: "Shameless.", targetLang: "ca"),
            DeckCard(english: "Having ants", spanish: "Tenir formigues", notes: "Can't sit still.", targetLang: "ca"),
            DeckCard(english: "Selling smoke", spanish: "Vendre fum", notes: "Making empty promises.", targetLang: "ca"),
            DeckCard(english: "Frying pan by the handle", spanish: "Tenir la paella pel mànec", notes: "Being in control.", targetLang: "ca"),
            DeckCard(english: "Making little eyes", spanish: "Fer ullets", notes: "Flirting with glances.", targetLang: "ca"),
            DeckCard(english: "Sleep with the chickens", spanish: "Anar a dormir amb les gallines", notes: "Going to bed very early.", targetLang: "ca"),
            DeckCard(english: "Having a monkey", spanish: "Tenir una mona", notes: "Drunk or hungover.", targetLang: "ca"),
            DeckCard(english: "Cat escaped the bag", spanish: "El gat ha sortit de la bossa", notes: "The secret is out.", targetLang: "ca"),
        ]
        case .datingAndRomance: return [
            DeckCard(english: "I like you", spanish: "M'agrades", notes: "Simple and direct.", targetLang: "ca"),
            DeckCard(english: "You're very pretty/handsome", spanish: "Ets molt bonica/guapo", notes: "Bonica (f), guapo (m).", targetLang: "ca"),
            DeckCard(english: "Want to grab a drink?", spanish: "Vols anar a prendre alguna cosa?", notes: "Catalan way to suggest drinks.", targetLang: "ca"),
            DeckCard(english: "Beautiful smile", spanish: "Tens un somriure molt bonic", notes: "Sincere and not over-the-top.", targetLang: "ca"),
            DeckCard(english: "Can't stop thinking about you", spanish: "No puc deixar de pensar en tu", notes: "Really falling for someone.", targetLang: "ca"),
            DeckCard(english: "I miss you", spanish: "Et trobo a faltar", notes: "I find you missing.", targetLang: "ca"),
            DeckCard(english: "Are you seeing anyone?", spanish: "Estàs amb algú?", notes: "Are you with someone?", targetLang: "ca"),
            DeckCard(english: "You make me happy", spanish: "Em fas feliç", notes: "Simple and powerful.", targetLang: "ca"),
            DeckCard(english: "I love you", spanish: "T'estimo", notes: "Immense emotional weight.", targetLang: "ca"),
            DeckCard(english: "Love of my life", spanish: "Ets l'amor de la meva vida", notes: "Reserved for serious relationships.", targetLang: "ca"),
        ]
        }
    }
}
