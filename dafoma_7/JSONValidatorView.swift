//
//  JSONValidatorView.swift
//  dafoma_7
//
//  Created by AI Assistant on 1/27/25.
//

import SwiftUI

struct JSONValidatorView: View {
    @State private var jsonText = ""
    @State private var isValid = false
    @State private var errorMessage = ""
    @State private var formattedJSON = ""
    @State private var showFormattedView = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
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
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.appAccent)
                                    .font(.title2)
                                Text("JSON Validator")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appTextPrimary)
                                Spacer()
                                
                                // Validation Status
                                HStack(spacing: 8) {
                                    Circle()
                                        .foregroundColor(isValid ? Color.green : (jsonText.isEmpty ? Color.gray : Color.red))
                                        .frame(width: 12, height: 12)
                                    Text(jsonText.isEmpty ? "Ready" : (isValid ? "Valid" : "Invalid"))
                                        .font(.caption)
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                            
                            Text("Validate and format JSON in real-time")
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.horizontal)
                        
                        // Input Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("JSON Input")
                                    .font(.headline)
                                    .foregroundColor(.appTextPrimary)
                                Spacer()
                                
                                if !jsonText.isEmpty {
                                    Button("Clear") {
                                        jsonText = ""
                                        isValid = false
                                        errorMessage = ""
                                        formattedJSON = ""
                                    }
                                    .foregroundColor(.appAccent)
                                    .font(.caption)
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(Color.appSecondaryBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isValid ? Color.appAccent : (jsonText.isEmpty ? Color.gray.opacity(0.3) : Color.red), lineWidth: 1)
                                    )
                                
                                TextEditor(text: $jsonText)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.appTextPrimary)
                                    .background(Color.clear)
                                    .padding(12)
                                    .onChange(of: jsonText) { _ in
                                        validateJSON()
                                    }
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
                                
                                if jsonText.isEmpty {
                                    Text("Paste your JSON here...")
                                        .foregroundColor(.appTextSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                        .allowsHitTesting(false)
                                }
                            }
                            .frame(height: geometry.size.height * 0.35)
                        }
                        .padding(.horizontal)
                        
                        // Error Message
                        if !errorMessage.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("Validation Error")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                                
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                    .padding(.horizontal, 24)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        if isValid && !jsonText.isEmpty {
                            HStack(spacing: 16) {
                                Button(action: formatJSON) {
                                    HStack {
                                        Image(systemName: "text.alignleft")
                                        Text("Format")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Color.appAccent)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: copyToClipboard) {
                                    HStack {
                                        Image(systemName: "doc.on.doc")
                                        Text("Copy")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.appAccent)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Color.appAccent.opacity(0.2))
                                    .cornerRadius(8)
                                }
                                
                                Button(action: saveToHistory) {
                                    HStack {
                                        Image(systemName: "bookmark")
                                        Text("Save")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.appAccent)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Color.appAccent.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFormattedView) {
            FormattedJSONView(jsonString: formattedJSON)
        }
    }
    
    private func validateJSON() {
        guard !jsonText.isEmpty else {
            isValid = false
            errorMessage = ""
            return
        }
        
        do {
            let data = jsonText.data(using: .utf8) ?? Data()
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            isValid = true
            errorMessage = ""
        } catch {
            isValid = false
            errorMessage = error.localizedDescription
        }
    }
    
    private func formatJSON() {
        guard isValid else { return }
        
        do {
            let data = jsonText.data(using: .utf8) ?? Data()
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            let formattedData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            formattedJSON = String(data: formattedData, encoding: .utf8) ?? ""
            showFormattedView = true
        } catch {
            errorMessage = "Failed to format JSON: \(error.localizedDescription)"
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = jsonText
    }
    
    private func saveToHistory() {
        HistoryManager.shared.addItem(
            type: .validation,
            content: jsonText,
            timestamp: Date()
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Formatted JSON View
struct FormattedJSONView: View {
    let jsonString: String
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
                    Text(jsonString)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.appTextPrimary)
                        .padding()
                }
            }
            .navigationTitle("Formatted JSON")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.appAccent),
                trailing: Button("Copy") {
                    UIPasteboard.general.string = jsonString
                }
                .foregroundColor(.appAccent)
            )
        }
    }
}

#Preview {
    JSONValidatorView()
} 