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
    @EnvironmentObject var dataController: DataController
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var goals: FetchedResults<GoalModel>

    @State private var showingDeleteAlert = false
    @State private var goalToDelete: GoalModel?
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""
    
    func formatDate(dte: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
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
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(goal.name ?? "My Goal")
                                            .font(.system(size: 20, weight: .heavy, design: .default))

                                        // Streak info
                                        HStack(spacing: 12) {
                                            if goal.currentStreak > 0 {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "flame.fill")
                                                        .foregroundColor(.orange)
                                                    Text("\(goal.currentStreak) day streak")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.orange)
                                                }
                                            }

                                            if goal.longestStreak > 0 {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "trophy.fill")
                                                        .foregroundColor(.yellow)
                                                    Text("Best: \(goal.longestStreak)")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }

                                        Text(goal.totalnow)
                                            .font(.system(size: 12, weight: .light, design: .default))
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Button(action: {
                                        goalToDelete = goal
                                        showingDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }

                                // Days toggles
                                ForEach(Array(goal.dayArray ), id: \.self) { mday in
                                    if let dayDate = mday.dt,
                                       let daysFromNow = calendar.dateComponents([.day], from: dayDate, to: Date()).day,
                                       daysFromNow < 3,
                                       daysFromNow >= 0,
                                       dayDate <= Date() {

                                        let isToday = calendar.isDateInToday(dayDate)

                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(formatDate(dte: dayDate))
                                                    .font(isToday ? .headline : .body)
                                                    .fontWeight(isToday ? .bold : .regular)
                                                    .foregroundColor(isToday ? .blue : .primary)

                                                if isToday {
                                                    Text("Make it count!")
                                                        .font(.caption)
                                                        .foregroundColor(.blue.opacity(0.7))
                                                }
                                            }

                                            Spacer()

                                            Toggle("", isOn: Binding<Bool>(
                                                get: {
                                                    mday.status ?? false
                                                },
                                                set: { newValue in
                                                    // Update value immediately for UI responsiveness
                                                    mday.status = newValue

                                                    // Capture context reference before async
                                                    let context = moc

                                                    // Save on background with debounce
                                                    Task {
                                                        // Small delay to batch rapid toggles
                                                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

                                                        await context.perform {
                                                            do {
                                                                if context.hasChanges {
                                                                    try context.save()
                                                                }
                                                            } catch {
                                                                Task { @MainActor in
                                                                    saveErrorMessage = "Failed to save: \(error.localizedDescription)"
                                                                    showingSaveError = true
                                                                    // Revert on failure
                                                                    mday.status = !newValue
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            ))
                                            .toggleStyle(SwitchToggleStyle(tint: .green))
                                        }
                                        .padding(.vertical, isToday ? 8 : 4)
                                        .padding(.horizontal, 8)
                                        .background(
                                            isToday ? Color.blue.opacity(0.1) : Color.clear
                                        )
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
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
    }
    
    
    
    
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ContentView()
                
            }
        }
    }
}
