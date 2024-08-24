import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: const Color(0xFFF5F6F9),
            foregroundColor:
                const Color(0xFF5e5f99), // This sets the default text color.
          ),
          onPressed: press, // Ensure 'press' is a valid function callback
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 22,
                color: Color(0xFF5e5f99),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600, // Specify the font family for the text
                    color: Color(
                        0xFF5e5f99), // Optional, since it's set by foregroundColor
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ));
  }
}
