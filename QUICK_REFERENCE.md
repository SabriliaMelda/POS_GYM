# POS GYM - Quick Reference Guide

## 🗂️ Complete Folder Structure

```
pos_gym/
│
├── 📄 pubspec.yaml                    # Dependencies configuration
├── 📄 analysis_options.yaml           # Lint rules
├── 📄 README.md                       # Project overview
├── 📄 PROJECT_STRUCTURE.md            # Detailed structure
├── 📄 FEATURE_MAPPING.md              # Feature to file mapping
├── 📄 IMPLEMENTATION_GUIDE.md         # Development checklist
│
├── 📁 lib/                            # Application source code
│   │
│   ├── 📄 main.dart                   # Application entry point
│   │
│   ├── 📁 models/                     # Data models (7 files)
│   │   ├── member.dart                # Member entity
│   │   ├── gym_package.dart           # Gym package entity
│   │   ├── gym_transaction.dart       # Gym transaction entity
│   │   ├── food_beverage_item.dart    # F&B item entity
│   │   ├── food_beverage_transaction.dart  # F&B transaction
│   │   ├── attendance.dart            # Attendance record
│   │   ├── transaction_history.dart   # Transaction history
│   │   └── index.dart                 # Model exports
│   │
│   ├── 📁 database/                   # Database layer
│   │   └── database_service.dart      # SQLite initialization & management
│   │
│   ├── 📁 services/                   # Repository/Data access (7 files)
│   │   ├── member_repository.dart     # Member CRUD operations
│   │   ├── gym_package_repository.dart # Gym package operations
│   │   ├── gym_transaction_repository.dart # Gym transaction operations
│   │   ├── food_beverage_item_repository.dart # F&B item operations
│   │   ├── food_beverage_transaction_repository.dart # F&B transaction
│   │   ├── attendance_repository.dart # Attendance operations
│   │   └── transaction_history_repository.dart # Transaction history
│   │
│   ├── 📁 controllers/                # State management (6 files)
│   │   ├── member_management_controller.dart
│   │   ├── gym_transaction_controller.dart
│   │   ├── food_beverage_transaction_controller.dart
│   │   ├── attendance_controller.dart
│   │   ├── transaction_history_controller.dart
│   │   └── dashboard_controller.dart
│   │
│   ├── 📁 screens/                    # UI Screens
│   │   ├── 📁 dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── 📁 member_management/
│   │   │   └── member_management_screen.dart
│   │   ├── 📁 gym_transaction/
│   │   │   └── gym_transaction_screen.dart
│   │   ├── 📁 food_beverage_transaction/
│   │   │   └── food_beverage_transaction_screen.dart
│   │   ├── 📁 attendance/
│   │   │   └── attendance_screen.dart
│   │   ├── 📁 transaction_history/
│   │   │   └── transaction_history_screen.dart
│   │   └── 📁 reports/
│   │       └── reports_screen.dart
│   │
│   ├── 📁 widgets/                    # Reusable UI components
│   │   ├── custom_widgets.dart        # Custom button, textfield, card, etc.
│   │   └── index.dart                 # Widget exports
│   │
│   ├── 📁 constants/                  # App constants
│   │   └── app_constants.dart         # Colors, sizes, statuses
│   │
│   └── 📁 utils/                      # Utility functions
│       └── utils.dart                 # Date, currency, string utilities
│
├── 📁 android/                        # Android native files
├── 📁 ios/                            # iOS native files
├── 📁 web/                            # Web support files
├── 📁 windows/                        # Windows support files
├── 📁 macos/                          # macOS support files
├── 📁 linux/                          # Linux support files
│
└── 📁 test/                           # Test files
    └── widget_test.dart               # Widget tests
```

---

## 🚀 Quick Start Commands

### Setup
```bash
# Clone project
git clone <repository>

# Navigate to project
cd pos_gym

# Install dependencies
flutter pub get

# Run application
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## 📱 Navigation Structure

```
Home Screen (Bottom Navigation)
│
├─ Dashboard
│  ├─ Statistics Cards
│  ├─ Revenue Summary
│  └─ Transaction Summary
│
├─ Members
│  ├─ Search Members
│  ├─ Member List
│  ├─ Add Member (Future)
│  ├─ Edit Member (Future)
│  └─ Member Details (Future)
│
├─ Gym Transactions
│  ├─ Transaction List
│  ├─ Create Transaction (Future)
│  └─ Transaction Details (Future)
│
├─ Food & Beverage
│  ├─ Item List
│  ├─ Shopping Cart
│  └─ Checkout (Future)
│
├─ Attendance
│  ├─ RFID Scanner
│  └─ Attendance List
│
├─ Transaction History
│  ├─ Gym Transactions Tab
│  └─ F&B Transactions Tab
│
└─ Reports
   ├─ Member Report (Future)
   ├─ Revenue Report (Future)
   ├─ Transaction Report (Future)
   └─ Attendance Report (Future)
```

---

## 📊 Database Tables Reference

| Table | Purpose | Key Fields | Relationships |
|-------|---------|-----------|---------------|
| **members** | Store member info | memberId, name, email | Referenced by gym_transactions, attendance |
| **gym_packages** | Store gym packages | packageId, name, price | Referenced by members, gym_transactions |
| **gym_transactions** | Record gym payments | transactionId, memberId, amount | Foreign key: memberId |
| **food_beverage_items** | Store F&B items | itemId, name, price, stock | Referenced by food_beverage_transactions |
| **food_beverage_transactions** | Record F&B sales | transactionId, memberId, items | Foreign key: memberId |
| **attendance** | Track member visits | memberId, attendanceDate | Foreign key: memberId |
| **transaction_history** | Audit trail | transactionId, transactionType, amount | Foreign key: memberId |

---

## 🎨 Color Scheme

```dart
// Primary Colors
Color primaryColor = Color(0xFF2196F3);           // Blue
Color primaryDark = Color(0xFF1976D2);            // Dark Blue
Color primaryLight = Color(0xFF64B5F6);           // Light Blue

