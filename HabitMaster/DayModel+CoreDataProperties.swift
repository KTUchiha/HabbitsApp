//
//  DayModel+CoreDataProperties.swift
//  HabitMaster
//
//  Created by Roohi Tatavarty on 4/10/22.
//



import Foundation
import CoreData


extension DaysModel {



    public var wrappedstatus: Bool {
        status ?? false
    }
    
    public var wrappeddt: Date {
        dt ?? Date()
    }
}
