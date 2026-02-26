class MedicalParserService {
  /// Parses raw OCR or typed text identifying specific key medical markers
  /// natively mapped using generalized regular expressions catering to common Indian lab report variations.
  static Map<String, String> parseText(String input) {
    final Map<String, String> extractedData = {};

    if (input.isEmpty) return extractedData;

    try {
      // HbA1c parsing: e.g., 'HbA1c : 5.6', 'HbA1 6.0', 'HbA1c: 7.2%'
      final hba1cRegex = RegExp(
          r'\b(?:HbA1c|HbA1|A1c|Glycosylated\s*Hemoglobin)\b\s*[:\-\=]?\s*(\d+\.?\d*)',
          caseSensitive: false);
      final hba1cMatch = hba1cRegex.firstMatch(input);
      if (hba1cMatch != null && hba1cMatch.groupCount >= 1) {
        extractedData['hba1c'] = hba1cMatch.group(1)!;
      }

      // Blood Pressure parsing: e.g., 'Blood Pressure 120/80', 'BP: 130\90'
      final bpRegex = RegExp(
          r'\b(?:Blood\s*Pressure|BP)\b\s*[:\-\=]?\s*(\d{2,3})\s*[\/\\]\s*(\d{2,3})',
          caseSensitive: false);
      final bpMatch = bpRegex.firstMatch(input);
      if (bpMatch != null && bpMatch.groupCount >= 2) {
        extractedData['bp_systolic'] = bpMatch.group(1)!;
        extractedData['bp_diastolic'] = bpMatch.group(2)!;
        extractedData['bp'] = '${bpMatch.group(1)}/${bpMatch.group(2)}';
      }

      // Cholesterol parsing: e.g., 'Cholesterol - 190.5'
      final cholRegex = RegExp(
          r'\b(?:Cholesterol|Chol|Total\s*Cholesterol)\b\s*[:\-\=]?\s*(\d+\.?\d*)',
          caseSensitive: false);
      final cholMatch = cholRegex.firstMatch(input);
      if (cholMatch != null && cholMatch.groupCount >= 1) {
        extractedData['cholesterol'] = cholMatch.group(1)!;
      }

      // Glucose parsing: e.g., 'Glucose: 105', 'Fasting Glucose - 99'
      final glucoseRegex = RegExp(
          r'\b(?:Glucose|Blood\s*Sugar|FBS|PPBS|RBS)\b\s*[:\-\=]?\s*(\d+\.?\d*)',
          caseSensitive: false);
      final glucoseMatch = glucoseRegex.firstMatch(input);
      if (glucoseMatch != null && glucoseMatch.groupCount >= 1) {
        extractedData['glucose'] = glucoseMatch.group(1)!;
      }

      // Hemoglobin (bonus for Indian metrics): e.g., 'Hemoglobin 14.2 g/dL', 'Hb : 12.1'
      final hbRegex = RegExp(
          r'\b(?:Hemoglobin|Hb|Hbg)\b\s*[:\-\=]?\s*(\d+\.?\d*)',
          caseSensitive: false);
      final Iterable<RegExpMatch> hbMatches = hbRegex.allMatches(input);
      for (final match in hbMatches) {
        final matchText = match.group(0)!.toLowerCase();
        // Prevent matching against HbA1c
        if (!matchText.contains('a1c') && !matchText.contains('a1')) {
          extractedData['hemoglobin'] = match.group(1)!;
          break;
        }
      }
    } catch (e) {
      // Regex parsing failed on some invalid formatting. Safely catch and return whatever we got so far.
    }

    return extractedData;
  }
}
