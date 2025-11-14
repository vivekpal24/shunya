import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Use flutter_pdfview package
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfShow extends StatefulWidget {
  final String pdfUrl;

  PdfShow({required this.pdfUrl});

  @override
  _PdfShowState createState() => _PdfShowState();
}

class _PdfShowState extends State<PdfShow> {
  bool _isLoading = true;
  String? localPdfPath;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      final pdfFile = await downloadPdf(widget.pdfUrl);
      setState(() {
        localPdfPath = pdfFile.path;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading PDF: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File> downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/temp.pdf");
    return await file.writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : PDFView(
          filePath: localPdfPath,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          onError: (error) {
            print(error.toString());
          },
          onRender: (_pages) {
            setState(() {});
          },
          onViewCreated: (PDFViewController pdfViewController) {},
          onPageChanged: (int? page, int? total) {
            print('page change: $page/$total');
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
        ),
      ),
    );
  }
}
