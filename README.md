# Student Task Manager

A comprehensive Flutter application designed to help students organize their tasks by subject, deadline, and status. Built with Material 3 design, Firebase Authentication, and SQLite for local storage.

## 📱 App Purpose

Student Task Manager provides students with a powerful tool to:
- Organize tasks by subject, deadline, and priority
- Track completion status
- View analytics and progress per subject
- Get motivational study tips
- Manage academic workload effectively

## ✨ Features

### 🖌️ UI/UX Design
- **Modern Material 3 Design**: Clean, consistent, and responsive interface
- **Premium Dashboard**: Real-time statistics with gradient cards showing:
  - Total Tasks, Completed, Pending, and Upcoming Deadlines
  - Today's Tasks with horizontal scrolling
  - Recent Tasks with priority indicators
  - Animated progress charts
- **Beautiful Navigation Drawer**: Gradient header with user profile
- **Animated Components**: Smooth animations and transitions throughout
- **Consistent Color Palette**: Professional blue-teal gradient theme
- **Pull-to-Refresh**: Update dashboard data with a swipe

### 🔐 Firebase Authentication & Storage
- **Email & Password Authentication**: Secure user registration and login
- **Cloud Firestore**: Store user profiles with full name and email
- **Real-time Sync**: Instant updates when user data changes
- **Automatic Session Management**: Seamless authentication state handling
- **Error Handling**: User-friendly error messages
- **User Data Isolation**: Secure data storage per user

### 💾 Task Management
- **Full CRUD Support**: Create, Read, Update, and Delete operations
- **Task Fields**:
  - Title, Description, Subject
  - Deadline with time tracking
  - Priority (Low/Medium/High) with color coding
  - Status (Pending/Completed)
- **Advanced Filtering**:
  - Filter by status (All/Pending/Completed)
  - Filter by subject
  - Combined filters for precise search
- **Today's Tasks**: Focus on tasks due today
- **Upcoming Deadlines**: Show tasks due within 3 days
- **Overdue Indicators**: Visual warnings for overdue tasks
- **Form Validation**: Comprehensive validation before saving

### 🆕 Enhanced Features
- **Calendar View**: See tasks organized by date
- **Notifications**: View overdue and upcoming task reminders
- **Smart Reminders**: "Due today", "Due tomorrow", "X days left"
- **Profile Management**: Edit name and profile picture
- **Password Change**: Secure password updates
- **Task Statistics**: Visual progress tracking

### 🧩 Code Quality & Organization
- **Clean Architecture**: Well-organized folder structure
- **State Management**: Provider pattern for reactive UI
- **Code Comments**: Comprehensive documentation
- **Naming Conventions**: Clear and descriptive throughout
- **Error Handling**: Robust error management
- **Debug Logging**: Enhanced logging for troubleshooting

## 🛠️ Technologies Used

- **Flutter** (Latest version with SDK ^3.8.1)
- **Firebase Core** (v2.24.2) - Firebase initialization
- **Firebase Auth** (v4.16.0) - Email & password authentication
- **SQLite** (sqflite v2.3.0) - Local database storage
- **Provider** (v6.1.1) - State management
- **Intl** (v0.19.0) - Date formatting
- **Shared Preferences** (v2.2.2) - User preferences storage

## 🚀 How to Run the App

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Setup Instructions

1. **Clone or navigate to the project directory**
   ```bash
   cd students_task_manager
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (Required for authentication)
   
   Run the FlutterFire CLI to configure Firebase:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=student-task-manager-4bc6a --platforms=android
   ```
   
   This will automatically:
   - Generate `lib/firebase_options.dart` with Firebase configuration
   - Configure your `google-services.json` file
   - Set up Firebase for your Android app

   **Note:** The app is already configured with Firebase. If you're setting up on a new machine, follow the steps above.

4. **Run the App**
   ```bash
   flutter run
   ```

### Firebase Configuration Note
The app is designed to work with Firebase Authentication. After you provide the `google-services.json` file, the authentication features will be fully functional. The app will still compile and run without Firebase configuration, but authentication won't work until Firebase is properly set up.

## 📂 Project Structure

```
lib/
├── models/
│   └── task_model.dart          # Task data model
├── services/
│   ├── database_service.dart    # SQLite CRUD operations
│   └── auth_service.dart        # Firebase authentication
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   └── task_provider.dart       # Task state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Login screen
│   │   └── register_screen.dart # Registration screen
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Main dashboard
│   ├── tasks/
│   │   ├── task_list_screen.dart      # Task listing with filters
│   │   └── add_edit_task_screen.dart  # Add/Edit task form
│   ├── study_tips/
│   │   └── study_tips_screen.dart     # Study tips and quotes
│   └── analytics/
│       └── analytics_screen.dart      # Analytics and progress
├── widgets/
│   ├── stats_card.dart          # Statistics display card
│   └── task_card.dart           # Task display card
└── main.dart                    # App entry point
```

## 📋 Features Walkthrough

### 1. Authentication
- **Login**: Users can log in with email and password
- **Registration**: New users can create an account
- **Session Management**: Automatic login state persistence
- **Logout**: Secure logout functionality

### 2. Dashboard
- **Statistics Overview**: View total, completed, and pending tasks
- **Quick Actions**: Fast access to common operations
- **Navigation**: Easy access to all app sections

### 3. Task Management
- **Add Tasks**: Create new tasks with all required fields
- **Edit Tasks**: Update existing task details
- **Delete Tasks**: Remove tasks with confirmation
- **Mark Complete**: Toggle task completion status
- **Filter Tasks**: Filter by status or subject

### 4. Study Tips
- **Motivational Quotes**: Random inspirational quotes
- **Study Techniques**: Tips for effective studying
- **Interactive**: Refresh to get new tips

### 5. Analytics
- **Progress Tracking**: View completion percentage per subject
- **Visual Charts**: Progress bars for easy visualization
- **Overall Statistics**: Summary of task completion

## 🎨 Design Features

- **Material 3**: Latest Material Design guidelines
- **Consistent Theming**: Unified color scheme throughout
- **Responsive Layout**: Adapts to different screen sizes
- **Smooth Animations**: Enhanced user experience
- **Accessible**: Clear labels and intuitive navigation

## 🔒 Security

- **User Data Isolation**: Each user's tasks are isolated by Firebase User ID
- **Secure Authentication**: Firebase Authentication for secure login
- **Local Encryption**: SQLite database with user-specific data
- **Input Validation**: All forms validated before submission

## 📝 Code Comments

Important parts of the code are thoroughly commented, including:
- Model definitions and methods
- Service layer operations
- Provider state management logic
- Complex UI components
- Business logic explanations

## 🐛 Troubleshooting

### Firebase Not Initialized
If you see Firebase initialization errors:
1. Ensure `google-services.json` is in the correct location
2. Verify Firebase project configuration
3. Check that Firebase plugins are properly configured

### Database Errors
If SQLite operations fail:
1. Check device storage permissions
2. Verify database initialization
3. Check for database version conflicts

### Build Errors
If the app fails to build:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Ensure all dependencies are compatible

## 🤝 Contributing

This is a student project following a specific rubric. The codebase is well-organized and documented for easy maintenance and extension.

## 📄 License

This project is created for educational purposes as part of a Flutter development course.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication services
- Material Design team for the design system

---

**Note**: Remember to add your `google-services.json` file to enable Firebase Authentication features!
