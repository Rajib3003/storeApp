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

              // 🔥 MULTIPLE LABELS BASED ON STOCK
              children: List.generate(quantity, (index) {
                return pw.Container(
                  width: 180,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      
                      // PRODUCT NAME
                      pw.Text(
                        productName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.SizedBox(height: 8),

                      // BARCODE
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: barcode,
                        width: 150,
                        height: 50,
                      ),

                      pw.SizedBox(height: 8),

                      // QR CODE
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: barcode,
                        width: 80,
                        height: 80,
                      ),

                      pw.SizedBox(height: 5),

                      // TEXT BARCODE
                      pw.Text(
                        barcode,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
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