//
//  ContentView.swift
//  HabitMaster
//
//  Created by Kaavya on 10/17/21.
//

import SwiftUI
struct ContentView: View {
    struct Goal: Identifiable {
        let name: String
        let id = UUID()
        let why: String
        //  let howmanydays:Int
        
        // let streak: Array<Int>
    }
    private var goals = [
        Goal(name: "Excercise Daily", why:"Get fit"),
        Goal(name: "Drink Water 4 times",why:"Stop Headaches"),
        Goal(name: "Sleep by 9:30PM",why:"Prevent fatigue the next day"),
        Goal(name: "Wake up at 5:00AM",why:"concentrate"),
        Goal(name: "Practice Piano", why:"get better at piano")
       
    ]
    
    func getDate()->String{
        let date = Date()
        //  You can print the current date using a DateFormatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return "Goals for " + dateFormatter.string(from:date)
    }
    
    var body: some View {
        
        VStack {
            Text(getDate())
                .padding()
            Spacer()
            List(goals) {
                Text($0.name)
            }
            
            NavigationView{
                
                NavigationLink(destination:  GoalsView()
                ){
                    //Button(action:{
                    // }, label:{
                    HStack{
                        Image(systemName: "plus")
                        Text("Add Goals")
                            
                    }
                    
                    
                    //})
                    
                }
                
                
            }
        }
    }
    
    
    
    
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
