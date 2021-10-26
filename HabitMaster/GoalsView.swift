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
    @State private var isEditing1 = false
    @State private var isEditing2 = false
    @State private var isEditing3 = false
    
    
    var body: some View {
        
        VStack {
            
            Group{
                HStack {
                    Spacer()
                    Text("Add New Goal").foregroundColor(Color.black)
                    Spacer()
                }
            Spacer()
            Text("My goal is...")
            
                HStack {
                    Spacer()
                    TextField(
                           " Tell us what you want to achieve",
                            text: $goal
                       ){ isEditing in
                           self.isEditing1 = isEditing
                   }.foregroundColor(isEditing1 ? .red : .blue)
                }

                Spacer()
            }
            Text("My motivation is...")
            HStack{
                Spacer()
                TextField(
                       " Why do you want to achive this goal?",
                        text: $why
                   ){ isEditing in
                       self.isEditing2 = isEditing
                   }.foregroundColor(isEditing2 ? .red : .blue)
        
            }
            Spacer()
            Text("I will do this for...")
            HStack{
                Spacer()
                TextField(
                       " How many days will you attempt this goal?",
                        text: $days
                   ){ isEditing3 in
                        
                   }.foregroundColor(isEditing3 ? .red : .blue)
                
                
                
            }
            Spacer()
            Spacer()
            Spacer()
            
            
        
        }
        
  
    }
        }
    
        
    


struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
