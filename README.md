# Intelligent Diary 📖

A privacy-first, offline-first smart diary application built with Flutter. Intelligent Diary combines the security of local data storage with the power of advanced AI to help you document, reflect, and gain insights from your daily life.

## Features ✨

* **Privacy-First & Offline-First**: Your data is yours. All diary entries are stored locally on your device using SQLite. No cloud syncing means complete privacy.
* **Smart AI Insights**: Leveraging the blazing-fast Groq API, the app provides AI-driven insights and reflections on your entries without compromising the permanent storage of your data.
* **Interactive AI Chat**: Chat with your diary! Ask questions about your past entries or get personalized prompts.
* **Calendar View**: Easily navigate and visualize your writing habits with an intuitive calendar interface.
* **Modern & Clean UI**: A beautiful, distraction-free environment to write your thoughts.

## Tech Stack 🛠️

* **Framework**: Flutter
* **State Management**: Riverpod (for robust, scalable state handling)
* **Local Storage**: SQLite (via `sqflite`)
* **AI Integration**: Groq API via HTTP
* **Architecture**: Service-oriented structure ensuring API calls and business logic remain strictly isolated from the UI.

## Getting Started 🚀

### Prerequisites

* Flutter SDK (latest stable version)
* An active [Groq API Key](https://console.groq.com/keys)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ahmettsadik/Diary_AI.git
   cd Diary_AI
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory of the project and add your Groq API key:
   ```env
   GROQ_API_KEY=your_api_key_here
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Architecture 🏗️

This app follows standard object-oriented principles to ensure maintainability:
- `lib/models/`: Data classes for entries and app objects.
- `lib/providers/`: Riverpod providers for dependency injection and state management.
- `lib/screens/`: UI presentation layer.
- `lib/services/`: External integrations (LLM API, Background Tasks) and database helpers.

## License 📄

This project is licensed under the MIT License.
