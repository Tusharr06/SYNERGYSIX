import 'package:agro_stick/auth_screens/login_screen.dart';
import 'package:agro_stick/main_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:agro_stick/ui/chat_visibility.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatEnabledNotifier.value = false;
    });
    // Navigate to the next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => user != null ? const MainHomeScreen() : const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatEnabledNotifier.value = true;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepGreen,
              AppColors.lightGreen,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with simple fade-in and scale
              Image.asset(
                'assets/logo.png', // Replace with your logo image
                width: 200,
                height: 200,
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 20),
              // Project name with subtle shadow
              Text(
                'Agrostick',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  shadows: [
                    Shadow(
                      blurRadius: 6.0,
                      color: AppColors.shadowColor.withOpacity(0.3),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 1200.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0.0,
                    duration: 1200.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 10),
              // Tagline with simple fade-in
              Text(
                'Smart Crop Care',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary.withOpacity(0.9),
                ),
              )
                  .animate()
                  .fadeIn(duration: 1400.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0.0,
                    duration: 1400.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 20),
              // Simple circular loader
              CircularProgressIndicator(  
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldenAccent),
                strokeWidth: 2.0,
              ).animate().fadeIn(duration: 1400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
 