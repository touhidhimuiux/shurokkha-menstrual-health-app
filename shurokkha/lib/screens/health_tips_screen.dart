import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';
import '../services/language_provider.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  // Global visibility map for managing dropdown interactive card elements independently
  final Map<String, bool> _expandedStates = {
    'fluid': true,       // Keeps first card open for instructional layout visibility
    'seasons': false,
    'ph_defense': false,
    'nutrients': false,
    'red_flags': false,
  };

  // Failsafe Language Scanner
  bool _isBanglaActive(BuildContext context, dynamic provider) {
    try {
      if (Localizations.localeOf(context).languageCode == 'bn') return true;
    } catch (_) {}
    try {
      if (provider.locale.languageCode == 'bn') return true;
    } catch (_) {}
    try {
      if (provider.isBangla == true || provider.isBengali == true) return true;
    } catch (_) {}
    try {
      final testWord = context.translate('phase_menstruation');
      if (testWord != null && (testWord.contains('ঋতু') || testWord.contains('মাসিক'))) return true;
    } catch (_) {}
    return false;
  }

  // Failsafe Language Switch Handler 
  void _triggerLanguageToggle(BuildContext context, dynamic provider, bool currentIsBangla) {
    final String targetLang = currentIsBangla ? 'en' : 'bn';
    final Locale targetLocale = Locale(targetLang);

    try { provider.toggleLanguage(); return; } catch (_) {}
    try { provider.changeLanguage(targetLang); return; } catch (_) {}
    try { provider.setLocale(targetLocale); return; } catch (_) {}
    try { provider.changeLocale(targetLocale); return; } catch (_) {}
    try { provider.setLanguage(targetLang); return; } catch (_) {}
  }

  void _toggleCard(String key) {
    setState(() {
      _expandedStates[key] = !(_expandedStates[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = _isBanglaActive(context, languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF9),
      body: SafeArea(
        child: Column(
          children: [
            // Interactive App Control Top Bar Frame
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsivePadding(mobilePadding: 20),
                vertical: context.responsivePadding(mobilePadding: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B35B5).withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF331652),
                        size: 18,
                      ),
                    ),
                  ),
                  
                  // Functional High-Luminosity Language Selector Badge
                  GestureDetector(
                    onTap: () => _triggerLanguageToggle(context, languageProvider, isBangla),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B35B5).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: !isBangla ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: !isBangla ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            child: Text(
                              'EN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: !isBangla ? const Color(0xFF7B35B5) : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isBangla ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isBangla ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            child: Text(
                              'বাং',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isBangla ? const Color(0xFF7B35B5) : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Layout Header Content Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBangla ? 'নারী স্বাস্থ্য ও সুস্থতা তথ্য' : 'Female Health Insights',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF331652),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBangla ? 'কার্ডে ট্যাপ করে বিস্তারিত গাইডলাইন দেখুন' : 'Tap on cards to expand medical guidelines.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main Interactive Scroller Feed Field
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  
                  // CARD 1: Menstrual Fluid Color Analysis
                  _buildExpandableTipCard(
                    title: isBangla ? '১. ঋতুস্রাবের রক্তের রঙ বিশ্লেষণ' : '1. Menstrual Fluid Color Metrics',
                    icon: Icons.bloodtype_rounded,
                    gradientColors: [const Color(0xFFFF2A6D), const Color(0xFFFF62A5)],
                    isExpanded: _expandedStates['fluid'] ?? false,
                    onToggle: () => _toggleCard('fluid'),
                    children: [
                      _buildSubSection(
                        title: isBangla ? 'টকটকে লাল রঙ (১ম - ৩য় দিন):' : 'Bright Red Flow (Days 1–3):',
                        items: isBangla
                            ? ['এটি একটি সম্পূর্ণ স্বাভাবিক ও সুস্থ জরায়ু পরিষ্কারকরণ পর্যায় নির্দেশ করে।', 'এটি নিশ্চিত করে যে রক্ত দ্রুত শরীর থেকে বেরিয়ে আসছে।']
                            : ['Indicates a steady, fresh, normal velocity shed of the active uterine endometrium lining.', 'Represents clean and highly efficient uterine clearance.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'গাঢ় বাদামী বা কালচে রঙ:' : 'Dark Brown or Tinted Black:',
                        items: isBangla
                            ? ['এটি সাধারণত মাসিকের একদম শুরুতে বা শেষের দিকে দেখা যায়।', 'এটি আসলে পুরনো রক্ত যা জরায়ু থেকে দেরিতে বের হওয়ার কারণে অক্সিডাইজড হয়ে গেছে। এটি ক্ষতিকর নয়।']
                            : ['Commonly appears at the absolute beginning or the tail-end of your period cycle.', 'Older blood that took longer to exit the uterus, oxidizing safely along the way.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'হালকা গোলাপী বা পানির মতো পাতলা:' : 'Pale Pink or Watery Bleeding:',
                        items: isBangla
                            ? ['শরীরে ইস্ট্রোজেন হরমোনের মাত্রা কম থাকার এটি একটি অন্যতম লক্ষণ।', 'অতিরিক্ত ডায়েট, তীব্র ব্যায়াম বা রক্তস্বল্পতা (Anemia) থাকলে এমন হতে পারে।']
                            : ['Often a direct biological sign of low systemic estrogen levels.', 'Prevalent among intense athletes, sudden weight loss, or early signs of anemia.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'ধূসর বা দুর্গন্ধযুক্ত স্রাব 🚨:' : 'Grayish-Red / Foul Odor 🚨:',
                        items: isBangla
                            ? ['এটি জরায়ু বা যোনিপথে ব্যাকটেরিয়াল ভ্যাজাইনোসিস (BV) সংক্রমণের লক্ষণ হতে পারে।', 'অবিলম্বে একজন স্ত্রীরোগ বিশেষজ্ঞের (Gynecologist) পরামর্শ নেওয়া উচিত।']
                            : ['A key clinical indicator of an active pelvic infection or Bacterial Vaginosis (BV).', 'Requires immediate professional medical diagnostic verification.'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 2: The 4 Hormonal Seasons
                  _buildExpandableTipCard(
                    title: isBangla ? '২. হরমোনের ৪টি চক্র বা ঋতু' : '2. Mastering the 4 Hormonal Seasons',
                    icon: Icons.wb_twighlight,
                    gradientColors: [const Color(0xFF7B35B5), const Color(0xFF984DDB)],
                    isExpanded: _expandedStates['seasons'] ?? false,
                    onToggle: () => _toggleCard('seasons'),
                    children: [
                      _buildSubSection(
                        title: isBangla ? 'ক) মাসিক পর্যায় (Days 1–5):' : 'A) Menstrual Phase (Days 1–5):',
                        items: isBangla
                            ? ['ইস্ট্রোজেন এবং প্রোজেস্টেরন হরমোন সর্বনিম্ন স্তরে নেমে আসে।', 'শরীর এই সময়ে বিশ্রাম চায়। আদা চা বা উষ্ণ তরল খাবার ক্র্যাম্প কমাতে সাহায্য করে।']
                            : ['Estrogen and Progesterone crash to their lowest base levels.', 'Energy is pulled inward. Prioritize restorative rest and warm anti-inflammatory fluids.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'খ) ফলিকুলার পর্যায় (Days 6–13):' : 'B) Follicular Phase (Days 6–13):',
                        items: isBangla
                            ? ['ইস্ট্রোজেন হরমোন ক্রমশ বাড়তে থাকে, যা জরায়ুর নতুন লাইনিং তৈরি করে।', 'এই সময়ে শরীরে শক্তি, কাজের উদ্যম এবং মানসিক মনোযোগ সবচেয়ে বেশি থাকে।']
                            : ['Steady upward surge of Estrogen (estradiol) helps regenerate the uterine lining.', 'Physical stamina, mental clarity, and metabolic capacity spike upward.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'গ) ডিম্বস্ফোটন বা ওভুলেশন (Days 14–15):' : 'C) Ovulatory Phase (Days 14–15):',
                        items: isBangla
                            ? ['ডিম্বাশয় থেকে ডিম্বাণু নিঃসৃত হয়। এই সময়ে গর্ভধারণের সম্ভাবনা সবচেয়ে বেশি থাকে।', 'শরীরের তাপমাত্রা সামান্য বাড়ে এবং ডিমের সাদা অংশের মতো চটচটে তরল নিঃসৃত হয়।']
                            : ['LH hormone triggers egg release. Basal body temperature shifts upward.', 'Cervical fluid transitions into a transparent, stretchy, egg-white consistency.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'ঘ) লুটিয়াল পর্যায় (Days 16–28):' : 'D) Luteal Phase (Days 16–28):',
                        items: isBangla
                            ? ['প্রোজেস্টেরন হরমোন প্রাধান্য পায়। এটি কমে গেলে মুড সুইং বা পিএমএস (PMS) শুরু হয়।', 'এই সময়ে ম্যাগনেসিয়াম সমৃদ্ধ খাবার এবং পর্যাপ্ত কার্বোহাইড্রেট মেজাজ শান্ত রাখে।']
                            : ['Progesterone rules to stabilize uterus, then drops if no pregnancy occurs.', 'Can trigger mood swings, cravings, and PMS. Use magnesium foods to soothe tissue.'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 3: Vaginal pH Ecosystem Defense
                  _buildExpandableTipCard(
                    title: isBangla ? '৩. যোনিপথের প্রাকৃতিক সুরক্ষাবলয়' : '3. Reproductive Microbe Defense',
                    icon: Icons.shield_rounded,
                    gradientColors: [const Color(0xFF00C853), const Color(0xFF4CAF50)],
                    isExpanded: _expandedStates['ph_defense'] ?? false,
                    onToggle: () => _toggleCard('ph_defense'),
                    children: [
                      _buildSubSection(
                        title: isBangla ? 'প্রাকৃতিক pH মাত্রা (3.8 – 4.5):' : 'The Critical pH Scale (3.8 – 4.5):',
                        items: isBangla
                            ? ['সুস্থ যোনিপথ প্রাকৃতিকভাবেই কিছুটা অম্লীয় (Acidic) থাকে যা ক্ষতিকর ব্যাকটেরিয়া ধ্বংস করে।', 'উপকারী ব্যাকটেরিয়া (Lactobacilli) এই ভারসাম্য বজায় রাখে।']
                            : ['A healthy vaginal ecosystem is highly acidic to block out pathological bacterial strain overgrowths.', 'Lactobacilli naturally generate protective clean lactic barrier values.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'সাবান ও কেমিক্যাল ওয়াশ বর্জন করুন:' : 'The Danger of Scented Corporate Washes:',
                        items: isBangla
                            ? ['যোনিপথ একটি স্বয়ংক্রিয়ভাবে পরিষ্কার হওয়া (Self-cleansing) অঙ্গ।', 'কোনো ধরণের সুগন্ধি সাবান বা কৃত্রিম ওয়াশ যোনিপথের ভেতরের প্রাকৃতিক pH ব্যালেন্স সম্পূর্ণ নষ্ট করে সংক্রমণ বাড়ায়।']
                            : ['The vagina is fully self-cleansing. Scented chemical products flood the area with alkaline agents.', 'This alters natural pH and triggers recurring yeast infections or BV.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'সঠিক অন্তর্বাস নির্বাচন:' : 'Optimized Air Transmissibility:',
                        items: isBangla
                            ? ['সবসময় শতভাগ সুতি (100% Cotton) ও ঢিলেঢালা অন্তর্বাস ব্যবহার করুন।', 'সিন্থেটিক কাপড় বাতাস চলাচলে বাধা দেয়, ফলে আর্দ্রতা জমে ফাঙ্গাস বা চুলকানি তৈরি হয়।']
                            : ['Always wear clean, breathable 100% genuine cotton undergarments.', 'Synthetic textiles trap body heat and moisture, spinning up a hot mold cell for fungal spore expansion.'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 4: Nutrient Micro-targets
                  _buildExpandableTipCard(
                    title: isBangla ? '৪. প্রয়োজনীয় পুষ্টি উপাদান ও পরিমাপ' : '4. Essential Micro-Nutrient Targets',
                    icon: Icons.spa_rounded,
                    gradientColors: [const Color(0xFFE65100), const Color(0xFFFF9800)],
                    isExpanded: _expandedStates['nutrients'] ?? false,
                    onToggle: () => _toggleCard('nutrients'),
                    children: [
                      _buildSubSection(
                        title: isBangla ? 'আয়রন (Iron) - দৈনিক ১৮ মিলিগ্রাম:' : 'Elemental Iron – 18 mg Daily:',
                        items: isBangla
                            ? ['মাসিকের সময় রক্তক্ষরণের কারণে শরীরে যে ঘাটতি হয় তা পূরণে আয়রন অত্যাবশ্যক।', 'উৎস: পালং শাক, কচু শাক, কলিজা, ডালিম, ডিমের কুসুম এবং খেজুর।']
                            : ['Counteracts monthly blood loss values to maintain safe baseline blood cell limits.', 'Sources: Organic spinach, lean red meats, liver, pumpkin seeds, lentils.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'ম্যাগনেসিয়াম (Magnesium) - ৩২০ মিলিগ্রাম:' : 'Magnesium Bisglycinate – 320 mg Daily:',
                        items: isBangla
                            ? ['এটি জরায়ুর পেশীর অতিরিক্ত সংকোচন শিথিল করে মাসিকের তীব্র ব্যথা বা ক্র্যাম্প কমায়।', 'উৎস: ডার্ক চকোলেট (৭০%+), কাঠবাদাম, মিষ্টি কুমড়ার বীজ।']
                            : ['Calms nervous systems and relaxes uterine muscle walls to significantly ease heavy cramps.', 'Sources: Almonds, dark chocolate (70%+), whole grains, pumpkin kernels.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'ভিটামিন বি৬ (Vitamin B6) - ১.৩ মিলিগ্রাম:' : 'Vitamin B6 – 1.3 mg Daily:',
                        items: isBangla
                            ? ['মাসিকের আগের দিনগুলোতে হরমোনের কারণে সৃষ্ট মেজাজ খিটখিটে হওয়া বা বিষণ্ণতা কমায়।', 'উৎস: কলা, ছোলা, ওটস এবং মুরগির মাংস।']
                            : ['Aids internal synthesis of dopamine and serotonin to control PMS mood swings.', 'Sources: Chickpeas, standard bananas, wild salmon, poultry.'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 5: Red Flag Warnings
                  _buildExpandableTipCard(
                    title: isBangla ? '৫. রেড ফ্ল্যাগ: কখন ডাক্তারের কাছে যাবেন' : '5. Red Flags: Immediate Doctor Signs',
                    icon: Icons.warning_amber_rounded,
                    gradientColors: [const Color(0xFFD32F2F), const Color(0xFFEF5350)],
                    isExpanded: _expandedStates['red_flags'] ?? false,
                    onToggle: () => _toggleCard('red_flags'),
                    children: [
                      _buildSubSection(
                        title: isBangla ? 'অসহ্য পেট ব্যথা (Severe Dysmenorrhea):' : 'Incapacitating Pain (Severe Dysmenorrhea):',
                        items: isBangla
                            ? ['মাসিকের ব্যথা যদি এত তীব্র হয় যে বমি, অজ্ঞান হওয়া বা স্বাভাবিক কাজ ব্যাহত হয়।', 'এটি এন্ডোমেট্রিওসিস (Endometriosis) এর মতো জটিল রোগের লক্ষণ হতে পারে।']
                            : ['Cramps that cause vomiting, fainting, or completely block daily routine operational work.', 'Often stands as a primary medical clinical symptom of active Endometriosis.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'অতিরিক্ত রক্তস্রাব (Excessive Flow):' : 'Menorrhagia (Excessive Blood Loss):',
                        items: isBangla
                            ? ['যদি প্রতি ১-২ ঘণ্টায় একটি করে হাই-অ্যাবজরবেন্ট প্যাড সম্পূর্ণ ভিজে যায়।', 'মাসিকের রক্তে যদি কয়েন বা বড় আকারের চটচটে রক্তের চাকা বা ক্লট দেখা যায়।']
                            : ['Soaking through a high-capacity sanitary pad every single hour for multiple hours.', 'Passing large thick blood coagulated clotting arrays wider than a quarter.'],
                      ),
                      const SizedBox(height: 12),
                      _buildSubSection(
                        title: isBangla ? 'অনিয়মিত রক্তপাত (Irregular Spotting):' : 'Intermenstrual Spotting:',
                        items: isBangla
                            ? ['দুটি মাসিকের মধ্যবর্তী সময়ে হঠাৎ রক্ত দেখা দেওয়া কিংবা সহবাসের পর রক্তপাত হওয়া।', 'এটি জরায়ুর হরমোনজনিত জটিলতা বা টিউমারের লক্ষণ হতে পারে, দ্রুত পরীক্ষা করান।']
                            : ['Experiencing unexpected bleeding or dark staining between scheduled periods.', 'Requires diagnostic ultrasound screenings to eliminate polyps or fibroids.'],
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fully compiled dynamic toggle frame builder module
  Widget _buildExpandableTipCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7B35B5).withOpacity(0.04), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF331652),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, thickness: 0.6, color: Color(0xFFF2EFF6)),
                  const SizedBox(height: 16),
                  ...children,
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF331652),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 10),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2A6D),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}