# spendsnap

B. Tech 6th Sem Final Submission

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Problem Understanding

SpendSnap is a personal finance management application designed to help users track their expenses, set budgets, and gain insights into their spending habits. The core problem it addresses is the difficulty individuals face in managing personal finances effectively, especially with irregular income and expenses. Users often struggle with:

- Tracking daily expenses and income in real-time
- Setting and monitoring financial goals (budgets)
- Forecasting how long their current balance will last based on spending patterns
- Visualizing spending trends through charts and analytics

The app aims to provide a simple, intuitive interface for logging transactions, setting snap goals (budgets), and viewing a dashboard with key financial metrics like total balance and runway forecast.

## Feature Justification

The features were added to solve specific user needs and enhance the overall utility of the app:

- **Authentication**: Added to ensure user data privacy and personalization. Firebase Auth allows secure login/logout, enabling users to access their personal financial data across devices.
- **Transactions Management**: Core feature for logging income and expenses. Supports categorization and real-time updates to provide accurate balance calculations.
- **Budget/Goals (SnapGoals)**: Allows users to set financial targets. Justification: Helps users stay disciplined with spending by visualizing progress towards goals.
- **Dashboard**: Central hub displaying total balance, runway forecast (days until funds run out), and recent transactions. Added for quick insights without navigating through multiple screens.
- **Charts and Analytics**: Using fl_chart library for visualizing spending trends. Justification: Visual data is easier to understand and motivates better financial decisions.
- **Firebase Integration**: Real-time database for data persistence and synchronization. Justification: Ensures data is available offline and synced across devices.

## Architecture Diagram

<img src="./architecture-diagram.svg" alt="SpendSnap Architecture" width="840" />

The architecture follows a clean layered approach with clear separation of concerns:
- **Presentation Layer**: Handles user interface components built with Flutter.
- **State Management Layer**: Manages application state using the Provider pattern.
- **Business Logic Layer**: Contains services for interacting with external APIs (Firebase).
- **Data Layer**: Manages data models and persistent storage.

## State Management Explanation

SpendSnap uses the Provider package for state management, which is a simple and effective solution for Flutter apps. Key aspects:

- **ChangeNotifier Providers**: AuthProvider, TransactionProvider, and GoalProvider extend ChangeNotifier to notify listeners of state changes.
- **MultiProvider Setup**: In main.dart, providers are set up with dependencies (e.g., TransactionProvider depends on AuthProvider for user ID).
- **Reactive UI**: Widgets consume providers using Consumer or context.watch to rebuild when data changes.
- **Proxy Providers**: Used for providers that need initialization with user data, ensuring proper lifecycle management.

This approach ensures efficient updates and separation of concerns, making the app responsive to real-time data changes from Firebase.

## Challenges Faced

During development, several challenges were encountered:

- **State Management Complexity**: Coordinating between multiple providers (Auth, Transactions, Goals) required careful dependency management to avoid rebuild loops and ensure data consistency.
- **Firebase Real-time Sync**: Handling real-time updates from Firebase Database while maintaining UI performance, especially with charts that need frequent recalculations.
- **UI Responsiveness**: Optimizing the dashboard with charts and lists to handle large datasets without lag, using techniques like Sliver widgets and efficient list building.
- **Cross-platform Compatibility**: Ensuring the app works seamlessly across Android, iOS, Web, and Desktop platforms, dealing with platform-specific Firebase configurations.
- **Data Persistence**: Implementing offline support with Firebase's persistence enabled, but managing conflicts when coming back online.
- **Chart Integration**: Customizing fl_chart for runway forecast visualization, requiring data processing to calculate spending trends and projections.
