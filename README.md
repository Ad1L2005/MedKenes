# Medkenes 🩺

**Medkenes** is a modern platform for the digital transformation of healthcare in Kazakhstan. The platform helps medical organizations, doctors, and patients work faster, more accurately, and more conveniently.

---

## 🚀 Overview

Medkenes is an ecosystem that unifies the core tools clinics and patients need:

* Next-generation **Electronic Medical Record (EMR)** with smart autofill
* **Telemedicine** consultations
* Integration with government services (RPN, EGIZ, Damumed, etc.)
* **AI assistant** for clinicians to automate routine tasks
* Mobile application for patients (Flutter)

We focus on accessibility, data security, and human-centered care.

---

## ✨ Key Features

### For doctors

* Smart EMR with autofill and structured templates
* Voice input for patient history and notes
* AI-powered diagnostic suggestions and clinical prompts
* Clinical templates and treatment protocols

### For clinics

* Full integration with state systems and reporting
* Document automation and electronic paperwork
* Analytics and financial reports
* Built-in payment / POS for clinic cash flows

### For patients

* Personal profile and visit history
* Online appointment booking and telemedicine
* Push notifications and appointment reminders
* Access to lab results and prescribed treatment plans

---

## 🛠️ Tech Stack

* **Backend:** Node.js, Firebase
* **Frontend / Mobile:** Flutter
* **Database:** Firebase (Realtime / Firestore)
* **AI:** Grok + OpenAI
* **CI / CD:** (you can add GitHub Actions / other pipelines)

---

## 📱 Demo

Mobile application — coming soon to App Store and Google Play.

(Place screenshots or a demo GIF in `/assets` or GitHub Releases.)

---

## 🔧 Installation (Developer)

```bash
# Clone
git clone https://github.com/Ad1L2005/medkenes.git
cd medkenes

# Install dependencies
pnpm install

# Copy example env
cp .env.example .env
# Edit .env with your keys (Firebase, OpenAI, etc.)

# Run in development
pnpm run start:dev
```

### Required environment variables (example)

```
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
OPENAI_API_KEY=sk-xxxxx
GROK_API_KEY=xxx
```

> **Security note:** Never commit real API keys or credentials to the repository. Use GitHub Secrets for CI and `.env` locally.

---

## 📦 Project structure (example)

```
/medkenes
  /apps
    /mobile      # Flutter app
    /web         # Admin / clinic dashboard
  /packages
    /common      # shared utilities
  /functions     # Node.js backend / Firebase functions
  .env.example
  README.md
```

---

## 🧪 Testing

Provide instructions here how to run unit/integration tests for backend and mobile. Example:

```bash
pnpm test
# or for Flutter
flutter test
```

---

## 🚀 Deployment

Short notes on deploying backend and mobile builds. Use Firebase Hosting / Cloud Functions for backend and Play/App Store flows for mobile releases.

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit your changes: `git commit -m "feat: add ..."`
4. Push and open a Pull Request

Add an issue template and PR template to streamline contributions.

---

## 🔐 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

Maintainer: Adil (Ad1L)

* Email: [adil.nurgozha@gmail.com](mailto:adil.nurgozha@gmail.com)
* GitHub: [https://github.com/Ad1L2005](https://github.com/Ad1L2005)
