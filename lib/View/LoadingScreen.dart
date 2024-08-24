import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController
      _controller; // Controller for the text scaling animation
  late Animation<double> _animationScale; // Animation for scaling text

  @override
  void initState() {
    super.initState();
    // Initialize the Animation Controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duration of the animation
      vsync: this, // Provide the vsync handling
    );

    // Define the scale animation
    _animationScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth animation curve
      ),
    );

    // Loop the animation
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    // Dispose the controller to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8), // Modern background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: _animationScale,
              child: Text(
                'Madidou',
                style: TextStyle(
                  fontFamily: "Montserrat", // Modern and accessible font
                  fontWeight: FontWeight.w700,
                  fontSize: 42, // Larger font size for prominence
                  color: Color(0xFF5e5f99), // Use specified color
                ),
              ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 255, 112, 137)), // Use specified color
            ),
            const SizedBox(height: 20),
            Center(
              // Center the text
              child: Text(
                'Merci de patienter pour quelques secondes ...',
                style: TextStyle(
                  fontFamily: "Montserrat", // Modern and accessible font
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color:
                      Color.fromARGB(255, 255, 112, 137), // Use specified color
                ),
                textAlign:
                    TextAlign.center, // Center the text within its container
              ),
            ),
          ],
        ),
      ),
    );
  }
}
