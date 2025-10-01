//
//  HabitMasterApp.swift
//  HabitMaster
//
//  Created by Kaavya on 10/17/21.
//

import SwiftUI

@available(iOS 17.0, *)
@main
struct HabitMasterApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}

