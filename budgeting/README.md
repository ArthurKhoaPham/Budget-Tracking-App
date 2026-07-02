# Budgeting

Budgeting is a Flutter app for tracking spending, managing a monthly budget, and monitoring savings goals. It uses Supabase for authentication and backend data storage, with a dashboard that summarizes category spending and remaining balance.

## Features

- Email and password authentication with sign up and login screens
- Dashboard with category spending summary and pie chart visualization
- Add activity screen for recording expenses and recurring transactions
- Monthly budget allocation and persistence through Supabase
- Goals page for tracking savings targets and progress
- Navigation drawer for moving between the main app sections

## Tech Stack

- Flutter
- Supabase Flutter
- pie_chart package

## Getting Started

### Prerequisites

- Flutter SDK installed
- A Supabase project
- An `assets/logo.png` image file, which this app expects at runtime

### Setup

1. Install dependencies:

	```bash
	flutter pub get
	```

2. Update the Supabase configuration in [lib/main.dart](lib/main.dart) if you want to connect to your own project.

3. Make sure the database tables used by the app exist in Supabase. The code references:

	- `profiles`
	- `transactions`
	- `user_budget`
	- `budget_allocation`
	- `goals`

4. Run the app:

	```bash
	flutter run
	```

## Project Structure

- [lib/main.dart](lib/main.dart) - app entry point and Supabase initialization
- [lib/login_page.dart](lib/login_page.dart) - sign in screen
- [lib/register_page.dart](lib/register_page.dart) - account creation screen
- [lib/dashboard_page.dart](lib/dashboard_page.dart) - spending overview dashboard
- [lib/add_activity_screen.dart](lib/add_activity_screen.dart) - add new spending activity
- [lib/budget_allocation_page.dart](lib/budget_allocation_page.dart) - set monthly budget
- [lib/goals_page.dart](lib/goals_page.dart) - savings goals tracking
- [lib/app_drawer.dart](lib/app_drawer.dart) - shared navigation drawer

## Notes

- The app currently uses a Supabase-backed data model and will fall back to legacy budget storage where needed.
- If you change the asset layout, update `pubspec.yaml` accordingly.
