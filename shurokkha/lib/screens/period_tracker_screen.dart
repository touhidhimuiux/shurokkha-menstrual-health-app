import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/cycle_gauge_widget.dart';
import '../services/period_data_provider.dart';
import '../services/localization_extension.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'shop_screen.dart';
import 'community_screen_protected.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    // Refresh period data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PeriodDataProvider>().refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ShopScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CommunityScreenNew()),
              );
              break;
          }
        },
      ),
      body: GradientBackground(
        colors: const [
          Colors.white,
          Colors.white,
          Colors.white,
          Colors.white
        ],
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Bar with Title and Back Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsivePadding(mobilePadding: 16),
                          vertical: context.responsivePadding(mobilePadding: 12, tabletPadding: 14),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                                );
                              },
                              child: Icon(Icons.arrow_back,
                                  color: AppColors.textDark,
                                  size: context.responsiveIconSize(mobileSize: 28, tabletSize: 32)),
                            ),
                            SizedBox(width: context.responsiveSpacing(mobileSpacing: 12)),
                            Expanded(
                              child: Text(
                                context.translate('period_tracker'),
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(mobileSize: 18, tabletSize: 20, desktopSize: 24),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Cycle Gauge Widget
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(mobileSpacing: 20, tabletSpacing: 24),
                        ),
                        child: Consumer<PeriodDataProvider>(
                          builder: (context, periodProvider, _) {
                            return CycleGaugeWidget(
                                periodProvider: periodProvider);
                          },
                        ),
                      ),
                      const Divider(height: 1),

                      // Main Content with Padding
                      Consumer<PeriodDataProvider>(
                        builder: (context, periodProvider, _) {
                          return Padding(
                            padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 16, tabletPadding: 20)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Prediction & Insights Cards
                                _buildPredictionCards(context, periodProvider),
                                SizedBox(height: context.responsiveSpacing(mobileSpacing: 20, tabletSpacing: 24)),

                                // Month Navigation & Calendar
                                Container(
                                  padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 16, tabletPadding: 20)),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 20, tabletRadius: 24)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Month Header
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() => _currentMonth =
                                                  DateTime(_currentMonth.year,
                                                      _currentMonth.month - 1));
                                            },
                                            child: Icon(
                                                Icons.chevron_left,
                                                color: AppColors.primaryPurple,
                                                size: context.responsiveIconSize(mobileSize: 28, tabletSize: 32)),
                                          ),
                                          Text(
                                            '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                                            style: TextStyle(
                                              fontSize: context.responsiveFontSize(mobileSize: 18, tabletSize: 20, desktopSize: 22),
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() => _currentMonth =
                                                  DateTime(_currentMonth.year,
                                                      _currentMonth.month + 1));
                                            },
                                            child: Icon(
                                                Icons.chevron_right,
                                                color: AppColors.primaryPurple,
                                                size: context.responsiveIconSize(mobileSize: 28, tabletSize: 32)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: context.responsiveSpacing(mobileSpacing: 16, tabletSpacing: 20)),

                                      // Day Headers
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          'S',
                                          'M',
                                          'T',
                                          'W',
                                          'T',
                                          'F',
                                          'S'
                                        ]
                                            .map((day) => Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      day,
                                                      style: TextStyle(
                                                        fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors
                                                            .primaryPurple,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                      SizedBox(height: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 16)),

                                      // Calendar Grid
                                      _buildCalendarGrid(periodProvider),

                                      SizedBox(height: context.responsiveSpacing(mobileSpacing: 20, tabletSpacing: 24)),

                                      // Legend
                                      Container(
                                        padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 16, tabletPadding: 20)),
                                        decoration: BoxDecoration(
                                          color: AppColors.softLavender
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16, tabletRadius: 20)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.translate('cycle_phases'),
                                              style: TextStyle(
                                                fontSize: context.responsiveFontSize(mobileSize: 14, tabletSize: 16, desktopSize: 18),
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            SizedBox(height: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 16)),
                                            _LegendItem(
                                              color: AppColors.softPink,
                                              label: context.translate('phase_menstruation'),
                                              description:
                                                  context.translate('your_menstrual_phase'),
                                            ),
                                            SizedBox(height: context.responsiveSpacing(mobileSpacing: 10, tabletSpacing: 12)),
                                            _LegendItem(
                                              color: const Color(0xFFFFC107),
                                              label: context.translate('ovulation'),
                                              description:
                                                  context.translate('fertile_window'),
                                            ),
                                            SizedBox(height: context.responsiveSpacing(mobileSpacing: 10, tabletSpacing: 12)),
                                            _LegendItem(
                                              color: AppColors.primaryPurple,
                                              label: context.translate('pms_period'),
                                              description:
                                                  context.translate('pms_description'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: context.responsiveSpacing(mobileSpacing: 20, tabletSpacing: 24)),

                                // Cycle History
                                _buildCycleHistorySection(context, periodProvider),
                                SizedBox(height: context.responsiveSpacing(mobileSpacing: 20, tabletSpacing: 24)),

                                // Future Predictions
                                _buildFuturePredictions(context, periodProvider),
                                SizedBox(height: context.responsiveSpacing(mobileSpacing: 20, tabletSpacing: 24)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // FAB Button
              Positioned(
                right: context.responsivePadding(mobilePadding: 16),
                bottom: context.responsivePadding(mobilePadding: 16),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header
                                Text(
                                  context.translate('set_your_period'),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  context.translate('choose_preferred_method'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Option 1: Start Date Only
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _selectPeriodStartDate(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryPurple,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                context.translate('period_start_date'),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                context.translate('set_when_started'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.textGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Option 2: Start & End Date
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _selectPeriodStartAndEnd(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.mediumPink.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      color: AppColors.mediumPink.withValues(alpha: 0.08),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.mediumPink,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.date_range,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                context.translate('period_start_end'),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                context.translate('set_both_dates'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.textGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: AppColors.mediumPink,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Cancel Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.textGrey,
                                      side: BorderSide(
                                        color: AppColors.textGrey.withValues(alpha: 0.2),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(context.translate('cancel')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primaryPurple,
                  label: const Text('Set Period',
                      style: TextStyle(color: Colors.white)),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionCards(BuildContext context, PeriodDataProvider periodProvider) {
    if (periodProvider.lastPeriodDate == null) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 20, tabletPadding: 24)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16, tabletRadius: 20)),
          ),
          child: Text(
            context.translate('set_period_date'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.responsiveFontSize(mobileSize: 14, tabletSize: 16, desktopSize: 18),
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    final today = DateTime.now();
    final daysSincePeriod =
        today.difference(periodProvider.lastPeriodDate!).inDays;
    final daysInCycle = daysSincePeriod % periodProvider.cycleLength;
    final daysUntilNextPeriod = periodProvider.cycleLength - daysInCycle;
    final ovulationDay = (periodProvider.cycleLength / 2).round();
    final daysUntilOvulation = (ovulationDay - daysInCycle).abs();
    final pmsStartDay = periodProvider.cycleLength - 3;
    final daysUntilPms = (pmsStartDay - daysInCycle).abs();

    final isInFertileWindow = daysInCycle >= 12 && daysInCycle <= 16;
    final isInPms = daysInCycle >= pmsStartDay;

    return Column(
      children: [
        // Current Status Card
        Container(
          padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 16, tabletPadding: 20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple.withValues(alpha: 0.8),
                AppColors.softLavender.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16, tabletRadius: 20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('current_cycle'),
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(mobileSpacing: 4)),
                  Text(
                    'Day ${daysInCycle + 1}',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(mobileSize: 24, tabletSize: 28, desktopSize: 32),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(width: context.responsiveSpacing(mobileSpacing: 20, tabletSpacing: 24)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('next_period'),
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(mobileSpacing: 4)),
                  Text(
                    context.translate('period_in_days', {'days': daysUntilNextPeriod.toString()}),
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(mobileSize: 16, tabletSize: 18, desktopSize: 20),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 16)),

        // Fertility Window Card
        Container(
          padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 14, tabletPadding: 16)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16, tabletRadius: 20)),
            border: isInFertileWindow
                ? Border.all(color: const Color(0xFFFFC107), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 12, tabletPadding: 14)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 12, tabletRadius: 14)),
                ),
                child: Icon(
                  Icons.favorite,
                  color: const Color(0xFFFFC107),
                  size: context.responsiveIconSize(mobileSize: 24, tabletSize: 28),
                ),
              ),
              SizedBox(width: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('fertility_ovulation'),
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(mobileSize: 13, tabletSize: 15, desktopSize: 16),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      isInFertileWindow
                          ? context.translate('high_fertility')
                          : context.translate('ovulation_in', {'days': daysUntilOvulation.toString()}),
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 16)),

        // PMS Prediction Card
        Container(
          padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 14, tabletPadding: 16)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16, tabletRadius: 20)),
            border: isInPms
                ? Border.all(color: AppColors.softPink, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 12, tabletPadding: 14)),
                decoration: BoxDecoration(
                  color: AppColors.softPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 12, tabletRadius: 14)),
                ),
                child: Icon(
                  Icons.mood,
                  color: AppColors.softPink,
                  size: context.responsiveIconSize(mobileSize: 24, tabletSize: 28),
                ),
              ),
              SizedBox(width: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PMS Prediction',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(mobileSize: 13, tabletSize: 15, desktopSize: 16),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      isInPms
                          ? '⚠️ PMS period - Take care of yourself'
                          : 'PMS starts in $daysUntilPms days',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleHistorySection(BuildContext context, PeriodDataProvider periodProvider) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 16, tabletPadding: 20)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16, tabletRadius: 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle History',
            style: TextStyle(
              fontSize: context.responsiveFontSize(mobileSize: 14, tabletSize: 16, desktopSize: 18),
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 16)),
          if (periodProvider.lastPeriodDate != null) ...[
            _buildHistoryItem(
              context,
              'Last Period Started',
              _formatDate(periodProvider.lastPeriodDate!),
              '${periodProvider.periodLength} days',
            ),
            SizedBox(height: context.responsiveSpacing(mobileSpacing: 10, tabletSpacing: 12)),
            _buildHistoryItem(
              context,
              'Average Cycle',
              '${periodProvider.cycleLength} days',
              'Regular',
            ),
          ] else
            Text(
              'No cycle history yet',
              style: TextStyle(
                fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
                color: AppColors.textGrey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String label, String value, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(mobileSpacing: 4)),
            Text(
              value,
              style: TextStyle(
                fontSize: context.responsiveFontSize(mobileSize: 13, tabletSize: 15, desktopSize: 16),
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsivePadding(mobilePadding: 12),
            vertical: context.responsivePadding(mobilePadding: 6),
          ),
          decoration: BoxDecoration(
            color: AppColors.softLavender.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 10, tabletRadius: 12)),
          ),
          child: Text(
            detail,
            style: TextStyle(
              fontSize: context.responsiveFontSize(mobileSize: 11, tabletSize: 12, desktopSize: 13),
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuturePredictions(BuildContext context, PeriodDataProvider periodProvider) {
    if (periodProvider.lastPeriodDate == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(context.responsivePadding(mobilePadding: 16, tabletPadding: 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.1),
            AppColors.softLavender.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16, tabletRadius: 20)),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next 6 Months Prediction',
            style: TextStyle(
              fontSize: context.responsiveFontSize(mobileSize: 14, tabletSize: 16, desktopSize: 18),
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(mobileSpacing: 12, tabletSpacing: 16)),
          _buildUpcomingCyclePreview(context, periodProvider, 1),
          SizedBox(height: context.responsiveSpacing(mobileSpacing: 10, tabletSpacing: 12)),
          _buildUpcomingCyclePreview(context, periodProvider, 2),
          SizedBox(height: context.responsiveSpacing(mobileSpacing: 10, tabletSpacing: 12)),
          _buildUpcomingCyclePreview(context, periodProvider, 3),
        ],
      ),
    );
  }

  Widget _buildUpcomingCyclePreview(
      BuildContext context, PeriodDataProvider periodProvider, int cycleNumber) {
    final nextPeriodDate = periodProvider.lastPeriodDate!
        .add(Duration(days: periodProvider.cycleLength * cycleNumber));

    return Row(
      children: [
        SizedBox(width: context.responsiveSpacing(mobileSpacing: 8)),
        Text(
          'Cycle $cycleNumber',
          style: TextStyle(
            fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(nextPeriodDate),
          style: TextStyle(
            fontSize: context.responsiveFontSize(mobileSize: 12, tabletSize: 13, desktopSize: 14),
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildCalendarGrid(PeriodDataProvider periodProvider) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7; // 0 = Sunday

    List<Widget> dayWidgets = [];

    // Empty cells for days before month starts
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.expand());
    }

    // Day cells
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dayType = _getDayType(date, periodProvider);
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;

      Color backgroundColor = Colors.transparent;
      Color textColor = AppColors.textDark;
      Color? indicatorColor;

      if (dayType == 'period') {
        backgroundColor = AppColors.softPink.withValues(alpha: 0.7);
        indicatorColor = AppColors.softPink;
      } else if (dayType == 'ovulation') {
        backgroundColor = const Color(0xFFFFC107).withValues(alpha: 0.7);
        indicatorColor = const Color(0xFFFFC107);
      } else if (dayType == 'pms') {
        backgroundColor = AppColors.primaryPurple.withValues(alpha: 0.5);
        indicatorColor = AppColors.primaryPurple;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  dayType == 'period'
                      ? 'Period Day - Log details'
                      : dayType == 'ovulation'
                          ? 'Ovulation Day - Most fertile'
                          : dayType == 'pms'
                              ? 'PMS Period - Taking care before period'
                              : 'Normal Day',
                ),
                backgroundColor: AppColors.primaryPurple,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: isToday
                  ? Border.all(color: AppColors.primaryPurple, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (indicatorColor != null)
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  String _getDayType(DateTime day, PeriodDataProvider periodProvider) {
    if (periodProvider.lastPeriodDate == null) return 'normal';

    int daysDiff = day.difference(periodProvider.lastPeriodDate!).inDays;
    int cycleDay = daysDiff % periodProvider.cycleLength;
    int pmsStartDay = periodProvider.cycleLength - 3;

    if (cycleDay >= 0 && cycleDay < periodProvider.periodLength) {
      return 'period';
    } else if (cycleDay >= 12 && cycleDay <= 16) {
      return 'ovulation';
    } else if (cycleDay >= pmsStartDay) {
      return 'pms';
    }
    return 'normal';
  }



  Future<void> _selectPeriodStartDate(BuildContext context) async {
    final periodProvider =
        Provider.of<PeriodDataProvider>(context, listen: false);
    final initialDate = periodProvider.lastPeriodDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      // Save to provider
      await periodProvider.setPeriodData(
        lastPeriodDate: picked,
        cycleLength: periodProvider.cycleLength,
        periodLength: periodProvider.periodLength,
        userName: periodProvider.userName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Period start date set to ${picked.day}/${picked.month}/${picked.year}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selectPeriodStartAndEnd(BuildContext context) async {
    final periodProvider =
        Provider.of<PeriodDataProvider>(context, listen: false);
    final initialDate = periodProvider.lastPeriodDate ?? DateTime.now();

    // Select start date
    final startDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (startDate != null && mounted) {
      // Select end date
      final endDate = await showDatePicker(
        context: context,
        initialDate: startDate.add(const Duration(days: 5)),
        firstDate: startDate,
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.mediumPink,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (endDate != null && mounted) {
        // Calculate period length
        final periodDays = endDate.difference(startDate).inDays + 1;

        // Save to provider
        await periodProvider.setPeriodData(
          lastPeriodDate: startDate,
          cycleLength: periodProvider.cycleLength,
          periodLength: periodDays,
          userName: periodProvider.userName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Period set: ${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month} (${periodDays} days)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }


  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String description;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
