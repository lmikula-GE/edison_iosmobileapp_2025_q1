//
//  ToDoListViewModel.swift
//  ToDoListApp
//
//  Created by Lauren Mikula on 3/1/25.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications

class ToDoListViewModel: ObservableObject {
    
    private let repository: ToDoListRepository = ToDoListRepositoryImpl()
    @Published var editingItemId: UUID?
    @Published var inputTask: String = "test"
    @Published var toDoItems: [ToDoItem] = []
    
    @Published var priority: Priority = .Low
    @Published var tag: String = "None"
    @Published var notificationTime: Date? = nil
    @Published var hideCompleted: Bool = false
    
    @Published var searchQuery: String = ""
    @Published var showSettings = false
    @Published var showDatePickerToAdd = false
    @Published var showDatePickerToUpdate = false    
    
    var filteredItems: [ToDoItem] {
       let filteredByCompletion = hideCompleted ? toDoItems.filter { !$0.isComplete } : toDoItems
       return searchQuery.isEmpty ? filteredByCompletion : filteredByCompletion.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
    }
       
    func addItem() {
        if inputTask.isEmpty { return }
        let newItem = ToDoItem(title: inputTask, priority: priority.rawValue, tag: tag, notificationTime: notificationTime)
        toDoItems.append(newItem)
        sortItemsByPriority()
        inputTask = ""
        
        if notificationTime != nil{
            scheduleNotification(for: newItem)
        }
        
        repository.saveToDoItems(toDoItems)
    }
    
    func removeItem(_ item: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems.remove(at: index)
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func toggleItem(_ item: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index].isComplete.toggle()
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func updateItemText(_ item: ToDoItem, _ newValue: String) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index].title = newValue
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func updatePriority(_ item: ToDoItem, _ newPriority: String) {
           if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
               toDoItems[index].priority = newPriority
               sortItemsByPriority()
               repository.saveToDoItems(toDoItems)
           }
       }
    
    func updateTag(_ item: ToDoItem, _ newTag: String) {
           if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
               toDoItems[index].tag = newTag
               repository.saveToDoItems(toDoItems)
           }
       }
    
    func sortItemsByPriority() {
        toDoItems.sort { a, b in
            let priorityOrder = ["Low", "Medium", "High"]
            guard let aIndex = priorityOrder.firstIndex(of: a.priority),
                  let bIndex = priorityOrder.firstIndex(of: b.priority) else {
                return false
            }
            return aIndex > bIndex
        }
    }
    
    func updateNotificationTime(_ item: ToDoItem, _ newTime: Date?) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index].notificationTime = newTime
            scheduleNotification(for: toDoItems[index])
            repository.saveToDoItems(toDoItems)
        }
    }

    func scheduleNotification(for item: ToDoItem) {
        guard let notificationTime = item.notificationTime else { return }
        
        let timeInterval = notificationTime.timeIntervalSinceNow
        if timeInterval <= 0 {
            print("Notification time has already passed.")
            return
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = item.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled for \(item.title) at \(notificationTime).")
                }
            }
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Permission for push notifications denied.")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func loadData() {
        toDoItems = repository.loadToDoItems()
    }
    
    func onSubmit() {
        editingItemId = nil
        repository.saveToDoItems(toDoItems)
    }
    
    func onTapItem(_ item: ToDoItem) {
        editingItemId = item.id
        repository.saveToDoItems(toDoItems)
    }
}
