//
//  ToDoItem.swift
//  ToDoListApp
//
//  Created by Lauren Mikula on 3/1/25.
//

import Foundation

struct ToDoItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isComplete: Bool = false
    var priority: String = "Low"
    var tag: String
    var notificationTime: Date? = nil
}
