//
//  GoalModel+CoreDataProperties.swift
//  HabitMaster
//
//  Created by Roohi Tatavarty on 4/10/22.
//

import Foundation
extension GoalModel {

    public var wrappedwhy: String {
        why ?? ""
    }

    public var wrappedstatus: Bool {
        status ?? true
    }

    public var wrappedtitle: String {
        name ?? ""
    }
    
    public var wrappedtrigger: String {
        trigger ?? ""
    }
    
    public var daysArray: [DaysModel] {
        let set = trackeddays as? Set<DaysModel> ?? []
        return set.sorted {
            $0.wrappeddt < $1.wrappeddt
        }
    }
}


