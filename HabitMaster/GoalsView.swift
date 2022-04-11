//
//  GoalsView.swift
//  HabitMaster
//
//  Created by Kaavya on 10/19/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct GoalsView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var why: String = ""
    @State private var days: String = ""
    @State private var trigger: String = ""
    @State private var isEditing1 = false
    @State private var isEditing2 = false
    @State private var isEditing3 = false
    @State private var isEditing4 = false
    
    
    var body: some View {
        
        VStack {
            
            Group{
   //             HStack {
  //                  Spacer()
   //                 Text("Add New Goal").foregroundColor(Color.black)
   //                 Spacer()
   //             }
   //         Spacer()
            
            
                HStack {
                    Spacer()
                    Text("My goal ")
                    TextField(
                           " Tell us what you want to achieve",
                            text: $title
                       ){ isEditing in
                           self.isEditing1 = isEditing
                   }.foregroundColor(isEditing1 ? .red : .blue)
                }

                Spacer()
            }
            
            HStack{
                Spacer()
                Text("My motivation")
                TextField(
                       " Why do you want to achive this goal?",
                        text: $why
                   ){ isEditing in
                       self.isEditing2 = isEditing
                   }.foregroundColor(isEditing2 ? .red : .blue)
        
            }
            Spacer()
            
            HStack{
                Spacer()
                Text("I commit for")
                
                TextField(
                       "Type a Number",
                        text: $days
                   ){ isEditing3 in
                   }.foregroundColor(isEditing3 ? .red : .blue).keyboardType(.decimalPad)
                Text(" days for this goal")

            }
            Spacer()
            
            HStack{
                Text(" My Trigger is...")
                Spacer()
                TextField(
                    "What already existing habit will you link this to?",
                    text: $trigger
                )
                
                Spacer()
                
                
         
            }
                   
            Button("Add Goal"){
                let goal = GoalModel(context: moc)
                goal.id = UUID()
                goal.name = title
                //goal.status =
                goal.trigger = trigger
                goal.why = why

                let cal = Calendar.current
                // DateComponents as a date specifier
                var startdate = cal.date(from: DateComponents(calendar: cal,
                                                              year: 2022,
                                                              month: 1,
                                                              day: 1))!

               
                startdate = cal.date(byAdding: .day, value: -3, to: Calendar.current.startOfDay(for: Date()))!
                
                let stopDate = cal.date(byAdding: .day, value: Int(days)! + 2 ?? 30, to: startdate)!

                while startdate <= stopDate {
                    //mydates.append(from: startdate)
                    let day=DaysModel(context: moc)
                    day.goal = goal
                    day.dt = startdate
                    day.status = false// Bool.random() //false
                    startdate = Calendar.current.date(byAdding: .day, value: 1, to: startdate)!
                }

                
                try? moc.save()
                dismiss()
                
                
            }
            
        
        }
        
  
    }
        }
    
        
    


@available(iOS 15.0, *)
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
