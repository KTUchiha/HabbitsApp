//
//  HabitMasterApp.swift
//  HabitMaster
//
//  Created by Kaavya on 10/17/21.

// Still figuring out bruh !!!
//

import SwiftUI

@available(iOS 15.0, *)
@main
struct HabitMasterApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}

