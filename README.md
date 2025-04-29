# ⚽ Saudi Pro League Matches App

<div align="center">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" alt="iOS Version">
  <img src="https://img.shields.io/badge/Xcode-15.0+-blue.svg" alt="Xcode Version">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</div>

## 📱 Overview

A modern iOS application that provides real-time access to Saudi Pro League matches, featuring live scores, upcoming fixtures, and match results. The app offers a clean, intuitive interface with match grouping by date and comprehensive match details.

## ✨ Features

- 🎯 **Live Matches**
  - Real-time match updates
  - Live scores
  - Match status indicators

- 📅 **Upcoming Matches**
  - Date-grouped fixtures
  - Match time and venue
  - Team information

- 📊 **Match Results**
  - Historical match data
  - Detailed scores
  - Team statistics

## 🛠 Technical Stack

- **Language:** Swift 5.9
- **Framework:** SwiftUI
- **Architecture:** MVVM
- **API Integration:** RESTful API
- **Data Management:** Async/Await

## 📦 Project Structure

```
football/
├── Models/
│   ├── Match.swift
│   └── News.swift
├── Views/
│   ├── MatchesView.swift
│   ├── NewsView.swift
│   └── ProfileView.swift
├── ViewModels/
│   └── MatchesViewModel.swift
└── Services/
    └── NetworkService.swift
```

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 15.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository
```bash
git clone https://github.com/alshehri12/korah.git
```

2. Open the project in Xcode
```bash
cd korah
open football.xcodeproj
```

3. Build and run the project

## 🎨 UI/UX Features

- **Modern Design**
  - Clean and intuitive interface
  - Smooth animations
  - Responsive layout

- **Match Organization**
  - Date-based grouping
  - Status indicators
  - Team logos and information

- **User Experience**
  - Pull-to-refresh functionality
  - Tab-based navigation
  - Error handling and loading states

## 🔄 API Integration

The app integrates with the Football API to fetch:
- Live match data
- Upcoming fixtures
- Match results
- Team information

## 📱 Screenshots

[Add screenshots here]

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Abdulrahman Alshehri
- GitHub: [@alshehri12](https://github.com/alshehri12)

## 🙏 Acknowledgments

- Football API for providing match data
- SwiftUI for the amazing UI framework
- The open-source community for their support

---

<div align="center">
  Made with ❤️ by Abdulrahman Alshehri
</div> 