# POS GYM - PT X-FIT Digital Indonesia

A comprehensive Flutter-based Point of Sale (POS) system designed specifically for managing gym memberships and food & beverage transactions at PT X-FIT Digital Indonesia Jakarta.

## Project Overview

This application addresses the operational challenges of PT X-FIT Digital Indonesia by providing an integrated system for:

- **Gym Membership Management**: Registration, payment, renewal, and status tracking
- **Gym Transaction Processing**: Membership purchases and renewals
- **Food & Beverage Sales**: POS system for F&B transactions
- **Member Attendance Tracking**: RFID card integration and check-in/check-out
- **Transaction History**: Comprehensive record of all transactions
- **Reports & Analytics**: Revenue reports, member statistics, and transaction summaries

## Project Structure

```
lib/
├── models/              # Data models
│   ├── member.dart
│   ├── gym_package.dart
│   ├── gym_transaction.dart
│   ├── food_beverage_item.dart
│   ├── food_beverage_transaction.dart
│   ├── attendance.dart
│   ├── transaction_history.dart
│   └── index.dart
│
├── database/            # Database layer
│   └── database_service.dart
│
├── services/            # Repository/Data access layer
│   ├── member_repository.dart
│   ├── gym_package_repository.dart
│   ├── gym_transaction_repository.dart
│   ├── food_beverage_item_repository.dart
│   ├── food_beverage_transaction_repository.dart
│   ├── attendance_repository.dart
│   └── transaction_history_repository.dart
│
├── controllers/         # State management (GetX)
│   ├── member_management_controller.dart
│   ├── gym_transaction_controller.dart
│   ├── food_beverage_transaction_controller.dart
│   ├── attendance_controller.dart
│   ├── transaction_history_controller.dart
│   └── dashboard_controller.dart
│
├── screens/             # UI Screens
│   ├── dashboard/
│   ├── member_management/
│   ├── gym_transaction/
│   ├── food_beverage_transaction/
│   ├── attendance/
│   ├── transaction_history/
│   └── reports/
│
├── widgets/             # Reusable components
│   ├── custom_widgets.dart
│   └── index.dart
│
├── constants/           # App constants
│   └── app_constants.dart
│
├── utils/               # Utility functions
│   └── utils.dart
│
└── main.dart            # Application entry point
```

## Features

