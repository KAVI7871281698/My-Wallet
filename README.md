# 💳 My Wallet - Modern Expense & Savings Tracker

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**My Wallet** is a premium, feature-rich personal finance management application built with Flutter and Firebase. It empowers users to track their daily expenses, manage savings, and visualize their financial health through a stunning, modern interface.

---

## ✨ Key Features

### 🔐 Advanced Authentication
*   **Phone & OTP Login**: Secure authentication using Firebase Phone Auth.
*   **User Registration**: Simple onboarding with profile setup.
*   **Mock Mode**: Built-in fallback for instant demo access when network services are restricted.
*   **Auto-Login**: Seamlessly skip intro screens once authenticated.

### 📊 Interactive Dashboard
*   **Smart Overviews**: Real-time display of total expenses and income categories.
*   **Data Caching**: Instant access to your data even offline using local hydration logic.
*   **Dynamic Filtering**: Filter financial records by Month or Year with a single click.

### 💰 Savings & Goals
*   **Simple Deposits**: Effortlessly track your growth by adding savings without complex setups.
*   **Intelligent History**: View your progress over time with built-in month/year pickers.
*   **Motivation**: Real-time status updates and encouraging micro-animations.

### 👤 User Profile & Sidebar
*   **Financial Insights**: At-a-glance stats showing total wallets, expenses, and savings.
*   **Modern Side Menu**: A high-end "Shrink & Slide" navigation experience.
*   **Secure Logout**: One-tap session termination.

---

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore)
- **Local Storage**: [SharedPreferences](https://pub.dev/packages/shared_preferences)
- **UI & Animations**: 
    - `flutter_screenutil` (Responsiveness)
    - `animate_do` (Micro-animations)
    - `shrink_sidemenu` (Navigation)
    - `month_picker_dialog` (Date selection)
- **Architecture**: Service-based Clean Architecture (AuthService, ExpenseService, SavingService).

---

## 🛠️ Installation & Setup

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/KAVI7871281698/My-Wallet.git
    cd my_wallet
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase**
    *   Create a project in the [Firebase Console](https://console.firebase.google.com/).
    *   Enable **Phone Authentication** and **Firestore Database**.
    *   Add your `google-services.json` (Android) to `android/app/`.

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```text
lib/
├── Core/          # Constants and theme configurations
├── Models/        # Data models (User, Expense, Saving)
├── Screens/       # UI Screens (Dashboard, Auth, Savings, etc.)
├── Services/      # Firebase and Logic services
├── Widgets/       # Reusable UI components
└── main.dart      # App entry point
```

---

## 📢 Firestore Rules (Required)
To ensure the app works correctly, apply these rules in your Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null && (request.resource.data.userId == request.auth.uid || resource.data.userId == request.auth.uid);
    }
    match /savings/{savingId} {
      allow read, write: if request.auth != null && (request.resource.data.userId == request.auth.uid || resource.data.userId == request.auth.uid);
    }
  }
}
```

---

## 🤝 Contributing
Feel free to fork this project and submit a Pull Request! Any contribution to improve the UI or functionality is welcome.

---

### Developed with ❤️ by Kavi