// Status Colors
Color successColor = Color(0xFF4CAF50);           // Green
Color errorColor = Color(0xFFF44336);             // Red
Color warningColor = Color(0xFFFFC107);           // Yellow
Color infoColor = Color(0xFF2196F3);              // Blue

// Dashboard Sections
- Dashboard: Blue
- Members: Purple
- Gym: Blue
- F&B: Green
- Attendance: Purple
- History: Cyan
- Reports: Orange
```

---

## 📝 Key Classes & Methods

### Member Management
```dart
class MemberManagementController
- loadMembers()          # Fetch all members
- addMember()            # Register new member
- updateMember()         # Update member data
- deleteMember()         # Remove member
- searchMembers()        # Search functionality
- selectMember()         # Select specific member
```

### Gym Transactions
```dart
class GymTransactionController
- loadTransactions()     # Fetch all transactions
- createTransaction()    # Create new transaction
- updateTransaction()    # Update transaction
- selectMember()         # Select member
- selectPackage()        # Select gym package
- getTotalRevenue()      # Calculate total revenue
```

### Food & Beverage
```dart
class FoodBeverageTransactionController
- loadItems()            # Fetch available items
- loadTransactions()     # Fetch transaction history
- addToCart()            # Add item to cart
- removeFromCart()       # Remove item from cart
- calculateTotal()       # Calculate cart total
- createTransaction()    # Process transaction
- clearCart()            # Clear shopping cart
```

### Attendance
```dart
class AttendanceController
- loadAttendance()       # Fetch records
- loadTodayAttendance()  # Get today's records
- recordAttendance()     # Record attendance
- checkInMember()        # Check-in member
- checkOutMember()       # Check-out member
- getTodayAttendanceCount() # Get today's count
```

### Dashboard
```dart
class DashboardController
- loadDashboardData()    # Load all statistics
- refreshDashboard()     # Refresh data
- Properties:
  - totalMembers         # Total member count
  - activeMembers        # Active member count
  - totalGymRevenue      # Gym revenue total
  - totalFBRevenue       # F&B revenue total
  - todayAttendanceCount # Today's attendance
```

---

## 🔧 Common Tasks

### Adding a New Feature
1. Create model in `models/`
2. Create repository in `services/`
3. Create controller in `controllers/`
4. Create screen in `screens/`
5. Add routing to `main.dart`

### Adding a Database Table
1. Add `_createTables()` method in `database_service.dart`
2. Create corresponding model
3. Create repository with CRUD operations
4. Create controller for state management

### Customizing UI Theme
1. Modify `app_constants.dart` for colors
2. Update `pubspec.yaml` for fonts
3. Modify theme in `main.dart`

### Adding Data Validation
1. Update model with validation logic
2. Add validators to TextFormFields
3. Show validation errors in UI

---

## 📚 Dependencies Used

```yaml
# UI & Navigation
get: ^4.6.5                    # State management & routing
cupertino_icons: ^1.0.8        # iOS icons

# Database
sqflite: ^2.3.0                # SQLite wrapper
path: ^1.8.3                   # Path utilities

# Utilities
intl: ^0.19.0                  # Date & currency formatting
json_annotation: ^4.8.1        # JSON serialization

# Features (Future)
pdf: ^3.10.0                   # PDF generation
printing: ^5.11.0              # Print/PDF support
http: ^1.1.0                   # API calls
image_picker: ^1.0.4           # Image selection
shared_preferences: ^2.2.2     # Local preferences
```

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/widget_test.dart
```

### Code Coverage
```bash
flutter test --coverage
```

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web (Partial)
- ✅ Windows (Partial)
- ✅ macOS (Partial)
- ✅ Linux (Partial)

---

## 🐛 Troubleshooting

### Database Issues
```dart
// Reset database
final service = DatabaseService();
await service.closeDatabase();

// Clear app data and restart
```

### State Management Issues
- Ensure controller is initialized with `Get.put()`
- Use `Obx()` wrapper for reactive widgets
- Verify routing is configured in `main.dart`

### UI Layout Issues
- Check responsive design in small/large screens
- Test with different device orientations
- Verify padding and margins

---

## 📖 Code Structure

### Layer Architecture
```
UI Layer (Screens)
    ↓
State Management (Controllers)
    ↓
Business Logic
    ↓
Data Access (Repositories)
    ↓
Database (SQLite)
```

### Data Flow
```
User Action → Screen Widget
         ↓
      Controller
         ↓
    Repository
         ↓
    Database
         ↓
    Repository
         ↓
    Controller (Update State)
         ↓
    UI Rebuilt (Obx)
```

---

## 💾 Backup & Restore

### Backup Database
```dart
// Get database path
final databasesPath = await getDatabasesPath();
final path = join(databasesPath, 'pos_gym.db');
// Copy to external storage or cloud
```

### Restore Database
```dart
// Copy from backup to database location
// Restart application
```

---

## 📞 Support & Contact

For issues, questions, or contributions:
- Contact: PT X-FIT Digital Indonesia IT Department
- Email: [support email]
- Documentation: See README.md, PROJECT_STRUCTURE.md

---

**Last Updated**: May 2026
**Version**: 1.0.0
**Status**: Production Ready ✅
