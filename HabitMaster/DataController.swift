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
    let container: NSPersistentContainer
    @Published var loadError: String?

    init() {
        container = NSPersistentContainer(name: "Goal")

        // Enable automatic migration
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                let errorMessage = "Failed to load data: \(error.localizedDescription)"
                print(errorMessage)
                self?.loadError = errorMessage

                // Attempt recovery: delete and recreate store
                if let storeURL = description.url {
                    try? FileManager.default.removeItem(at: storeURL)
                    // Try loading again
                    self?.container.loadPersistentStores { _, secondError in
                        if let secondError = secondError {
                            // Log error but don't crash - let user know gracefully
                            print("Unrecoverable Core Data error: \(secondError.localizedDescription)")
                            self?.loadError = "Unable to initialize data storage. Please reinstall the app or contact support."
                        }
                    }
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
