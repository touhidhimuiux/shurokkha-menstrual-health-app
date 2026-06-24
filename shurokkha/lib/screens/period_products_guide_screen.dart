import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/localization_extension.dart';
import '../services/language_provider.dart';
import 'home_screen.dart';

class PeriodProductsGuideScreen extends StatefulWidget {
  const PeriodProductsGuideScreen({super.key});

  @override
  State<PeriodProductsGuideScreen> createState() => _PeriodProductsGuideScreenState();
}

class _PeriodProductsGuideScreenState extends State<PeriodProductsGuideScreen> {
  // Failsafe Language Detection Module
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

  // Failsafe Toggle Invocation Core
  void _triggerLanguageToggle(BuildContext context, dynamic provider, bool currentIsBangla) {
    final String targetLang = currentIsBangla ? 'en' : 'bn';
    final Locale targetLocale = Locale(targetLang);

    try { provider.toggleLanguage(); return; } catch (_) {}
    try { provider.changeLanguage(targetLang); return; } catch (_) {}
    try { provider.setLocale(targetLocale); return; } catch (_) {}
    try { provider.changeLocale(targetLocale); return; } catch (_) {}
    try { provider.setLanguage(targetLang); return; } catch (_) {}
  }

  List<ProductGuide> _getProducts(bool isBengali) {
    if (isBengali) {
      return [
        ProductGuide(
          name: 'স্যানিটারি প্যাড (Pads)',
          icon: Icons.layers_rounded,
          description: 'সবচেয়ে সাধারণ, নিরাপদ এবং ব্যবহার করা সহজ পদ্ধতি।',
          guidelines: [
            'প্রতি ৪ থেকে ৬ ঘণ্টা পর পর অবশ্যই নতুন স্যানিটারি ন্যাপকিন বা প্যাড ব্যবহার করবেন।',
            'প্যাডের পেছনের আঠালো প্রোটেক্টিভ পেপারটি সাবধানে তুলে ফেলুন।',
            'अंतর্বাসের ভেতরের মাঝখানের অংশে প্যাডটি সোজাভাবে চেপে বসিয়ে দিন।',
            'দুটি ডানা বা উইংস অন্তর্বাসের বাইরের দিকে মুড়িয়ে ভালোমত লক করুন।',
            'ব্যব্যহৃত প্যাডটি পরিষ্কার কাগজে মুড়িয়ে নির্দিষ্ট ডাস্টবিনে ফেলুন।'
          ],
          pros: ['কোনো অভ্যন্তরীণ স্পর্শের প্রয়োজন নেই', 'সহজে বহনযোগ্য ও সর্বত্র পাওয়া যায়', 'সব ধরণের পোশাকের সাথে ব্যবহার উপযোগী'],
          cons: ['দীর্ঘক্ষণ রাখলে আর্দ্রতা ও রেশ বা চুলকানি সৃষ্টি হতে পারে', 'পরিবেশে সহজে পচে না (নন-বায়োডিগ্রেডেবল)'],
        ),
        ProductGuide(
          name: 'মেন্সট্রুয়াল কাপ (Cups)',
          icon: Icons.local_activity_rounded,
          description: 'মেডিকেল গ্রেড সিলিকন দ্বারা তৈরি পরিবেশ-বান্ধব ও দীর্ঘস্থায়ী ইকো সリューション।',
          guidelines: [
            'কাপ ধরার আগে হাত সাবান দিয়ে ভালোমত পরিষ্কার ও জীবাণুমুক্ত করে নিন।',
            'কাপটিকে C-শেপ বা পাঞ্চ-ডাউন ফোল্ড করে ভাঁজ করে নিন।',
            'আরামদায়ক পজিশনে বসে কাপটি যোনিপথে আলতো করে পুশ করুন।',
            'ভিতরে গিয়ে কাপটি নিজে থেকেই খুলে একটি ভ্যাকুয়াম সিল তৈরি করবে।',
            '৮ থেকে ১২ ঘণ্টা পর কাপটির নিচের বেস সামান্য চেপে ভ্যাকুয়াম রিলিজ করে বের করে আনুন।'
          ],
          pros: ['১০-১২ ঘণ্টা পর্যন্ত একটানা লিক-প্রুফ সুরক্ষা দেয়', 'ধৌত করে ৩ থেকে ৫ বছর পর্যন্ত পুনর্ব্যবহারযোগ্য', 'মাসিক খরচ বিপুল পরিমাণে কমায়'],
          cons: ['প্রথম প্রথম প্রবেশ করানো এবং বের করার প্রক্রিয়াটি শিখতে সময় লাগতে পারে', 'পাবলিক ওয়াশরুমে ধুয়ে পুনরায় ব্যবহার করা কিছুটা অস্বস্তিকর'],
        ),
      ];
    } else {
      return [
        ProductGuide(
          name: 'Sanitary Napkins (Pads)',
          icon: Icons.layers_rounded,
          description: 'Extremely accessible, external barrier solution perfect for absolute comfort.',
          guidelines: [
            'Peel off the central release strip adhesive layer protective paper carefully.',
            'Position item exactly centered longitudinally along internal underwear base.',
            'Fold flanking protective wrap wings tightly around underwear fabric walls to lock.',
            'Replace disposable elements strictly every 4 to 6 hours to avert bacterial growth.',
            'Wrap old units securely inside clean scrap paper and toss in dry disposal containers.'
          ],
          pros: ['Zero internal placement required, high intuitive comfort', 'Universally accessible across pharmacy networks', 'Optimized variations available for heavy flow'],
          cons: ['Possibility of friction rash or damp irritation during humid months', 'High environmental lifecycle plastic residue waste overhead'],
        ),
        ProductGuide(
          name: 'Medical Menstrual Cups',
          icon: Icons.local_activity_rounded,
          description: 'High-fidelity eco-friendly medical grade silicone collection apparatus.',
          guidelines: [
            'Wash hands thoroughly using antibacterial clear handwash before contact.',
            'Apply a compressed C-fold or Punch-down folding technique to minimize entrance diameter.',
            'Relax vaginal muscles; gently slide item internal apex angled toward lower spine.',
            'Release grip to allow the elastic cup rim to fully open, establishing a secure vacuum seal.',
            'Every 8 to 12 hours, slightly squeeze the lower collection base to disengage vacuum.'
          ],
          pros: ['Unparalleled 12-hour continuous capture buffer timeline capacity', 'Washable, reusable blueprint extending across a 5-year active deployment lifecycle', 'Completely preserves delicate dynamic internal fluid values'],
          cons: ['Slight initial learning curve required to perfect insert mechanics smoothly', 'Requires consistent access to boiling clean water for sterilization steps'],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBengali = _isBanglaActive(context, languageProvider);
    final products = _getProducts(isBengali);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Frame with Dynamic Switching Control
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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

                  GestureDetector(
                    onTap: () => _triggerLanguageToggle(context, languageProvider, isBengali),
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
                              color: !isBengali ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: !isBengali ? [
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
                                color: !isBengali ? const Color(0xFF7B35B5) : Colors.grey.shade500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isBengali ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isBengali ? [
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
                                color: isBengali ? const Color(0xFF7B35B5) : Colors.grey.shade500,
                                letterSpacing: 0.5,
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

            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBengali ? 'পণ্য ব্যবহার নির্দেশিকা' : 'Anatomical Hygiene Guide',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF331652),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBengali ? 'ফিচার সেকশনে ট্যাপ করে ড্রপডাউন গাইডটি খুলুন' : 'Tap on section cards to expand detailed metrics.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main Product List Feed Card Engine
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF7B35B5).withOpacity(0.04), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF2A6D).withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(item.icon, color: const Color(0xFFFF2A6D), size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF331652)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Dynamic Feature Segment Accordions / Dropdowns
                          ExpandableSectionWidget(
                            title: isBengali ? 'সহজ ব্যবহার বিধি (How to Use)' : 'Clinical Deployment Protocol',
                            icon: Icons.menu_book_rounded,
                            color: const Color(0xFF7B35B5),
                            tips: item.guidelines,
                            initialExpanded: index == 0, // Keep first card open for better UI context
                          ),
                          ExpandableSectionWidget(
                            title: isBengali ? 'সুবিধাসমূহ (Advantages)' : 'Physiological Advantages',
                            icon: Icons.check_circle_outline_rounded,
                            color: const Color(0xFF00C853),
                            tips: item.pros,
                          ),
                          ExpandableSectionWidget(
                            title: isBengali ? 'অসুবিধাসমূহ (Disadvantages)' : 'Lifecycle Constraints',
                            icon: Icons.error_outline_rounded,
                            color: const Color(0xFFFF3D00),
                            tips: item.cons,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Independent State-Managed Expandable Feature Card (Dropdown UI pattern)
class ExpandableSectionWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> tips;
  final bool initialExpanded;

  const ExpandableSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.tips,
    this.initialExpanded = false,
  });

  @override
  State<ExpandableSectionWidget> createState() => _ExpandableSectionWidgetState();
}

class _ExpandableSectionWidgetState extends State<ExpandableSectionWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withOpacity(0.06), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon, size: 16, color: widget.color),
                      const SizedBox(width: 8),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: widget.color, letterSpacing: 0.1),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: widget.color),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, thickness: 0.5, color: Colors.black12),
                  const SizedBox(height: 12),
                  ...widget.tips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5, right: 10),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(color: widget.color.withOpacity(0.6), shape: BoxShape.circle),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class ProductGuide {
  final String name;
  final IconData icon;
  final String description;
  final List<String> guidelines;
  final List<String> pros;
  final List<String> cons;

  ProductGuide({
    required this.name,
    required this.icon,
    required this.description,
    required this.guidelines,
    required this.pros,
    required this.cons,
  });
}