### 1. Dashboard
- Summary of key metrics (total members, active members, expired members, today's attendance)
- Revenue breakdown (gym transactions, food & beverage)
- Transaction statistics
- Real-time data refresh

### 2. Member Management
- Add new members with detailed information
- Search members by name, ID, or phone number
- View member details and status
- Update member information
- Track membership expiry dates
- Delete member records
- Automatic warning for expiring memberships (within 7 days)

### 3. Gym Transaction
- Create new gym membership transactions
- Select member and package
- Record payment method and status
- Automatic membership expiry date calculation
- View transaction history
- Filter transactions by date range
- Revenue tracking

### 4. Food & Beverage Transaction
- Browse available items by category
- Add items to shopping cart
- Manage quantities in cart
- Apply discounts and taxes
- Process payment with multiple payment methods
- Optional member linking
- Receipt generation

### 5. Attendance Management
- RFID card check-in/check-out
- Daily attendance tracking
- Member check-in with automatic timestamp
- View today's attendance summary
- Historical attendance records
- Attendance statistics per member

### 6. Transaction History
- View all gym transactions
- View all F&B transactions
- Filter by date range
- Track transaction types and status
- Member transaction history
- Revenue summary by category

### 7. Reports
- Member reports (list, status, expiry dates)
- Revenue reports (breakdown by category, time period)
- Transaction reports (detailed history, statistics)
- Attendance reports (statistics, trends)
- PDF export functionality

## Technology Stack

### Framework & UI
- **Flutter**: Cross-platform mobile development
- **Material Design 3**: Modern UI design language

### State Management
- **GetX**: State management, routing, and dependency injection

### Database
- **SQLite**: Local data persistence
- **Sqflite**: Flutter SQLite plugin

### Utilities
- **Intl**: Internationalization and date/time formatting
- **HTTP**: API calls (for future backend integration)
- **PDF**: Report generation
- **Image Picker**: Member photo upload
- **Shared Preferences**: Local preferences storage

## Getting Started

### Prerequisites
- Flutter SDK (version 3.11.5 or higher)
- Dart SDK
- Android SDK or Xcode (for iOS development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd pos_gym
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Build APK/iOS

For Android:
```bash
flutter build apk --release
```

For iOS:
```bash
flutter build ios --release
```

## Database Schema

### Tables

1. **members**
   - id (INTEGER PRIMARY KEY)
   - memberId (TEXT UNIQUE)
   - name, email, phoneNumber, address
   - gender, dateOfBirth
   - gymPackageId, registrationDate, membershipExpiryDate
   - isActive, photoPath
   - createdAt, updatedAt

2. **gym_packages**
   - id (INTEGER PRIMARY KEY)
   - packageId (TEXT UNIQUE)
   - name, description, price, durationInDays
   - isActive
   - createdAt, updatedAt

3. **gym_transactions**
   - id (INTEGER PRIMARY KEY)
   - transactionId (TEXT UNIQUE)
   - memberId, gymPackageId
   - amount, paymentMethod, status
   - transactionDate, notes
   - createdAt, updatedAt

4. **food_beverage_items**
   - id (INTEGER PRIMARY KEY)
   - itemId (TEXT UNIQUE)
   - name, description, category
   - price, stock, isActive
   - createdAt, updatedAt

5. **food_beverage_transactions**
   - id (INTEGER PRIMARY KEY)
   - transactionId (TEXT UNIQUE)
   - memberId, items, totalAmount
   - discountAmount, taxAmount, finalAmount
   - paymentMethod, status, transactionDate
   - createdAt, updatedAt

6. **attendance**
   - id (INTEGER PRIMARY KEY)
   - memberId, attendanceDate
   - checkInTime, checkOutTime, rfidCardNumber
   - createdAt, updatedAt

7. **transaction_history**
   - id (INTEGER PRIMARY KEY)
   - transactionId (TEXT UNIQUE)
   - memberId, transactionType
   - amount, description, status
   - transactionDate
   - createdAt, updatedAt

## Usage Guide

### Adding a New Member

1. Navigate to **Members** section
2. Tap the **+** button
3. Fill in member details (name, email, phone, address, etc.)
4. Select gym package and membership duration
5. Tap "Save Member"

### Creating a Gym Transaction

1. Navigate to **Gym** section
2. Tap the **+** button
3. Select member from list
4. Choose gym package
5. Enter payment details
6. Tap "Complete Transaction"

### Processing F&B Transaction

1. Navigate to **F&B** section
2. Browse available items
3. Tap **+** to add items to cart
4. Adjust quantities as needed
5. Apply discounts/taxes if applicable
6. Tap "Checkout"
7. Enter payment details
8. Complete transaction

### Recording Attendance

1. Navigate to **Attendance** section
2. Scan RFID card or enter member ID
3. System automatically records check-in time
4. View today's attendance summary

## Future Enhancements

- Backend API integration
- Cloud data synchronization
- Real-time RFID reader integration
- Multi-location support
- Advanced analytics and forecasting
- Mobile app for members
- WhatsApp integration for notifications
- Payment gateway integration
- Automated email/SMS notifications
- Backup and restore functionality

## Contributing

This project is developed as part of a thesis project. For contributions, please contact the development team.

## License

All rights reserved. PT X-FIT Digital Indonesia Jakarta.

## Support

For support and inquiries, please contact the IT department at PT X-FIT Digital Indonesia Jakarta.

---

**Project Status**: In Development
**Version**: 1.0.0
**Last Updated**: May 2026
