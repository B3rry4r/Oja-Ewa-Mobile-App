import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../app/theme/app_theme_colors.dart';
import '../../../../app/widgets/app_page_scaffold.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;

  void _handleLoaded(PdfDocumentLoadedDetails details) {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _handleLoadFailed(PdfDocumentLoadFailedDetails details) {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: widget.title,
      showActions: false,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SfPdfViewer.asset(
                widget.assetPath,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                onDocumentLoaded: _handleLoaded,
                onDocumentLoadFailed: _handleLoadFailed,
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: colors.background.withValues(alpha: 0.8),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
