//
//  goalextensions.swift
//  HabitMaster
//
//  Created by Roohi Tatavarty on 4/11/22.
//

import Foundation
import CoreData

extension GoalModel {


    

    public var dayArray: [DaysModel] {
        let set = trackeddays as? Set<DaysModel> ?? []
        return set.sorted {
            $0.dt ?? Date()  < $1.dt ?? Date()
        }
    }
    
    public var totalnow: String {
        let set = trackeddays as? Set<DaysModel> ?? []
        return  "(" + String( set.filter{ $0.status && $0.dt! < Date() }.count  ) + " days Committed )"
    }
}
