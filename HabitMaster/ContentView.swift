//
//  ContentView.swift
//  HabitMaster
//
//  Created by Kaavya on 10/17/21.
//

import SwiftUI



struct CheckboxStyle: ToggleStyle { // this struct defines how the toggle should look like
   // @State private var changeView = false
    func makeBody(configuration: Self.Configuration) -> some View { //making your own checkbox
        
            
        return HStack {
            configuration.label //
            //    Spacer()
            Image(systemName: configuration.$isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .green : .red)
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.$isOn.wrappedValue.toggle()
                    debugPrint("Tapped")
                    
                    
                   // self.changeView = true
            }
        }
        
    }
}

struct CheckView: View  {
    
    @State  var isChecked:Bool = false
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

@available(iOS 15.0, *)
struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var goals: FetchedResults<GoalModel>
    
   
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dt)]) var days: FetchedResults<DaysModel>
   
   
    // US English Locale (en_US)
   
    @State private var showingAddScreen = false
    
    @State private var refresh  = false
    

    
    struct Goal: Identifiable {
        let name: String
        let id = UUID()
        let why: String
        //  let howmanydays:Int
        
        // let streak: Array<Int>
    }
    /*
     private var goals = [
     Goal(name: "Excercise Daily", why:"Get fit"),
     Goal(name: "Drink Water 4 times",why:"Stop Headaches"),
     Goal(name: "Sleep by 9:30PM",why:"Prevent fatigue the next day"),
     Goal(name: "Wake up at 5:00AM",why:"concentrate"),
     Goal(name: "Practice Piano", why:"get better at piano")
     
     ] */
    
    func getDate()->String{
        let date = Date()
        //  You can print the current date using a DateFormatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return "Goals for " + dateFormatter.string(from:date)
    }
    
    func formatDate(dte:Date)->String{
      
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd EEEE"
        return dateFormatter.string(from:dte)
    }
    
    var body: some View {
        let calendar = Calendar.current
      //  let startdate = calendar.date(from: DateComponents(calendar: calendar,year: 2022, month: 1,day: 1))!
        
     //   let start_index = calendar.dateComponents([.day], from: startdate , to: Date()).day!
       
        VStack {
            
            HStack{
                Text("Goals for Today").font(.system(size: 30, weight: .heavy, design: .default))
                /*
                Button("Save"){
                    if moc.hasChanges {
                        do {
                          try moc.save()
                        } catch {
                            fatalError("Could not save context.")
                        }
                      }
                    
                } */
            }
            
            //.padding()
            Spacer()
            
            
            //List(goals) {
            List {
                
                
                ForEach(goals, id: \.self) { goal in
                    HStack(alignment:.firstTextBaseline){
                        Text(goal.name ??  "My Goal").font(.system(size: 20, weight: .heavy, design: .default))
                        Text(" " + goal.totalnow ).font(.system(size: 12, weight: .light, design: .default))
                        Button(action: {
                            moc.delete(goal)
                            try?moc.save()
                            dismiss()
                        }) {
                            Image(systemName: "trash")
                                //.font(.largeTitle)
                                .foregroundColor(.red)
                        }
                        
                   
                    }
                    VStack{
          
                       
                        ForEach(Array(goal.dayArray ), id: \.self) {
                            mday in
                            
                            // step is NSObject type, so you'll need it cast to your model
                            if (( calendar.dateComponents([.day], from: mday.dt! , to: Date()).day!  <  3) &&
                                (calendar.dateComponents([.day], from: mday.dt! , to: Date()).day! >= 0))
                            {
                            
                               // CheckView(isChecked: mday.status ,title: "" )
                                /*
                                Button(action: {
                                  mday.status.toggle()
                                    self.refresh=mday.status
                                    try?moc.save()
                                    
                                  }
                                ) {
                                  Image(systemName: mday.status ?  "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(mday.status ? .green : .red)
                                        .font(.system(size: 20, weight: .bold, design: .default))
                                }
                                .buttonStyle(PlainButtonStyle())
                               */
                               
                                if mday.dt! <= Date(){
                                    
                                    
                                Toggle(isOn: Binding<Bool>(
                                    get: { mday.status },
                                    set: {
                                            mday.status = $0
                                            try? moc.save()
                                            self.refresh = $0
                                            dismiss()
                                    }
                                )){
                                    Text(formatDate(dte:mday.dt ?? Date() ))
                                } } //.frame(width: 42, height: 18)
                                 //.foregroundColor(mday.status ? .green : .red)
                                // toggleStyle(.automatic)
                                //.toggleStyle(CheckboxStyle())
                                 
                           
                                   // {
                                   // Text("")
                                   // }
                            }
                            
                           
                            
                        }
                      //  Text("Today" + goal.totalnow )
                    }
                    
                    /*
                     if (goal.trackeddays?.count ?? 0 > 10)
                     {
                     
                     HStack{
                     //  CheckView(isChecked: true,title: "")
                     
                     CheckView(isChecked: true  ,title: "")
                     CheckView(isChecked: true,title: "")
                     CheckView(isChecked: true,title: "")
                     CheckView(isChecked: true,title: "")
                     CheckView(isChecked: true, title: "Today")
                     
                     
                     }
                     
                     
                     }  */
                    
                    //    }
                }
                
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
                
            }
        }
    }
}
