//
//  HistoryView.swift
//  dafoma_7
//
//  Created by AI Assistant on 1/27/25.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var historyManager = HistoryManager.shared
    @State private var selectedFilter: HistoryItemType? = nil
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var selectedItem: HistoryItem?
    
    var filteredItems: [HistoryItem] {
        var items = historyManager.items
        
        // Apply type filter
        if let filter = selectedFilter {
            items = items.filter { $0.type == filter }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.content.localizedCaseInsensitiveContains(searchText) ||
                item.type.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.appBackground, Color.appSecondaryBackground]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.appAccent)
                                    .font(.title2)
                                Text("History")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appTextPrimary)
                                Spacer()
                                
                                if !historyManager.items.isEmpty {
                                    Button("Clear All") {
                                        showingDeleteAlert = true
                                    }
                                    .foregroundColor(.red)
                                    .font(.caption)
                                }
                            }
                            
                            Text("View and manage your recent work")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.horizontal)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.appTextSecondary)
                            
                                                    TextField("Search history...", text: $searchText)
                            .font(.body)
                            .foregroundColor(.appTextPrimary)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    Button("Hide Keyboard") {
                                        hideKeyboard()
                                    }
                                    .foregroundColor(.appAccent)
                                    .font(.headline)
                                    .accessibilityLabel("Hide Keyboard")
                                    .accessibilityHint("Dismisses the keyboard")
                                }
                            }
                        }
                        .padding()
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        // Filter Buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterButton(
                                    title: "All",
                                    isSelected: selectedFilter == nil,
                                    count: historyManager.items.count
                                ) {
                                    selectedFilter = nil
                                }
                                
                                ForEach(HistoryItemType.allCases, id: \.self) { type in
                                    let count = historyManager.items.filter { $0.type == type }.count
                                    if count > 0 {
                                        FilterButton(
                                            title: type.displayName,
                                            isSelected: selectedFilter == type,
                                            count: count
                                        ) {
                                            selectedFilter = type
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // History List
                        if filteredItems.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 48))
                                    .foregroundColor(.appTextSecondary)
                                
                                Text(historyManager.items.isEmpty ? "No history yet" : "No matching items")
                                    .font(.headline)
                                    .foregroundColor(.appTextPrimary)
                                
                                Text(historyManager.items.isEmpty ? 
                                     "Your saved work will appear here" : 
                                     "Try adjusting your search or filter")
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredItems) { item in
                                        HistoryItemRow(item: item) { selectedItem in
                                            self.selectedItem = selectedItem
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedItem) { item in
            HistoryDetailView(item: item)
        }
        .alert("Clear History", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                historyManager.clearAll()
            }
        } message: {
            Text("This will permanently delete all history items. This action cannot be undone.")
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if count > 0 {
                    Text("(\(count))")
                        .font(.caption)
                }
            }
            .font(.subheadline)
            .foregroundColor(isSelected ? .white : .appTextSecondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                isSelected 
                ? Color.appAccent 
                : Color.appSecondaryBackground
            )
            .cornerRadius(8)
        }
    }
}

// MARK: - History Item Row
struct HistoryItemRow: View {
    let item: HistoryItem
    let onTap: (HistoryItem) -> Void
    
    private var previewText: String {
        let lines = item.content.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return firstLine.count > 80 ? String(firstLine.prefix(77)) + "..." : firstLine
    }
    
    var body: some View {
        Button {
            onTap(item)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack {
                        Image(systemName: item.type.icon)
                            .foregroundColor(.appAccent)
                        Text(item.type.displayName)
                            .font(.caption)
                            .foregroundColor(.appAccent)
                    }
                    
                    Spacer()
                    
                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Text(previewText)
                    .font(.body)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.appSecondaryBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - History Detail View
struct HistoryDetailView: View {
    let item: HistoryItem
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.appBackground, Color.appSecondaryBackground]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: item.type.icon)
                                    .foregroundColor(.appAccent)
                                Text(item.type.displayName)
                                    .font(.headline)
                                    .foregroundColor(.appTextPrimary)
                            }
                            
                            Text(item.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.horizontal)
                        
                        // Content
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color.appSecondaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                                )
                            
                            ScrollView {
                                Text(item.content)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.appTextPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                UIPasteboard.general.string = item.content
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Color.appAccent)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                HistoryManager.shared.removeItem(item)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("History Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.appAccent)
            )
        }
    }
}

#Preview {
    HistoryView()
} 