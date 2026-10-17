import 'package:delego/widgets/mun_logo.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/Pages/Login_Page/verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final contactController = TextEditingController();
  final dobController = TextEditingController();

  // Backend values: 'veg', 'non_veg', 'jain'
  String? _selectedFoodPreference;

  static const Map<String, String> _foodLabels = {
    'veg': 'Veg',
    'non_veg': 'Non-Veg',
    'jain': 'Jain',
  };

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      setState(() {
        dobController.text = '$dd-$mm-$yyyy';
      });
    }
  }

  Future<void> signUserUp() async {
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final email = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final contact = contactController.text.trim();
    final dob = dobController.text.trim();
    final foodPref = _selectedFoodPreference;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        contact.isEmpty ||
        dob.isEmpty ||
        foodPref == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final digitsOnly = contact.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit contact number."),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    if (password.length < 8) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters long."),
        ),
      );
      return;
    }

    final body = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'contact': contact,
      'dateofbirth': dob,
      'food_preference': foodPref,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse('${Backend.baseUrl}/mumbaimun/register'),
        body: jsonEncode(body),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);
      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        // Cache signup profile details locally (and keyed by email so login can sync
        // them to the server if needed).
        final prefs = await SharedPreferences.getInstance();
        final dietLabel = _foodLabels[foodPref] ?? foodPref;
        await prefs.setString('contact', contact);
        await prefs.setString('dateofbirth', dob);
        await prefs.setString('diet', dietLabel);
        final emailKey = email.toLowerCase();
        await prefs.setString('pending_contact_$emailKey', contact);
        await prefs.setString('pending_dob_$emailKey', dob);
        await prefs.setString('pending_food_pref_$emailKey', foodPref);

        if (!mounted) return;
        // The account exists but cannot log in until the emailed code is entered.
        // (A server that does not report `verified` has already verified them.)
        final unverified = responseData['verified'] == false;
        if (!unverified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Registration successful. You can log in now.",
              ),
              backgroundColor: scheme.primary,
            ),
          );
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        final verified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailPage(
              email: email,
              emailSent: responseData['email_sent'] != false,
            ),
          ),
        );
        if (!mounted) return;
        if (verified == true) {
          Navigator.pop(context); // back to the login page
          messenger.showSnackBar(const SnackBar(
            content: Text('Email verified. Log in with your password.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['detail'].toString()),
            backgroundColor: scheme.error,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "An error occurred. Please check your internet connection.",
          ),
          backgroundColor: scheme.error,
        ),
      );
    }
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    bool obscure, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: scheme.onSurface),
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildFoodPreferenceSelector(ColorScheme scheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Food Preference',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _foodLabels.entries.map((entry) {
              final selected = _selectedFoodPreference == entry.key;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _selectedFoodPreference = entry.key;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? scheme.primary
                            : scheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? scheme.primary
                              : scheme.outlineVariant,
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        style: textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? scheme.onPrimary
                              : scheme.onSurface,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MunLogoLink(
                  child: SizedBox(
                    height: 160,
                    width: 160,
                    child: Image.asset("assets/images/logo_solid.webp"),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'DELEGO',
                  style: textTheme.headlineMedium?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                buildTextField(firstNameController, 'First Name', false),
                const SizedBox(height: 12),
                buildTextField(lastNameController, 'Last Name', false),
                const SizedBox(height: 12),
                buildTextField(
                  usernameController,
                  'Email ID',
                  false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                buildTextField(
                  contactController,
                  'Contact Number',
                  false,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                  ],
                ),
                const SizedBox(height: 12),
                buildTextField(
                  dobController,
                  'Date of Birth (dd-mm-yyyy)',
                  false,
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                  suffixIcon: Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFoodPreferenceSelector(scheme, textTheme),
                const SizedBox(height: 12),
                buildTextField(passwordController, 'Password', true),
                const SizedBox(height: 12),
                buildTextField(
                  confirmPasswordController,
                  'Confirm Password',
                  true,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: signUserUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Sign Up',
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

