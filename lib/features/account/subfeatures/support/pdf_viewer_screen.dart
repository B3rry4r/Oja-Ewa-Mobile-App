import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../app/widgets/app_header.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFFBF5),
              iconColor: const Color(0xFF241508),
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
              showActions: false,
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                        color: const Color(0xFFFFFBF5).withOpacity(0.8),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
