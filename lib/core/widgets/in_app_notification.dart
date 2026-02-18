import 'package:flutter/material.dart';

/// In-app notification overlay that shows at the top of the screen
class InAppNotification {
  InAppNotification._();

  static OverlayEntry? _currentEntry;
  static bool _isShowing = false;

  /// Show an in-app notification
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onTap,
    IconData icon = Icons.notifications,
    Color backgroundColor = const Color(0xFF603814),
    Duration duration = const Duration(seconds: 4),
  }) {
    // Dismiss existing notification if any
    dismiss();

    _isShowing = true;

    // Create overlay entry
    _currentEntry = OverlayEntry(
      builder: (context) => _InAppNotificationWidget(
        title: title,
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        onTap: () {
          dismiss();
          onTap();
        },
        onDismiss: dismiss,
      ),
    );

    // Show overlay
    Overlay.of(context).insert(_currentEntry!);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      dismiss();
    });
  }

  /// Dismiss the current notification
  static void dismiss() {
    if (_isShowing && _currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
      _isShowing = false;
    }
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  const _InAppNotificationWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_InAppNotificationWidget> createState() => _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: widget.onTap,
              onHorizontalDragEnd: (details) {
                // Swipe up to dismiss
                if (details.primaryVelocity! < 0) {
                  _dismiss();
                }
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Campton',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontFamily: 'Campton',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: _dismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
