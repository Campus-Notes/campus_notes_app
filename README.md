<div align="center">
  <img src="assets/icons/applogo.png" alt="Campus Notes+ Logo" width="620" height="620">
  
  # 📚 Campus Notes+
  
  **Your Ultimate Campus Note Sharing Platform**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Powered-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
  
  [Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Architecture](#-architecture) • [Contributing](#-contributing)
  
</div>

---

## Overview

**Campus Notes+** is a comprehensive mobile application built with Flutter that revolutionizes how students share, discover, and monetize academic notes. With a focus on security, user experience, and seamless transactions, it provides a trusted marketplace for educational content within campus communities.

### 🎯 Why Campus Notes+?

- 📖 **Easy Note Discovery**: Browse categorized notes from various subjects and courses
- 💰 **Monetization**: Students can sell their quality notes and earn money
- 🔒 **Secure Transactions**: Integrated Razorpay payment gateway for safe payments
- 🛡️ **Content Protection**: Screenshot prevention and secure PDF viewing
- 💬 **Real-time Chat**: Connect with note sellers and buyers instantly
- 🌓 **Dark Mode**: Eye-friendly interface with full dark mode support
- 📱 **Cross-Platform**: Works seamlessly on Android and iOS

---

## Features

### Authentication & Security
- **Firebase Authentication** with email/password
- **Password Reset** functionality with secure tokens
- **App Check** integration for enhanced security
- **Screen Protection** - Prevents screenshots and screen recording
- **Secure PDF Viewer** - In-app document viewing without downloads

### Notes Marketplace
- **Browse Notes** by category, subject, and price
- **Advanced Search** and filtering capabilities
- **Note Details** with preview, ratings, and seller information
- **Shopping Cart** for multiple note purchases
- **Favorites** system to save notes for later

### Payment Integration
- **Razorpay Payment Gateway** for secure transactions
- **Multiple Payment Methods** (UPI, Cards, Net Banking, Wallets)
- **Order History** and transaction tracking
- **Instant Access** to purchased notes

### User Profiles
- **Profile Management** with customizable information
- **Purchase History** tracking
- **Seller Dashboard** for note creators
- **Earnings Analytics** for sellers

### Communication
- **Real-time Chat** using Firebase Firestore
- **Buyer-Seller Messaging** for queries and support
- **Notification System** for updates

### User Experience
- **Beautiful Onboarding** with animated screens
- **Smooth Animations** throughout the app
- **Shi mmer Loading** effects for better perceived performance
- **Offline Support** with connectivity detection
- **Theme Customization** (Light/Dark modes)

---

### Tech Stack

### Frontend
- **Flutter 3.3.0+** - UI Framework
- **Provider** - State Management
- **Go Router** - Navigation
- **Google Fonts** - Typography

### Backend & Services
- **Firebase Core** - Backend infrastructure
- **Firebase Authentication** - User management
- **Cloud Firestore** - Real-time database
- **Firebase App Check** - Security

### Third-Party Integrations
- **Razorpay** - Payment processing
- **Syncfusion PDF Viewer** - Secure document viewing
- **Screen Protector** - Content protection

### Additional Packages
```yaml
Dependencies:
  - carousel_slider       # Image carousels
  - shimmer              # Loading animations
  - flutter_staggered_animations  # Smooth animations
  - file_picker          # Document selection
  - animated_text_kit    # Text animations
  - shared_preferences   # Local storage
  - connectivity_plus    # Network detection
  - http                 # API calls
  - intl                 # Internationalization
  - crypto               # Encryption utilities
```



##  Installation

### Prerequisites
- Flutter SDK (3.3.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode
- Firebase account
- Razorpay account (for payment features)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/ashwinpraveengo/campus_notes_app.git
   cd campus_notes_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android/iOS apps to your project
   - Download `google-services.json` (Android) and place it in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`
   - Run Firebase configuration:
     ```bash
     flutter pub run flutter_launcher_icons:main
     ```

4. **Environment Variables**
   - Create a `.env` file in the root directory
   - Add your configuration:
     ```env
     RAZORPAY_KEY_ID=your_razorpay_key_id
     RAZORPAY_KEY_SECRET=your_razorpay_key_secret
     ```

5. **Run the app**
   ```bash
   # For development
   flutter run
   
   # For release build
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

---

## 🏗️ Architecture

The app follows **Clean Architecture** principles with a feature-first folder structure:

```
lib/
├── main.dart                 # App entry point
├── routes.dart              # Route definitions
├── firebase_options.dart    # Firebase configuration
├── common_widgets/          # Reusable UI components
├── constants/               # App constants
├── data/                    # Data models and dummy data
├── features/                # Feature modules
│   ├── authentication/      # Auth feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── notes/              # Notes marketplace
│   ├── chat/               # Messaging system
│   ├── payment/            # Payment integration
│   ├── profile/            # User profiles
│   ├── home/               # Home dashboard
│   ├── onboarding/         # App introduction
│   └── sell_mode/          # Seller features
├── services/               # App services
│   ├── theme_service.dart
│   ├── security_service.dart
│   └── connectivity_service.dart
└── theme/                  # Theme configuration
```

### Key Architectural Decisions

- **Provider Pattern**: For state management across the app
- **Service Layer**: Abstraction for Firebase and third-party APIs
- **Repository Pattern**: Data access layer abstraction
- **Controller Pattern**: Business logic separation from UI

---

## 🔒 Security Features

1. **Screen Protection**: Prevents screenshots and screen recording on sensitive pages
2. **Firebase App Check**: Validates genuine app requests
3. **Secure PDF Viewing**: In-app viewing without file downloads
4. **Token-based Authentication**: Secure user sessions
5. **Payment Security**: PCI-compliant Razorpay integration

---

## 🎨 UI/UX Highlights

- **Material Design 3** principles
- **Smooth Animations** for better user engagement
- **Skeleton Loading** with shimmer effects
- **Responsive Design** for various screen sizes
- **Accessibility** features for inclusive design
- **Dark Mode** support with custom themes

---

## 📦 Building for Production

### Android
```bash
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Generate App Icons
```bash
flutter pub run flutter_launcher_icons:main
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and development process.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Ashwin Praveen**
- GitHub: [@campusnotes](https://github.com/teamcampusnotes)
- Email: teamcampusnotes@gmail.com

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Firebase](https://firebase.google.com) for backend services
- [Razorpay](https://razorpay.com) for payment integration
- All contributors who helped improve this project

---

## 📞 Support

If you encounter any issues or have questions:
- 📧 Email: teamcampusnotes@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/Campus-Notes/campus_notes_app/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/campus_notes_app/discussions)

---


<div align="center">
  
  ### ⭐ Star this repo if you find it helpful!
  
  Made with ❤️ by students, for students
  
  **Campus Notes+ © 2025**
  
</div>
