//
//  ContentView.swift
//  HabitMaster
//
//  Created by Kaavya on 10/17/21.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle { // this struct defines how the toggle should look like
 
    func makeBody(configuration: Self.Configuration) -> some View { //making your own checkbox
 
        return HStack {
 
            configuration.label //
 
        //    Spacer()
 
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .green : .red)
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
 
    }
}

    
struct CheckView: View  {
    @State var isChecked:Bool = false
    var title:String
 //   @State var isGray:Bool = true
    
   // func toggle(){isChecked = !isChecked}
    var body: some View {
//        Button(action: toggle){
//            HStack{
//                Image(systemName: isChecked ? "checkmark.circle": "circle").saturation(isGray ? 0.0 : 1.0)
//                Text(title)
//            }
//
//        }
        
        Toggle(isOn: $isChecked, label: {
           // Image(systemName: "heart")
            Text(title)
        }).toggleStyle(CheckboxStyle())

     }

}

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
                //.padding()
            Spacer()
            List(goals) {
                
               // HStack{
                    Text($0.name)
                HStack{
                  //  CheckView(isChecked: true,title: "")
                    CheckView(isChecked: true,title: "")
                    CheckView(isChecked: true,title: "")
                    CheckView(isChecked: true,title: "")
                    CheckView(isChecked: true,title: "")
                    CheckView(isChecked: true,title: "")
                    CheckView(isChecked: true, title: "Today")

                }
                
                //    }
            }
            
            NavigationView{
                NavigationLink(destination:  GoalsView()
                ){
                    //Button(action:{
                    // }, label:{
                    HStack{
                        Image(systemName: "plus").frame(height: 32.0)
                        Text("Add Goals").frame( height: 32.0)
                            
                    }
                    //})
                    
                }.frame( height: 32.0)
                
                
            }.frame( height: 222)
            

        }
    }
    
    
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ContentView()
            //    ContentView()
            //    ContentView()
              //  ContentView()
            }
        }
    }
}
