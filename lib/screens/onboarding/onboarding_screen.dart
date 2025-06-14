import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/onboarding_model.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      image: 'assets/images/onboard1.png',
      title: 'Keyword Research',
      description: 'Discover high-ranking keywords with AI-powered insights.',
    ),
    OnboardingContent(
      image: 'assets/images/onboard2.png',
      title: 'Content Optimization',
      description: 'Get real-time SEO scores and improve your content.',
    ),
  ];

  void _onPageChanged(int page) => setState(() => _currentPage = page);

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (ctx, index) => OnboardingPage(content: _pages[index]),
            ),

            // Dot Indicator
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: const WormEffect(
                    activeDotColor: Color(0xFF2D5EFF),
                    dotColor: Colors.grey,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 16,
                  ),
                ),
              ),
            ),

            // Buttons
            Positioned(
              bottom: 30,
              right: 24,
              left: 24,
              child: _currentPage == _pages.length - 1
                  ? ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5EFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
                  : Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2D5EFF),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
