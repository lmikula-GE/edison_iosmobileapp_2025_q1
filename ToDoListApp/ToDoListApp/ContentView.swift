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
    
    @State private var showSettings = false
    @State private var isDatePickerPresented = false
    @State private var isDatePickerPresented2 = false
    @State private var searchQuery = ""
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Picker("Priority", selection: $viewModel.selectedPriority) {
                        ForEach(Priority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Menu("Tag") {
                        Picker("Tag", selection: $viewModel.selectedTag) {
                            ForEach(availableTags, id: \.self) { tag in
                                Text(tag).tag(tag)
                            }
                        }
                    }
                    
                    Button("Set Notification Time") {
                        isDatePickerPresented = true  // Open the sheet
                    }
                    
                } label: {
                    Image(systemName: "info.circle.fill")
                    .padding(8)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $isDatePickerPresented) {
                    VStack {
                        DatePicker("Set Notification", selection: Binding(
                            get: { viewModel.notificationTime ?? Date() },
                            set: { newDate in viewModel.notificationTime = newDate }
                        ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        
                        Button("Done") {
                            isDatePickerPresented = false
                        }
                        .padding()
                    }
                }

                TextField("Input task", text: $viewModel.inputTask)

                Button("Add") {
                    viewModel.addItem()
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
                                    .pickerStyle(MenuPickerStyle())

                                    Picker("Tag", selection: Binding(
                                        get: { item.tag },
                                        set: { newTag in viewModel.updateTag(item, newTag) }
                                    )) {
                                        ForEach(availableTags, id: \.self) { tag in
                                            Text(tag).tag(tag)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    
                                    Button("Set Notification Time") {
                                        isDatePickerPresented2 = true 
                                    }

                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .sheet(isPresented: $isDatePickerPresented2) {
                                    VStack {
                                        DatePicker("Set Notification", selection: Binding(
                                            get: { item.notificationTime ?? Date() },
                                            set: { newDate in viewModel.updateNotificationTime(item, newDate) }
                                        ), displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.graphical)
                                        .labelsHidden()
                                        .padding()
                                        
                                        Button("Done") {
                                            isDatePickerPresented2 = false
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
                                    .foregroundColor(.orange)
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
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 28))
                        .padding()
                        .foregroundColor(.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .popover(isPresented: $showSettings, arrowEdge: .bottom) {
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
                .padding(8)  // Optional: You can adjust the padding around the button
            }
        }
        .onAppear() {
            viewModel.requestNotificationPermissions()
            viewModel.loadData()
        }
    }
    
    func formattedDate(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateStyle = .none
           formatter.timeStyle = .short
           return formatter.string(from: date)
       }
}

#Preview {
    ContentView()
}
