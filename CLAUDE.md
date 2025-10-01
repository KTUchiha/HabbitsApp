# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
HabitMaster is an iOS habit tracking app built with SwiftUI and Core Data. Users can create goals, track daily progress with toggles, and view commitment streaks.

## Build & Run Commands
- Open the project: `open HabitMaster.xcodeproj`
- Build: `xcodebuild -project HabitMaster.xcodeproj -scheme HabitMaster -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run tests: `xcodebuild test -project HabitMaster.xcodeproj -scheme HabitMaster -destination 'platform=iOS Simulator,name=iPhone 15'`
- Test targets: `HabitMasterTests`, `HabitMasterUITests`

## Core Architecture

### Data Layer (Core Data)
- **DataController**: Manages NSPersistentContainer for the "Goal" data model (DataController.swift:20)
- **Core Data Models**: Three separate .xcdatamodeld files exist (Goal, Days, Habit) but only Goal.xcdatamodeld is actively used
- **Active Entities**:
  - `GoalModel`: Stores habit goals with name, why, trigger, status, and relationship to DaysModel
  - `DaysModel`: Tracks individual days with date (dt), status (boolean), and relationship back to GoalModel
- Container injected via environment into ContentView (HabitMasterApp.swift:18)

### View Layer
- **ContentView**: Main screen displaying today's goals with toggles for last 3 days of progress
  - Fetches goals sorted by name and days sorted by date
  - Shows toggles only for days within 3-day window (past to today)
  - Displays progress string via `totalnow` computed property (e.g., "5 days Committed, 25 to go.")

- **GoalsView**: Form for creating new goals
  - Collects: goal name, motivation (why), commitment duration (days), and trigger
  - Generates DaysModel entries from 3 days before today through duration + 2 days
  - All days initialized with status=false

### Data Extensions
- **goalextensions.swift**: Provides `dayArray` (sorted days) and `totalnow` (progress string) on GoalModel
- **dataextensions.swift**: Duplicate `dayArray` implementation (consider removing)
- **GoalModel+CoreDataProperties.swift**: Wrapped properties for safe unwrapping (wrappedwhy, wrappedstatus, etc.)
- **DayModel+CoreDataProperties.swift**: Wrapped properties for DaysModel (wrappedstatus, wrappeddt)

## Key Implementation Details
- iOS 15.0+ required (@available annotations throughout)
- Date formatting: "MM/dd/yyyy" for headers, "MM/dd EEEE" for day toggles
- 3-day rolling window: Shows today and previous 2 days' progress (ContentView.swift:101-103)
- Deletion: Goals can be deleted via trash icon, cascades to related days
- All Core Data saves use `try? moc.save()` pattern

## Known Issues
- Duplicate extensions: Both dataextensions.swift and goalextensions.swift define `dayArray`
- Unused data models: Days.xcdatamodeld and Habit.xcdatamodeld are not integrated
- Hardcoded start date logic in GoalsView generates days from 3 days before today