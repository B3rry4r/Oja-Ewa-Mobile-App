import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../app/widgets/app_header.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;

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
                title,
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
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SfPdfViewer.asset(
                    assetPath,
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
