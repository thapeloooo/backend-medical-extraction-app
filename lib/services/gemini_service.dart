
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {

  // ==========================================
  // GEMINI AI MODEL
  // ==========================================

  final _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
    ),
  );

  // ==========================================
  // FUNCTION 1: EXTRACT MEDICAL DATA
  // ==========================================

  Future<String> extractMedicalData(
    String clinicalText,
  ) async {

    if (clinicalText.trim().isEmpty) {
      throw ArgumentError(
        'Clinical record cannot be empty',
      );
    }

    final prompt = '''
Extract structured medical information from
the following clinical record.

Return a JSON object containing:

- patient_name
- diagnosis
- medications
- allergies
- appointment_date
- referral_information

Use null for missing information.

Only extract information explicitly provided.
Do not invent medical facts.
Do not provide medical advice.

Clinical record:
$clinicalText
''';

    final response = await _model.generateContent([
      Content.text(prompt),
    ]);

    if (response.text == null ||
        response.text!.isEmpty) {
      throw Exception(
        'Gemini returned an empty response',
      );
    }

    return response.text!;
  }

  // ==========================================
  // FUNCTION 2: GENERATE PATIENT SUMMARY
  // ==========================================

  Future<String> generatePatientSummary(
    Map<String, dynamic> patientData,
  ) async {

    if (patientData.isEmpty) {
      throw ArgumentError(
        'Patient information cannot be empty',
      );
    }

    final summaryModel =
        FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );

    final prompt = '''
You are a clinical documentation assistant
for the MediBrief healthcare application.

Generate a clear and professional patient
medical summary using the information below.

The summary must contain:

1. PATIENT OVERVIEW
   - Patient name
   - Age

2. MEDICAL HISTORY
   - Known diagnoses
   - Relevant medical conditions

3. CURRENT MEDICATIONS
   - List prescribed medications

4. ALLERGIES
   - List known allergies

5. RECENT VISITS
   - Summarise recent appointments

6. CLINICAL NOTES
   - Summarise important observations

IMPORTANT RULES:
- Only use the supplied patient information.
- Do not invent diagnoses or medications.
- If information is missing, write
  "Not documented".
- Do not provide treatment recommendations.
- Do not provide medical advice.
- Keep the summary concise and factual.
- The summary must be reviewed by
  healthcare staff before being saved.

PATIENT INFORMATION:

Name: ${patientData['name'] ?? 'Not documented'}

Age: ${patientData['age'] ?? 'Not documented'}

Diagnoses:
${patientData['diagnoses'] ?? 'Not documented'}

Medications:
${patientData['medications'] ?? 'Not documented'}

Allergies:
${patientData['allergies'] ?? 'Not documented'}

Recent Visits:
${patientData['recentVisits'] ?? 'Not documented'}

Clinical Notes:
${patientData['notes'] ?? 'Not documented'}
''';

    final response = await summaryModel.generateContent([
      Content.text(prompt),
    ]);

    if (response.text == null ||
        response.text!.trim().isEmpty) {
      throw Exception(
        'Gemini could not generate a patient summary',
      );
    }

    return response.text!.trim();
  }
}

