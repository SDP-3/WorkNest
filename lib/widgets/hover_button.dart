import 'package:flutter/material.dart';

// ---------------- Hoverable Elevated Button ----------------
// Renamed from _HoverButton to HoverButton
class HoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color hoverColor;
  final Color textColor;

  const HoverButton({
    super.key, // Added super.key
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.hoverColor,
    required this.textColor,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

// State class remains private
class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Scale effect on hover
        transform: _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovered ? widget.hoverColor : widget.backgroundColor,
          ),
          child: Text(widget.text, style: TextStyle(color: widget.textColor)),
        ),
      ),
    );
  }
}

// ---------------- Hoverable Outlined Button ----------------
// Renamed from _HoverOutlinedButton to HoverOutlinedButton
class HoverOutlinedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const HoverOutlinedButton({
    super.key, // Added super.key
    required this.onPressed,
    required this.text
  });

  @override
  State<HoverOutlinedButton> createState() => _HoverOutlinedButtonState();
}

// State class remains private
class _HoverOutlinedButtonState extends State<HoverOutlinedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Slight background color on hover for visual feedback
        decoration: BoxDecoration(
          color: _isHovered ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(6), // Match OutlinedButton's default shape
        ),
        child: OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(
            // Change border color on hover
            side: BorderSide(color: _isHovered ? Colors.blue[900]! : Colors.grey),
          ),
          child: Text(widget.text, style: TextStyle(color: Colors.blue[900])),
        ),
      ),
    );
  }
}