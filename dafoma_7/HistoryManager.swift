//
//  HistoryManager.swift
//  dafoma_7
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation
import SwiftUI

// MARK: - History Item Types
enum HistoryItemType: String, CaseIterable, Codable {
    case validation = "validation"
    case schema = "schema"
    case formatting = "formatting"
    
    var displayName: String {
        switch self {
        case .validation: return "JSON Validation"
        case .schema: return "Schema Generation"
        case .formatting: return "API Formatting"
        }
    }
    
    var icon: String {
        switch self {
        case .validation: return "checkmark.seal.fill"
        case .schema: return "doc.text.fill"
        case .formatting: return "text.alignleft"
        }
    }
}

// MARK: - History Item Model
struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let type: HistoryItemType
    let content: String
    let timestamp: Date
    
    init(type: HistoryItemType, content: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - History Manager
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var items: [HistoryItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "app_history_items"
    private let maxHistoryItems = 100
    
    private init() {
        loadHistory()
    }
    
    // MARK: - Public Methods
    func addItem(type: HistoryItemType, content: String, timestamp: Date = Date()) {
        let newItem = HistoryItem(type: type, content: content, timestamp: timestamp)
        
        DispatchQueue.main.async {
            self.items.insert(newItem, at: 0)
            
            // Limit the number of history items
            if self.items.count > self.maxHistoryItems {
                self.items = Array(self.items.prefix(self.maxHistoryItems))
            }
            
            self.saveHistory()
        }
    }
    
    func removeItem(_ item: HistoryItem) {
        DispatchQueue.main.async {
            self.items.removeAll { $0.id == item.id }
            self.saveHistory()
        }
    }
    
    func clearAll() {
        DispatchQueue.main.async {
            self.items.removeAll()
            self.saveHistory()
        }
    }
    
    func getItems(ofType type: HistoryItemType) -> [HistoryItem] {
        return items.filter { $0.type == type }
    }
    
    func searchItems(query: String) -> [HistoryItem] {
        guard !query.isEmpty else { return items }
        
        return items.filter { item in
            item.content.localizedCaseInsensitiveContains(query) ||
            item.type.displayName.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Private Methods
    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items)
            userDefaults.set(data, forKey: historyKey)
        } catch {
            print("Failed to save history: \(error.localizedDescription)")
        }
    }
    
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            items = try decoder.decode([HistoryItem].self, from: data)
        } catch {
            print("Failed to load history: \(error.localizedDescription)")
            items = []
        }
    }
}

// MARK: - Sample Data Extension (for preview purposes)
extension HistoryManager {
    static func sampleData() -> HistoryManager {
        let manager = HistoryManager()
        
        // Add some sample data for previews
        manager.items = [
            HistoryItem(
                type: .validation,
                content: """
                {
                  "name": "John Doe",
                  "age": 30,
                  "email": "john@example.com",
                  "address": {
                    "street": "123 Main St",
                    "city": "New York",
                    "zipCode": "10001"
                  }
                }
                """,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            HistoryItem(
                type: .schema,
                content: """
                Input: {"name": "test", "value": 42}
                
                Schema (JSON Schema):
                {
                  "$schema": "http://json-schema.org/draft-07/schema#",
                  "type": "object",
                  "properties": {
                    "name": {"type": "string"},
                    "value": {"type": "number"}
                  },
                  "required": ["name", "value"]
                }
                """,
                timestamp: Date().addingTimeInterval(-7200)
            ),
            HistoryItem(
                type: .formatting,
                content: """
                Type: JSON
                
                Input:
                {"compressed":true,"data":[1,2,3]}
                
                Formatted:
                {
                  "compressed": true,
                  "data": [
                    1,
                    2,
                    3
                  ]
                }
                """,
                timestamp: Date().addingTimeInterval(-10800)
            )
        ]
        
        return manager
    }
} 