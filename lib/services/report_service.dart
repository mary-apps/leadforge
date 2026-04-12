import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business.dart';
import '../models/report.dart';
import 'supabase_service.dart';

class ReportService {
  static Future<Uint8List> generatePdfReport(
      Business business, String? agencyName) async {
    final pdf = pw.Document();

    final score = business.auditScore ?? 0;
    final breakdown = business.auditBreakdown ?? {};
    final diagnosis = business.auditDiagnosis ?? 'No diagnosis available.';

    // Page 1: Cover
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 80),
          pw.Text('WEB PRESENCE',
              style: const pw.TextStyle(
                  fontSize: 12,
                  letterSpacing: 4,
                  color: PdfColors.grey600)),
          pw.Text('AUDIT REPORT',
              style: const pw.TextStyle(
                  fontSize: 12,
                  letterSpacing: 4,
                  color: PdfColors.grey600)),
          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 24),
          pw.Text(business.name,
              style: pw.TextStyle(
                  fontSize: 32, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (business.address != null)
            pw.Text(business.address!,
                style:
                    const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
          pw.SizedBox(height: 40),
          // Score circle
          pw.Container(
            width: 120,
            height: 120,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(
                color: score >= 70
                    ? PdfColors.green
                    : score >= 40
                        ? PdfColors.orange
                        : PdfColors.red,
                width: 4,
              ),
            ),
            child: pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('$score',
                      style: pw.TextStyle(
                          fontSize: 36, fontWeight: pw.FontWeight.bold)),
                  pw.Text('/100',
                      style: const pw.TextStyle(
                          fontSize: 14, color: PdfColors.grey500)),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            score >= 70
                ? 'Good web presence'
                : score >= 40
                    ? 'Needs improvement'
                    : 'Poor web presence',
            style: pw.TextStyle(
                fontSize: 16,
                color: score >= 70
                    ? PdfColors.green700
                    : score >= 40
                        ? PdfColors.orange700
                        : PdfColors.red700),
          ),
          pw.Spacer(),
          if (agencyName != null && agencyName.isNotEmpty)
            pw.Text('Prepared by $agencyName',
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.grey500)),
          pw.Text('Powered by LeadForge',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
        ],
      ),
    ));

    // Page 2: Breakdown
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        final factors = <pw.Widget>[];

        breakdown.forEach((key, value) {
            if (value is Map) {
              final label = value['label']?.toString() ?? key;
              final impact = (value['impact'] is num)
                  ? (value['impact'] as num).toInt()
                  : 0;
              final passed = value['passed'] == true;

              factors.add(pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(label,
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: passed
                                ? PdfColors.green50
                                : PdfColors.red50,
                            borderRadius: pw.BorderRadius.circular(12),
                          ),
                          child: pw.Text(
                            passed ? 'PASS' : 'NEEDS WORK',
                            style: pw.TextStyle(
                                fontSize: 9,
                                color: passed
                                    ? PdfColors.green700
                                    : PdfColors.red700,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    // Score bar
                    pw.LinearProgressIndicator(
                      value: (impact / 20.0).clamp(0.0, 1.0),
                      backgroundColor: PdfColors.grey100,
                      valueColor: passed ? PdfColors.green400 : PdfColors.red400,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('$impact / 20 points',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey500)),
                  ],
                ),
              ));
            }
          });

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Score Breakdown',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Five key factors of your online presence',
                style:
                    const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            pw.SizedBox(height: 24),
            ...factors,
          ],
        );
      },
    ));

    // Page 3: Diagnosis + Recommendations
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Diagnosis',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text(diagnosis,
              style: const pw.TextStyle(fontSize: 13, lineSpacing: 6)),
          pw.SizedBox(height: 32),
          pw.Text('Recommendations',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text(
            score < 40
                ? '1. Establish a professional website with mobile responsiveness\n2. Claim and optimize Google Business Profile\n3. Encourage customers to leave reviews\n4. Set up social media profiles on relevant platforms\n5. Ensure consistent NAP (Name, Address, Phone) across directories'
                : score < 70
                    ? '1. Improve website loading speed and mobile experience\n2. Actively manage and respond to online reviews\n3. Increase social media posting frequency\n4. Add structured data markup to website\n5. Create location-specific content for better local SEO'
                    : '1. Maintain current review response strategy\n2. Consider advanced SEO techniques\n3. Explore paid advertising for growth\n4. Add more visual content (photos, videos)\n5. Monitor competitors in your area',
            style: const pw.TextStyle(fontSize: 12, lineSpacing: 8),
          ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey200),
          pw.SizedBox(height: 8),
          pw.Text(
              'This report was generated by LeadForge - Local Business Intelligence',
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
        ],
      ),
    ));

    return pdf.save();
  }

  static Future<String> uploadPdf(
      Uint8List bytes, String userId, String businessId) async {
    final path =
        'reports/$userId/$businessId-${DateTime.now().millisecondsSinceEpoch}.pdf';
    await SupabaseService.client.storage.from('reports').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
              contentType: 'application/pdf', upsert: true),
        );
    return path;
  }

  static Future<Report?> fetchReport(String businessId) async {
    final response = await SupabaseService.client
        .from('reports')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false)
        .limit(1);
    if (response.isEmpty) return null;
    return Report.fromJson(response.first);
  }

  static Future<Report> saveReport({
    required String businessId,
    required int score,
    required Map<String, dynamic> breakdown,
    required String diagnosis,
    required List<String> recommendations,
    required String pdfStoragePath,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await SupabaseService.client
        .from('reports')
        .insert({
          'business_id': businessId,
          'user_id': userId,
          'score': score,
          'breakdown': breakdown,
          'diagnosis': diagnosis,
          'recommendations': recommendations,
          'pdf_storage_path': pdfStoragePath,
        })
        .select()
        .single();

    return Report.fromJson(response);
  }

  static Future<List<Report>> fetchMyReports() async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await SupabaseService.client
        .from('reports')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Report.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
