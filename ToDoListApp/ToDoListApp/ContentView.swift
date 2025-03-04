///
////  ContentView.swift
////  ToDoListApp
////
////  Created by Lauren Mikula on 3/1/25.
////
//
import SwiftUI


struct ContentView: View {
    
    @StateObject private var viewModel = ToDoListViewModel()
    
    @State private var searchQuery = ""
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Picker("Priority", selection: $viewModel.priority) {
                        ForEach(Priority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Menu("Tag") {
                        Picker("Tag", selection: $viewModel.tag) {
                            ForEach(availableTags, id: \.self) { tag in
                                Text(tag).tag(tag)
                            }
                        }
                    }
                    
                    Button("Set Notification Time") {
                        viewModel.showDatePickerToAdd = true
                    }
                    
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 30))
                        .imageScale(.small)
                    .padding(8)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $viewModel.showDatePickerToAdd) {
                    VStack {
                        DatePicker("Set Notification", selection: Binding(
                            get: { viewModel.notificationTime ?? Date() },
                            set: { newDate in viewModel.notificationTime = newDate }
                        ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        
                        Button("Done") {
                            viewModel.showDatePickerToAdd = false
                        }
                        .padding()
                    }
                }

                TextField("Input task", text: $viewModel.inputTask)

                Button {
                    viewModel.addItem()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .imageScale(.medium)
                }
                
            }
            .padding([.leading, .trailing, .bottom], 15)
            .background(Color.blue.opacity(0.2))

            
            TextField("Search tasks...", text: $viewModel.searchQuery)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            List {
                ForEach(viewModel.filteredItems.filter {
                    searchQuery.isEmpty || $0.title.localizedCaseInsensitiveContains(searchQuery)
                })
                { item in
                    VStack {
                        HStack {
                            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    viewModel.toggleItem(item)
                                }
                            if viewModel.editingItemId == item.id {
                                HStack{
                                    TextField("", text: Binding(
                                        get: { item.title },
                                        set: { newValue in
                                            viewModel.updateItemText(item, newValue)
                                        }
                                    ))
                                    .onSubmit {
                                        viewModel.onSubmit()
                                    }
                                }
                                
                            } else {
                                Text(item.title)
                                    .strikethrough(item.isComplete)
                                    .onTapGesture {
                                        viewModel.onTapItem(item)
                                    }
                            }
                            
                            Spacer()
                            
                            if item.priority == "Medium" {
                                Image(systemName: "exclamationmark.2")
                                    .foregroundColor(.orange)
                            }
                            else if item.priority == "High" {
                                Image(systemName: "exclamationmark.3")
                                    .foregroundColor(.red)
                            }
                            
                            if viewModel.editingItemId == item.id {
                                Menu {
                                    Picker("Priority", selection: Binding(
                                        get: { item.priority },
                                        set: { newPriority in viewModel.updatePriority(item, newPriority) }
                                    )) {
                                        Text("Low").tag("Low")
                                        Text("Medium").tag("Medium")
                                        Text("High").tag("High")
                                    }

                                    Picker("Tag", selection: Binding(
                                        get: { item.tag },
                                        set: { newTag in viewModel.updateTag(item, newTag) }
                                    )) {
                                        ForEach(availableTags, id: \.self) { tag in
                                            Text(tag).tag(tag)
                                        }
                                    }
                                    
                                    Button("Set Notification") {
                                        viewModel.showDatePickerToUpdate = true 
                                    }
                                    
                                    if item.notificationTime != nil {
                                        Button("Remove Notification") {
                                            viewModel.updateNotificationTime(item, nil)
                                            viewModel.showDatePickerToUpdate = false
                                        }
                                    }
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .sheet(isPresented: $viewModel.showDatePickerToUpdate) {
                                    VStack {
                                        DatePicker("Set Notification", selection: Binding(
                                            get: { item.notificationTime ?? Date() },
                                            set: { newDate in viewModel.updateNotificationTime(item, newDate) }
                                        ), displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.graphical)
                                        .labelsHidden()
                                        .padding()
                                        
                                        Button("Done") {
                                            viewModel.showDatePickerToUpdate = false
                                        }
                                        .padding()
                                    }
                                }
                            }
                               
                            Button {
                                viewModel.removeItem(item)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding([.vertical], 10)
                        
                        HStack {
                            if let notificationTime = item.notificationTime {
                                Text("⏰ \(formattedDate(notificationTime))")
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if item.tag != "None" {
                                Text("#\(item.tag)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            
            
            HStack {
                Spacer()
                Button {
                    viewModel.showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 28))
                        .padding()
                        .foregroundColor(.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .popover(isPresented: $viewModel.showSettings, arrowEdge: .bottom) {
                    VStack {
                        Toggle("Hide Completed Tasks", isOn: $viewModel.hideCompleted)
                            .padding()
                            .presentationCompactAdaptation((.popover))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
                .padding(8) 
            }
        }
        .onAppear() {
            viewModel.requestNotificationPermissions()
            viewModel.loadData()
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            formatter.dateStyle = .none
        }
        else {
            formatter.dateStyle = .short
        }
        
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
