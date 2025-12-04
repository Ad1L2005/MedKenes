const { onCall } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");

// Ключ уже подхвачен из process.env.gemini.key
const genAI = new GoogleGenerativeAI(process.env.gemini?.key);

exports.parseMedicalRecord = onCall(async (request) => {
  const { text, patientId, doctorName } = request.data;

  if (!text || !patientId) {
    throw new Error("Текст немесе пациент ID жоқ");
  }

  const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

  const prompt = `Сен — тәжірибелі дәрігердің көмекшісісің. Төмендегі мәтіннен медициналық қорытындыны шығар:
- Диагноз (қысқа)
- Ұсыныстар (тыныштық, диета, т.б.)
- Тағайындалған дәрілер (атауы, дозасы, қанша рет, қанша күн)

Егер дәрі айтылмаса — бос массив қайтар.

Мәтін: """${text}"""

Жауап тек қана JSON болсын, қосымша сөзсіз:

{
  "diagnosis": "...",
  "recommendations": "...",
  "medicines": [
    {"name": "...", "dosage": "...", "frequency": "...", "duration": "..."}
  ]
}`;

  try {
    const result = await model.generateContent(prompt);
    const raw = result.response.text();

    // Чистим от ```json и т.п.
    const jsonStr = raw.replace(/```json|```/g, '').trim();
    const parsed = JSON.parse(jsonStr);

    return { success: true, data: parsed };
  } catch (error) {
    console.error("Parse error:", error);
    return { success: false, error: error.message };
  }
});