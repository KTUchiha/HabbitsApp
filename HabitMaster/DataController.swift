//
//  DataController.swift
//  HabitMaster
//
//  Created by Roohi Tatavarty on 4/10/22.
//


//
//  DataController.swift
//  Bookworm
//
//  Created by Paul Hudson on 23/11/2021.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Goal")

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
