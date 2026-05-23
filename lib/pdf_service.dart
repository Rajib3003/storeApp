import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generatePdf({
    required String productName,
    required String barcode,
    required int quantity,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(quantity, (index) {
                return pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        productName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      // Barcode image from online generator
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: barcode,
                        width: 180,
                        height: 60,
                      ),

                      pw.SizedBox(height: 10),

                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: barcode,
                        width: 100,
                        height: 100,
                      ),

                      pw.SizedBox(height: 10),

                      pw.Text(barcode),
                    ],
                  ),
                );
              }),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}