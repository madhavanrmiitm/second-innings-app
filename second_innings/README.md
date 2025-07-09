# Second Innings User App

This is the user-facing application for the Second Innings project, built with Flutter and Dart. For the old, by the young.

**Live Demo:** **[https://second-innings-iitm.web.app](https://second-innings-iitm.web.app)**

> **Note:** The application is designed and optimized for a mobile-only viewing experience, as it is primarily intended for senior citizens.

## Features

The application provides a comprehensive set of features tailored to three main user roles: Senior Citizens, Family Members, and Caregivers.

### General

-   **Enhanced Authentication**: Complete Google Sign-In integration with backend verification and automatic session management.
-   **Auto-Login**: Intelligent session detection that automatically navigates users to their appropriate dashboard on app startup.
-   **Session Management**: Secure user data storage with automatic session validation and logout functionality.
-   **Personalized Experience**: Dynamic user names and context displayed throughout the app from stored user data.
-   **Help & Support**: Users can create, view, and manage support tickets.

### For Senior Citizens

-   **Profile Management**: View and edit their profile.
-   **Task Management**: Create, view, and edit personal tasks and reminders.
-   **Family Management**: Link new family members, view linked members, and manage relationships.
-   **Caregiver Management**: Browse available caregivers, view their details, send hiring requests, and manage hired caregivers.
-   **Local Interest Groups**: View, join, create, and manage local community groups.
-   **Notifications**: Receive updates and alerts.

### For Family Members

-   **Profile Management**: View and edit their profile.
-   **Senior Citizen Management**:
    -   Link new senior citizen profiles.
    -   View and manage linked senior citizens.
    -   View, create, and edit tasks and reminders on behalf of the senior citizen.
-   **Caregiver Management**: Hire, view, and manage caregivers for their linked senior citizens.
-   **Notifications**: Receive updates related to their family members.

### For Caregivers

-   **Profile Management**: View and edit their professional profile.
-   **Approval Status**: Check the status of their registration approval.
-   **Job Management**: View available job opportunities, apply for jobs, and manage current assignments.
-   **Notifications**: Receive job alerts and other notifications.

## Architecture & Session Management

### Session Management System

The app implements a comprehensive session management system that provides:

- **Automatic Login Detection**: App checks user session on startup and navigates to appropriate dashboard
- **Session Validation**: Real-time session validation across all screens with automatic redirect if invalid
- **Secure Data Storage**: User data stored securely using SharedPreferences with encryption
- **Smart Logout**: Complete session cleanup with automatic navigation to welcome screen
- **Cross-Screen Consistency**: Unified user experience with personalized context throughout

### Authentication Flow

1. **Google Sign-In**: Users authenticate using Google OAuth
2. **Backend Verification**: ID tokens are verified with the backend API
3. **User Type Detection**: System determines user role (Senior Citizen/Family/Caregiver)
4. **Session Creation**: User data is securely stored locally
5. **Dashboard Navigation**: Automatic navigation to role-specific dashboard

### API Integration

- **Backend Connectivity**: Full integration with Second Innings backend API
- **User Registration**: Seamless registration flow with backend data sync
- **Session Verification**: Real-time session validation with backend
- **Error Handling**: Comprehensive error handling and user feedback

## Project Structure

The project follows a feature-based structure with enhanced service layer architecture:

```
second_innings/
├── lib/
│   ├── auth/             # Authentication flow (welcome, login, registration)
│   ├── config/           # API configuration and app settings
│   ├── dashboard/        # User role-specific dashboards
│   │   ├── senior_citizen/
│   │   ├── family/
│   │   └── caregiver/
│   ├── services/         # Core services (Session, User, API, Registration)
│   │   ├── session_manager.dart     # Session management & navigation
│   │   ├── user_service.dart        # User data operations
│   │   ├── api_service.dart         # HTTP API client
│   │   └── registration_service.dart # User registration
│   ├── widgets/          # Reusable UI components (UserAppBar, FeatureCard)
│   ├── util/             # Shared utility functions (validation)
│   └── main.dart         # Application entry point with session detection
├── assets/               # Static assets like images and logos
└── pubspec.yaml          # Dependencies and project configuration
```

## Getting Started: Running the App on the Web

The easiest way to run the app is by targeting the web platform.

### Prerequisites

1.  **Flutter SDK**: Make sure you have the Flutter SDK installed. You can find instructions on the [official Flutter website](https://flutter.dev/docs/get-started/install).
2.  **IDE**: [Visual Studio Code](https://code.visualstudio.com/) is recommended with the following extensions:
    -   [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
    -   [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
3.  **Google Chrome**: Required for debugging Flutter web apps.
4.  **Firebase Account**: Required for Google Authentication integration.

### Key Dependencies

The app utilizes several key packages for enhanced functionality:

- **`firebase_core`** & **`firebase_auth`**: Google authentication and Firebase integration
- **`shared_preferences`**: Secure local storage for user session data
- **`http`**: Backend API communication
- **`google_fonts`**: Typography and UI consistency
- **`dynamic_color`**: Material 3 theming support

### Installation & Setup

1.  Clone the repository:
    ```sh
    git clone https://github.com/madhavanrmiitm/soft-engg-project-may-2025-se-May-40
    ```
2.  Navigate to the `second_innings` directory:
    ```sh
    cd second_innings
    ```
3.  Install the required dependencies:
    ```sh
    flutter pub get
    ```

### Running the App

1.  Make sure a Chrome browser is available to run the app.
2.  Run the application:
    ```sh
    flutter run -d chrome
    ```
    This will launch the application in a new Chrome window.

## Recent Enhancements

### 🔐 Advanced Session Management
- **Auto-Login**: Users are automatically logged in if they have a valid session
- **Session Persistence**: User data is securely stored and persists across app restarts
- **Smart Navigation**: Automatic navigation to user-specific dashboards based on account type
- **Session Validation**: Real-time validation with automatic logout if session expires

### 🎨 Enhanced User Experience
- **Personalized Interface**: Dynamic user names displayed throughout the app
- **Consistent Design**: Unified `UserAppBar` component across all screens
- **Loading States**: Smooth loading indicators during authentication and data fetching
- **Error Handling**: Comprehensive error messages and graceful fallbacks

### 🔌 Backend Integration
- **API Connectivity**: Full integration with Second Innings backend services
- **Registration Flow**: Seamless user registration with backend synchronization
- **Token Management**: Secure ID token handling and verification
- **Data Synchronization**: Real-time sync between app and backend user data

### 🚀 Performance Improvements
- **Optimized Navigation**: Reduced app startup time with intelligent routing
- **Efficient Data Storage**: Optimized SharedPreferences usage for faster data access
- **Parallel Processing**: Concurrent API calls and data operations where possible

## Platform-Specific Web Setup Guides

For detailed instructions on setting up Flutter for web development on your specific operating system, please refer to the official documentation:

-   **macOS**: [docs.flutter.dev/get-started/install/macos/web](https://docs.flutter.dev/get-started/install/macos/web)
-   **Windows**: [docs.flutter.dev/get-started/install/windows/web](https://docs.flutter.dev/get-started/install/windows/web)
-   **Linux**: [docs.flutter.dev/get-started/install/linux/web](https://docs.flutter.dev/get-started/install/linux/web)
-   **ChromeOS**: [docs.flutter.dev/get-started/install/chromeos/web](https://docs.flutter.dev/get-started/install/chromeos/web)
