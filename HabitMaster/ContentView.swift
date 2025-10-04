//
//  ContentView.swift
//  HabitMaster
//
//  Created by Kaavya on 10/17/21.
//

import SwiftUI


@available(iOS 17.0, *)
struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var dataController: DataController
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var goals: FetchedResults<GoalModel>

    @State private var showingDeleteAlert = false
    @State private var goalToDelete: GoalModel?
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""
    @State private var currentDate = Date()
    @State private var midnightTimer: Timer?
    @State private var showingInfoPopup = false
    @State private var selectedGoal: GoalModel?
    @State private var showConfetti = false
    @State private var isRefreshing = false

    func refreshData() {
        isRefreshing = true

        // Force Core Data to refresh all objects from persistent store
        moc.reset()
        moc.refreshAllObjects()

        // Update current date in case day boundary was crossed
        currentDate = Date()

        // Small delay to show refresh indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isRefreshing = false
        }
    }

    func formatDate(dte: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        let dateToCheck = calendar.startOfDay(for: dte)

        if dateToCheck == today {
            return "Today"
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  dateToCheck == yesterday {
            return "Yesterday"
        } else if let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today),
                  dateToCheck == dayBeforeYesterday {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: dte)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd EEEE"
            return dateFormatter.string(from: dte)
        }
    }

    func startMidnightTimer() {
        // Cancel existing timer
        midnightTimer?.invalidate()

        let calendar = Calendar.current
        let now = Date()

        // Calculate next midnight
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else {
            return
        }

        let timeUntilMidnight = tomorrow.timeIntervalSince(now)

        // Set timer to fire at midnight
        midnightTimer = Timer.scheduledTimer(withTimeInterval: timeUntilMidnight, repeats: false) { _ in
            // Update current date
            currentDate = Date()
            // Restart timer for next midnight
            startMidnightTimer()
        }
    }


    @ViewBuilder
    func streakCalendarView(for goal: GoalModel) -> some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)

        // Get last 30 days worth of data
        let calendarDays: [(date: Date, dayModel: DaysModel?)] = {
            var days: [(date: Date, dayModel: DaysModel?)] = []
            for i in (0..<30).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    let dayModel = goal.dayArray.first { day in
                        guard let dayDate = day.dt else { return false }
                        return calendar.isDate(dayDate, inSameDayAs: date)
                    }
                    // Only include if day exists in goal data
                    if dayModel != nil {
                        days.append((date: date, dayModel: dayModel))
                    }
                }
            }
            return days
        }()

        // Don't show calendar if less than 3 days of data
        if calendarDays.count >= 3 {
            HStack(spacing: 4) {
                ForEach(calendarDays, id: \.date) { item in
                    Circle()
                        .fill((item.dayModel?.status ?? false) ? Color.green : Color.gray.opacity(0.25))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
        }
    }
    
    var body: some View {
        let calendar = Calendar.current

        NavigationView {
            VStack(spacing: 0) {
                if let error = dataController.loadError {
                    // Show data loading error
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)

                        Text("Data Error")
                            .font(.system(size: 24, weight: .bold))

                        Text(error)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if goals.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "target")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("No Goals Yet")
                            .font(.system(size: 24, weight: .bold))

                        Text("Start building better habits by adding your first goal")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        NavigationLink(destination: GoalsView()) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Your First Goal")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(goals, id: \.self) { goal in
                            VStack(alignment: .leading, spacing: 8) {
                                // Header with goal name and delete button
                                let endDate = goal.dayArray.last?.dt ?? Date()
                                let formatter = DateFormatter()
                                let _ = { formatter.dateFormat = "MMM d, yyyy" }()
                                let totalDays = goal.dayArray.count
                                // Count days elapsed (days that have passed, including today)
                                let elapsedDays = goal.dayArray.filter { ($0.dt ?? Date()) <= calendar.startOfDay(for: currentDate) }.count
                                let progress = totalDays > 0 ? Double(elapsedDays) / Double(totalDays) : 0

                                HStack(alignment: .top) {
                                    Button(action: {
                                        selectedGoal = goal
                                        showingInfoPopup = true
                                    }) {
                                        Image(systemName: "info.circle")
                                            .font(.system(size: 16))
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 2)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(goal.name ?? "My Goal")
                                            .font(.system(size: 20, weight: .heavy, design: .default))

                                        // End date and longest streak
                                        HStack(spacing: 8) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "flame.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.orange)
                                                Text("Longest: \(goal.longestStreak)")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }

                                            Text("•")
                                                .foregroundColor(.secondary)

                                            Text("Ends \(formatter.string(from: endDate))")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }

                                        // Progress bar with style
                                        HStack(spacing: 8) {
                                            GeometryReader { geometry in
                                                ZStack(alignment: .leading) {
                                                    // Background with subtle inner shadow effect
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.gray.opacity(0.12))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                                        )
                                                        .frame(height: 12)

                                                    // Animated gradient progress
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [
                                                                    Color(red: 0.0, green: 0.75, blue: 1.0),
                                                                    Color(red: 0.5, green: 0.3, blue: 1.0),
                                                                    Color(red: 0.8, green: 0.2, blue: 0.9)
                                                                ]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                                                        .frame(width: max(12, geometry.size.width * progress), height: 12)
                                                }
                                            }
                                            .frame(height: 12)

                                            Text("\(elapsedDays)/\(totalDays)")
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                                .fixedSize()
                                        }

                                        // Visual streak calendar (right-aligned with progress bar)
                                        streakCalendarView(for: goal)
                                    }

                                    Spacer()

                                    Button(action: {
                                        goalToDelete = goal
                                        showingDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }

                                // Toggles with minimal labels
                                HStack(spacing: 24) {
                                    ForEach(Array(goal.dayArray), id: \.self) { mday in
                                        if let dayDate = mday.dt,
                                           let daysFromNow = calendar.dateComponents([.day], from: dayDate, to: currentDate).day,
                                           daysFromNow < 2,
                                           daysFromNow >= 0,
                                           dayDate <= currentDate {

                                            let isToday = calendar.isDate(dayDate, inSameDayAs: currentDate)

                                            HStack(spacing: 6) {
                                                Toggle("", isOn: Binding<Bool>(
                                                    get: {
                                                        mday.status ?? false
                                                    },
                                                    set: { newValue in
                                                        // Update in-memory value immediately (no redraw)
                                                        mday.status = newValue

                                                        // Show confetti first (before save)
                                                        if newValue && isToday {
                                                            showConfetti = true
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                                showConfetti = false
                                                            }
                                                        }

                                                        // Save asynchronously to avoid blocking UI
                                                        DispatchQueue.main.async {
                                                            do {
                                                                try moc.save()
                                                                print("✅ Saved toggle: \(newValue)")
                                                            } catch {
                                                                print("❌ Save failed: \(error)")
                                                                // Revert on error
                                                                mday.status = !newValue
                                                                saveErrorMessage = "Failed to save: \(error.localizedDescription)"
                                                                showingSaveError = true
                                                            }
                                                        }
                                                    }
                                                ))
                                                .toggleStyle(SwitchToggleStyle(tint: .green))

                                                Text(isToday ? "Today" : "Yest")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .refreshable {
                        refreshData()
                    }

                    if !goals.isEmpty {
                        NavigationLink(destination: GoalsView()) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Goal")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Goals for Today")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Delete Goal", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let goal = goalToDelete {
                    moc.delete(goal)
                    do {
                        try moc.save()
                    } catch {
                        saveErrorMessage = "Failed to delete goal: \(error.localizedDescription)"
                        showingSaveError = true
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
        }
        .alert(selectedGoal?.name ?? "Goal Info", isPresented: $showingInfoPopup) {
            Button("OK", role: .cancel) { }
        } message: {
            if let goal = selectedGoal {
                VStack(alignment: .leading, spacing: 8) {
                    if let why = goal.why, !why.isEmpty {
                        Text("Why: \(why)")
                    }
                    if let trigger = goal.trigger, !trigger.isEmpty {
                        Text("\nWhen: \(trigger)")
                    }
                }
            }
        }
        .onAppear {
            // Start midnight timer when view appears
            startMidnightTimer()
            // Refresh context from store to get latest data
            moc.refreshAllObjects()
        }
        .onDisappear {
            // Clean up timer when view disappears
            midnightTimer?.invalidate()
            // Force save any pending changes
            if moc.hasChanges {
                try? moc.save()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // Update date when app becomes active (from background)
                currentDate = Date()
                // Restart timer
                startMidnightTimer()
            } else if newPhase == .background {
                // Invalidate timer when going to background
                midnightTimer?.invalidate()
            }
        }
        .overlay(
            ConfettiView(isActive: $showConfetti)
                .allowsHitTesting(false)
        )
    }
}

struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onChange(of: isActive) { active in
            if active {
                particles = (0..<50).map { _ in ConfettiParticle() }
                withAnimation(.linear(duration: 2.0)) {
                    particles = particles.map { particle in
                        var p = particle
                        p.position.y += 800
                        p.opacity = 0
                        return p
                    }
                }
            } else {
                particles = []
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint = CGPoint(
        x: CGFloat.random(in: 0...400),
        y: CGFloat.random(in: -100...100)
    )
    let color: Color = [.red, .blue, .green, .yellow, .orange, .pink, .purple].randomElement()!
    let size: CGFloat = CGFloat.random(in: 8...16)
    var opacity: Double = 1.0
}

@available(iOS 17.0, *)
extension ContentView {
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ContentView()
                
            }
        }
    }
}
