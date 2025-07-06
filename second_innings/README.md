# Second Innings User App

This is the user-facing application for the Second Innings project, built with Flutter and Dart. For the old, by the young.

**Live Demo:** **[https://second-innings-iitm.web.app](https://second-innings-iitm.web.app)**

> **Note:** The application is designed and optimized for a mobile-only viewing experience, as it is primarily intended for senior citizens.

## Features

The application provides a comprehensive set of features tailored to three main user roles: Senior Citizens, Family Members, and Caregivers.

### General

-   **Authentication**: Welcome, Registration, and Login screens with Google Sign-In.
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

## Getting Started: Running the App on the Web

The easiest way to run the app is by targeting the web platform.

### Prerequisites

1.  **Flutter SDK**: Make sure you have the Flutter SDK installed. You can find instructions on the [official Flutter website](https://flutter.dev/docs/get-started/install).
2.  **IDE**: [Visual Studio Code](https://code.visualstudio.com/) is recommended with the following extensions:
    -   [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
    -   [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
3.  **Google Chrome**: Required for debugging Flutter web apps.

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

## Platform-Specific Web Setup Guides

For detailed instructions on setting up Flutter for web development on your specific operating system, please refer to the official documentation:

-   **macOS**: [docs.flutter.dev/get-started/install/macos/web](https://docs.flutter.dev/get-started/install/macos/web)
-   **Windows**: [docs.flutter.dev/get-started/install/windows/web](https://docs.flutter.dev/get-started/install/windows/web)
-   **Linux**: [docs.flutter.dev/get-started/install/linux/web](https://docs.flutter.dev/get-started/install/linux/web)
-   **ChromeOS**: [docs.flutter.dev/get-started/install/chromeos/web](https://docs.flutter.dev/get-started/install/chromeos/web)
