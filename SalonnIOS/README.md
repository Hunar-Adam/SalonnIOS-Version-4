# Salonn iOS App

A beauty and wellness appointment booking application built with SwiftUI.

## Features

- Full email/password authentication
- User profile management
- Role-based permissions (Customer, Salon Staff, Salon Owner, Admin)
- Beautiful and modern UI
- Multiple environment support (Dev, Staging, Production)

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+
- Firebase

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/SalonnIOS.git
cd SalonnIOS
```

2. Install dependencies (if using CocoaPods)
```bash
pod install
```

3. Add your Firebase configuration files:
- Add `GoogleService-Info-Dev.plist` for development
- Add `GoogleService-Info-Staging.plist` for staging
- Add `GoogleService-Info-Prod.plist` for production

4. Open the project in Xcode
```bash
open SalonnIOS.xcworkspace # if using CocoaPods
# or
open SalonnIOS.xcodeproj # if not using CocoaPods
```

5. Build and run the project

## Environment Configuration

The app supports three environments:
- Development (Dev)
- Staging
- Production

Each environment has its own:
- Bundle identifier
- Firebase configuration
- API endpoints

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details 