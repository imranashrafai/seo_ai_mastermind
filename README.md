# 🚀 SEO AI Mastermind – Flutter Application

A modern Flutter-based SEO toolkit app designed for content creators, marketers, and SEO professionals. This app integrates AI-powered tools for keyword research, content generation, and SEO analytics — all wrapped in a beautiful, theme-aware UI.

---

## ✨ Features

- 🔐 Firebase Authentication with user role (Pro/Free) handling.
- 📊 Pro Dashboard for advanced analytics and tools.
- 🤖 AI Content Generation using OpenAI (ChatGPT).
- 🔍 Keyword Research powered by Hugging Face Transformers.
- 🧠 Built-in SEO Analyzer and Competitor Insights.
- 💬 AI Chatbot Assistant with persistent history.
- 🌙 Dark and Light Mode toggle with Riverpod.

---

## 📁 Project Structure

```plaintext
lib/
├── chatbot/
│   └── chat.dart
├── models/
│   └── onboarding_model.dart
├── providers/
│   ├── auth_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── auth/
│   ├── dashboard/
│   ├── onboarding/
│   ├── profile/
│   ├── splash/
│   ├── subscription/
│   └── tools/
│       ├── keyword_ai_screen.dart
│       ├── seo_analyzer_screen.dart
│       └── home_screen.dart
├── services/
│   ├── chatbotService.dart
│   └── keyword_ai_service.dart
├── constants.dart
├── firebase_options.dart
└── main.dart
```


---

## Getting Started

### Prerequisites

- Flutter SDK installed
- Firebase project configured
- `.env` file for API keys (stored securely)

```env
OPENAI_API_KEY=your_openai_key
HUGGINGFACE_API_KEY=your_huggingface_key

git clone https://github.com/imranashrafai/seo_ai_mastermind.git
cd seo_ai_mastermind
flutter pub get
flutter run
```
---
## Major Dependencies
- firebase_auth + cloud_firestore
- flutter_riverpod
- http
- flutter_dotenv

## 📜 License
This project is licensed under the MIT License.

## 👨‍💻 Developed By

**Imran Ashraf**  
📧 Email: [imranashraf0k@gmail.com](mailto:imranashraf0k@gmail.com)  
🔗 GitHub: [imranashrafai](https://github.com/imranashrafai)  
🔗 LinkedIn: [imranashrafai](https://www.linkedin.com/in/imranashrafai)


