//
//  GoalsView.swift
//  HabitMaster
//
//  Created by Kaavya on 10/19/21.
//

import SwiftUI

struct GoalsView: View {
    @State private var goal: String = ""
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
                            text: $goal
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
                       " How many days will you attempt this goal?",
                        text: $days
                   ){ isEditing3 in
                        
                   }.foregroundColor(isEditing3 ? .red : .blue)
                
                
                
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
                   
            Text("Add Goal").foregroundColor(.red)
            
        
        }
        
  
    }
        }
    
        
    


struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
