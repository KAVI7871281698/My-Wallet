<div align="center">
  <img src="assets/images/app_logo.png" alt="My Wallet Logo" width="150"/>
  
  # 💳 My Wallet
  **A Modern, Trendy, and Secure Personal Expense Tracker**

  <p>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Firebase-%23039BE5.svg?style=for-the-badge&logo=firebase&logoColor=white" alt="Firebase" />
    <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  </p>
</div>

---

**My Wallet** is a premium, beautifully crafted personal finance application designed to help you manage your daily expenses and track your savings effortlessly. Say goodbye to spreadsheets and hello to a seamless financial experience.

---

## 📱 App Experience

Experience a clean, glassmorphic, and highly interactive user interface.

<p align="center">
  <img src="assets/images/walk1.png" width="30%" alt="Onboarding Screen 1" style="border-radius: 15px; box-shadow: 0 4px 8px rgba(0,0,0,0.2); margin: 0 10px;" />
  <img src="assets/images/walk2.png" width="30%" alt="Onboarding Screen 2" style="border-radius: 15px; box-shadow: 0 4px 8px rgba(0,0,0,0.2); margin: 0 10px;" />
  <img src="assets/images/walk3.png" width="30%" alt="Onboarding Screen 3" style="border-radius: 15px; box-shadow: 0 4px 8px rgba(0,0,0,0.2); margin: 0 10px;" />
</p>
<p align="center">
  <em>(Beautiful onboarding screens showcasing the app's modern design language)</em>
</p>

---

## ✨ Why Choose My Wallet?

### 🎨 Stunning UI / UX
- **Glassmorphism Design:** Modern aesthetic with blurred backgrounds and sleek cards.
- **Micro-Animations:** Fluid transitions and engaging animations that make budgeting fun.
- **Dark Mode Optimized:** A gorgeous, eye-friendly dark theme with vibrant accent colors.

### 🔐 Secure & Private
- **Phone Authentication:** Securely login using your mobile number via Firebase Auth.
- **100% Private Data:** We do not connect to banks. You manually enter your data, giving you total control.

### 📊 Powerful Financial Tracking
- **Interactive Dashboard:** Instantly view your total income, expenses, and savings at a glance.
- **Smart Filtering:** Effortlessly filter your transaction history by month or year.
- **Quick Logging:** Add an expense or saving record in just a few taps.

---

## 🚀 Built With Modern Tech

- **Framework**: [Flutter](https://flutter.dev/) (Cross-Platform Mobile App Development)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore)
- **Local Caching**: `shared_preferences` for lightning-fast local data access.
- **UI Libraries**: 
  - `animate_do` (for smooth micro-animations)
  - `flutter_screenutil` (for pixel-perfect responsiveness)
  - `shrink_sidemenu` (for a trendy 3D sidebar menu)

---

## 🛠️ Getting Started

Want to run this project on your own machine? Follow these simple steps:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/KAVI7871281698/My-Wallet.git
   cd my_wallet
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new project in the Firebase Console.
   - Enable **Phone Authentication** and **Firestore Database**.
   - Download the `google-services.json` file and place it in the `android/app/` directory.

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🔒 Firestore Security Rules

To ensure your data remains completely private and secure, apply these rules in your Firebase Firestore console:

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

<div align="center">
  <h3>Designed & Developed with ❤️ by Kavi</h3>
</div>
