import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/auth_provider.dart';
import '../services/pin_provider.dart';
import '../services/period_data_provider.dart';
import '../services/language_provider.dart';
import '../services/firestore_user_service.dart';
import '../services/localization_extension.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cycleController = TextEditingController();
  final TextEditingController _lastPeriodController = TextEditingController();
  
  String? _selectedAge;
  String? _selectedPeriodDays;
  bool _isLoading = false;

  final List<String> _ageOptions = [
    '13-15', '16-18', '19-21', '22-25', '26-30', '31-35', '35+'
  ];

  final List<String> _periodDaysOptions = ['3', '4', '5', '6', '7'];

  void _selectDate() async {
    final languageProvider = context.read<LanguageProvider>();
    final locale = languageProvider.locale; // Get Bengali locale from provider
    
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: locale,
    );
    if (picked != null) {
      setState(() {
        // Store in format: DD/MM/YYYY for internal processing
        _lastPeriodController.text = 
          '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _continuePressed() async {
    if (_selectedAge == null || _cycleController.text.isEmpty || _lastPeriodController.text.isEmpty || _selectedPeriodDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('fill_required')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Parse the last period date
    final dateparts = _lastPeriodController.text.split('/');
    DateTime lastPeriodDate;
    try {
      lastPeriodDate = DateTime(
        int.parse(dateparts[2]),
        int.parse(dateparts[1]),
        int.parse(dateparts[0]),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('invalid_date')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Get providers BEFORE any async operations that might cause context to be invalid
    final authProvider = context.read<AuthProvider>();
    final periodProvider = context.read<PeriodDataProvider>();
    final pinProvider = context.read<PinProvider>();
    final firestoreService = FirestoreUserService();

    // Save user profile to auth (local)
    final userName = _nameController.text.isNotEmpty ? _nameController.text : 'User';
    final userAge = _selectedAge ?? '18-21';
    final cycleLength = int.tryParse(_cycleController.text) ?? 28;
    
    await authProvider.setUserProfile(
      name: userName,
      age: userAge,
      lastPeriod: _lastPeriodController.text,
      cycleLength: cycleLength,
    );
    
    // Save period data
    await periodProvider.setPeriodData(
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
      periodLength: int.parse(_selectedPeriodDays ?? '5'),
      userName: userName,
    );
    
    // Save user profile to Firestore
    await firestoreService.updateUserProfile(
      name: userName,
      age: userAge,
      lastPeriod: _lastPeriodController.text,
      cycleLength: cycleLength,
    );
    
    // Mark initial login as complete
    await pinProvider.completeInitialLogin();
    
    // Mark as logged in
    await authProvider.login();
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'userName': _nameController.text.isNotEmpty 
            ? _nameController.text 
            : 'User',
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Set default cycle length to 28 days
    _cycleController.text = '28';
    // Set default period duration to 5 days
    _selectedPeriodDays = '5';
    
    // Keep name field empty for user to input
    // (Don't prefill name even if available from Google login)
    _nameController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cycleController.dispose();
    _lastPeriodController.dispose();
    super.dispose();
  }

  // Display English date only (for input field)
  String _displayEnglishDateOnly(String dateStr) {
    try {
      final parts = dateStr.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      // English month names
      final englishMonths = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      // English date with English numbers only (no Bengali)
      return '$day ${englishMonths[month - 1]}, $year';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        colors: const [
          Color(0xFFFFE6F5),
          Color(0xFFFFD6EC),
          Color(0xFFFFCCE8),
          Color(0xFFE8D5FF)
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        // Illustration - Secure Profile Setup
                        Container(
                          height: 250,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Image.asset(
                            'assets/secure_profile.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image not found
                              return Icon(
                                Icons.security,
                                size: 100,
                                color: AppColors.primaryPurple.withValues(alpha: 0.5),
                              );
                            },
                          ),
                        ),
                        // Title
                        Text(
                          context.translate('complete_profile'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Name field
                        TextFormField(
                          controller: _nameController,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            hintText: context.translate('name_optional'),
                            hintStyle: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.primaryPurple,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Age dropdown
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.primaryPurple.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedAge,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                context.translate('age_group'),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.expand_more,
                                color: AppColors.primaryPurple.withValues(alpha: 0.6),
                              ),
                            ),
                            items: _ageOptions.map((String age) {
                              return DropdownMenuItem<String>(
                                value: age,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    age,
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() => _selectedAge = newValue);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Cycle Length field
                        TextFormField(
                          controller: _cycleController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: context.translate('cycle_length'),
                            hintStyle: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.primaryPurple,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Period Duration field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.primaryPurple.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedPeriodDays,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                context.translate('period_duration'),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.expand_more,
                                color: AppColors.primaryPurple.withValues(alpha: 0.6),
                              ),
                            ),
                            items: _periodDaysOptions.map((String days) {
                              return DropdownMenuItem<String>(
                                value: days,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${days} ${context.translate('period_days')}',
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() => _selectedPeriodDays = newValue);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Last Period Date field
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _lastPeriodController.text.isEmpty
                                      ? Text(
                                          context.translate('last_period_date'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textGrey,
                                          ),
                                        )
                                      : Text(
                                          _displayEnglishDateOnly(_lastPeriodController.text),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.mediumPink,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Continue button at bottom
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _isLoading ? null : _continuePressed,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mediumPink,
                                  AppColors.primaryPurple.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      context.translate('continue_btn'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
