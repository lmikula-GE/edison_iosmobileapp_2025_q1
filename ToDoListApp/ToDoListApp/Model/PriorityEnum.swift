//
//  PriorityEnum.swift
//  ToDoListApp
//
//  Created by Lauren Mikula on 3/2/25.
//

import Foundation

enum Priority: String, CaseIterable, Identifiable {
    case Low, Medium, High
    
    var id: Self { self }
}
