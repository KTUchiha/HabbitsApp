//
//  dataextensions.swift
//  HabitMaster
//
//  Created by Roohi Tatavarty on 4/10/22.
//

import Foundation

extension GoalModel {



    public var dayArray: [DaysModel] {
        let set = trackeddays as? Set<DaysModel> ?? []
        return set.sorted {
            $0.dt ?? Date() < $1.dt ?? Date()
        }
    }
}
