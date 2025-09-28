import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:agro_stick/l10n/app_localizations.dart';
import 'package:agro_stick/l10n/locale_notifier.dart'; 
import 'package:agro_stick/auth_screens/login_screen.dart';
import 'package:agro_stick/services/language_service.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(); 
  final _farmNameController = TextEditingController();

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Hindi', 'Punjabi'];

  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();

      if (!mounted) return;

      setState(() {
        _nameController.text = doc.exists ? (doc.data()?['name'] ?? '') : '';
        _phoneController.text = doc.exists ? (doc.data()?['phone'] ?? '') : ''; 
        _farmNameController.text = doc.exists ? (doc.data()?['farmName'] ?? '') : '';
        _selectedLanguage = doc.exists ? (doc.data()?['language'] ?? 'English') : 'English';
        _isLoading = false;
      });

      // Apply saved language to app locale (this ensures it's applied even if LanguageService already ran)
      appLocaleNotifier.value = localeFromDisplayName(_selectedLanguage);
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_userId == null) return;

    try {
      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(), 
        'farmName': _farmNameController.text.trim(),
        'language': _selectedLanguage,
      }, firestore.SetOptions(merge: true));

      if (!mounted) return;
      
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t?.profileUpdated ?? 'Profile updated successfully')),
      );
      
      // Update language using LanguageService
      await LanguageService.updateUserLanguage(_userId!, _selectedLanguage);
      
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      final msg = t?.profileUpdateError('$e') ?? 'Error updating profile: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    // Reset language to default when logging out
    appLocaleNotifier.value = const Locale('en');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightGreen.withOpacity(0.1),
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          title: Text(
            t?.profile ?? 'Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGreen.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          t?.profile ?? 'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card container for fields
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t?.personalInformation ?? 'Personal Information',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(t?.name ?? 'Name', _nameController),
                    _buildTextField(t?.phone ?? 'Phone', _phoneController, keyboardType: TextInputType.phone), 
                    _buildTextField(t?.farmName ?? 'Farm Name', _farmNameController),
                    const SizedBox(height: 15),
                    Text(
                      t?.language ?? 'Language',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      items: _languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null && mounted) {
                          setState(() {
                            _selectedLanguage = val;
                          });
                          
                          // Update language using LanguageService
                          if (_userId != null) {
                            LanguageService.updateUserLanguage(_userId!, val);
                          } else {
                            // If no user, just apply locally
                            appLocaleNotifier.value = localeFromDisplayName(val);
                          }
                          
                          // Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Language changed to $val'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: Size(double.infinity, screenHeight * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                t?.saveProfile ?? 'Save Profile',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: Size(double.infinity, screenHeight * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                t?.logout ?? 'Logout',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}