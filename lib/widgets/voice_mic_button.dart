import 'package:flutter/material.dart';

class VoiceMicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;

  const VoiceMicButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (widget.isListening) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant VoiceMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!widget.isListening && _animController.isAnimating) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: widget.isListening ? 'Stop listening' : 'Start voice input',
      button: true,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final scale = widget.isListening ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Material(
              color: widget.isListening
                  ? colorScheme.error
                  : colorScheme.primary,
              shape: const CircleBorder(),
              elevation: widget.isListening ? 8 : 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    widget.isListening ? Icons.mic : Icons.mic_none,
                    color: widget.isListening
                        ? colorScheme.onError
                        : colorScheme.onPrimary,
                    size: 26,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
