//
//  GoalsView.swift
//  HabitMaster
//
//  Created by Kaavya on 10/19/21.
//

import SwiftUI

@available(iOS 17.0, *)
struct GoalsView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var why: String = ""
    @State private var days: String = ""
    @State private var trigger: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    
    var body: some View {
        Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("What's your goal?", systemImage: "target")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("e.g., Exercise daily, Read more, Meditate", text: $title)
                            .textFieldStyle(.plain)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("How long?", systemImage: "calendar")
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack {
                            TextField("30", text: $days)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                            Text("days")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Why does this matter to you?", systemImage: "heart.fill")
                            .font(.headline)
                            .foregroundColor(.pink)
                        if #available(iOS 16.0, *) {
                            TextField("Your reason keeps you motivated...", text: $why, axis: .vertical)
                                .lineLimit(3...5)
                                .textFieldStyle(.plain)
                        } else {
                            TextField("Your reason keeps you motivated...", text: $why)
                                .textFieldStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Motivation")
                        .textCase(nil)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("When will you do it?", systemImage: "clock.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                        if #available(iOS 16.0, *) {
                            TextField("After breakfast, Before bed, 7am daily...", text: $trigger, axis: .vertical)
                                .lineLimit(2...3)
                                .textFieldStyle(.plain)
                        } else {
                            TextField("After breakfast, Before bed, 7am daily...", text: $trigger)
                                .textFieldStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Timing & Trigger")
                        .textCase(nil)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section {
                    Button(action: {
                // Validate input
                guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                    errorMessage = "Please enter a goal name"
                    showingError = true
                    return
                }

                guard let daysCount = Int(days), daysCount > 0, daysCount <= 365 else {
                    errorMessage = "Please enter a valid number of days (1-365)"
                    showingError = true
                    return
                }

                isSaving = true

                // Perform heavy Core Data operations on background thread
                Task {
                    let context = moc

                    await context.perform {
                        let goal = GoalModel(context: context)
                        goal.id = UUID()
                        goal.name = title
                        goal.trigger = trigger
                        goal.why = why

                        let cal = Calendar.current
                        // Start from 3 days ago (not 2022!)
                        guard let startdate = cal.date(byAdding: .day, value: -3, to: cal.startOfDay(for: Date())),
                              let stopDate = cal.date(byAdding: .day, value: daysCount + 2, to: startdate) else {
                            DispatchQueue.main.async {
                                errorMessage = "Error calculating dates"
                                showingError = true
                                isSaving = false
                            }
                            return
                        }

                        var currentDate = startdate
                        while currentDate <= stopDate {
                            let day = DaysModel(context: context)
                            day.goal = goal
                            day.dt = currentDate
                            day.status = false

                            guard let nextDate = cal.date(byAdding: .day, value: 1, to: currentDate) else {
                                break
                            }
                            currentDate = nextDate
                        }

                        do {
                            try context.save()
                            DispatchQueue.main.async {
                                isSaving = false
                                dismiss()
                            }
                        } catch {
                            DispatchQueue.main.async {
                                errorMessage = "Failed to save goal: \(error.localizedDescription)"
                                showingError = true
                                isSaving = false
                            }
                        }
                    }
                }
            }) {
                HStack {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                        Text("Creating your goal...")
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Start My Journey")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(isSaving)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("New Goal")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}
    
        
    


@available(iOS 17.0, *)
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
