//
//  SchemaGeneratorView.swift
//  dafoma_7
//
//  Created by AI Assistant on 1/27/25.
//

import SwiftUI

struct SchemaGeneratorView: View {
    @State private var inputJSON = ""
    @State private var generatedSchema = ""
    @State private var isValid = false
    @State private var errorMessage = ""
    @State private var schemaType: SchemaType = .jsonSchema
    
    enum SchemaType: String, CaseIterable {
        case jsonSchema = "JSON Schema"
        case typescript = "TypeScript Interface"
        case swift = "Swift Struct"
        
        var icon: String {
            switch self {
            case .jsonSchema: return "doc.text"
            case .typescript: return "chevron.left.forwardslash.chevron.right"
            case .swift: return "swift"
            }
        }
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
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.appAccent)
                                        .font(.title2)
                                    Text("Schema Generator")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appTextPrimary)
                                    Spacer()
                                }
                                
                                Text("Generate schemas from JSON data")
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                            }
                            .padding(.horizontal)
                            
                            // Schema Type Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Output Format")
                                    .font(.headline)
                                    .foregroundColor(.appTextPrimary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(SchemaType.allCases, id: \.self) { type in
                                            Button(action: {
                                                schemaType = type
                                                if isValid {
                                                    generateSchema()
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: type.icon)
                                                    Text(type.rawValue)
                                                }
                                                .font(.subheadline)
                                                .foregroundColor(schemaType == type ? .white : .appTextSecondary)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .background(
                                                    schemaType == type 
                                                    ? Color.appAccent 
                                                    : Color.appSecondaryBackground
                                                )
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Input JSON Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Sample JSON")
                                        .font(.headline)
                                        .foregroundColor(.appTextPrimary)
                                    Spacer()
                                    
                                    if !inputJSON.isEmpty {
                                        Button("Clear") {
                                            inputJSON = ""
                                            generatedSchema = ""
                                            isValid = false
                                            errorMessage = ""
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
                                                .stroke(isValid ? Color.appAccent : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    TextEditor(text: $inputJSON)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.appTextPrimary)
                                        .background(Color.clear)
                                        .padding(12)
                                        .onChange(of: inputJSON) { _ in
                                            validateAndGenerate()
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
                                    
                                    if inputJSON.isEmpty {
                                        Text("Paste sample JSON to generate schema...")
                                            .foregroundColor(.appTextSecondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .frame(height: geometry.size.height * 0.25)
                            }
                            .padding(.horizontal)
                            
                            // Error Message
                            if !errorMessage.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                        Text("Error")
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
                            
                            // Generated Schema Section
                            if !generatedSchema.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Generated \(schemaType.rawValue)")
                                            .font(.headline)
                                            .foregroundColor(.appTextPrimary)
                                        Spacer()
                                        
                                        Button("Copy") {
                                            UIPasteboard.general.string = generatedSchema
                                        }
                                        .foregroundColor(.appAccent)
                                        .font(.caption)
                                    }
                                    
                                    ZStack(alignment: .topLeading) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(Color.appSecondaryBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.appAccent, lineWidth: 1)
                                            )
                                        
                                        ScrollView {
                                            Text(generatedSchema)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.appTextPrimary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(12)
                                        }
                                    }
                                    .frame(height: geometry.size.height * 0.3)
                                    
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            UIPasteboard.general.string = generatedSchema
                                        }) {
                                            HStack {
                                                Image(systemName: "doc.on.doc")
                                                Text("Copy Schema")
                                            }
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 24)
                                            .background(Color.appAccent)
                                            .cornerRadius(8)
                                        }
                                        
                                        Button(action: saveSchemaToHistory) {
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
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 20)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func validateAndGenerate() {
        guard !inputJSON.isEmpty else {
            isValid = false
            generatedSchema = ""
            errorMessage = ""
            return
        }
        
        do {
            let data = inputJSON.data(using: .utf8) ?? Data()
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            isValid = true
            errorMessage = ""
            generateSchema()
        } catch {
            isValid = false
            generatedSchema = ""
            errorMessage = error.localizedDescription
        }
    }
    
    private func generateSchema() {
        guard isValid else { return }
        
        do {
            let data = inputJSON.data(using: .utf8) ?? Data()
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            switch schemaType {
            case .jsonSchema:
                generatedSchema = generateJSONSchema(from: json)
            case .typescript:
                generatedSchema = generateTypeScriptInterface(from: json)
            case .swift:
                generatedSchema = generateSwiftStruct(from: json)
            }
        } catch {
            errorMessage = "Failed to generate schema: \(error.localizedDescription)"
        }
    }
    
    private func generateJSONSchema(from json: Any) -> String {
        var schema: [String: Any] = [
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": getType(of: json)
        ]
        
        if let dict = json as? [String: Any] {
            schema["properties"] = generateProperties(from: dict)
            schema["required"] = Array(dict.keys)
        } else if let array = json as? [Any], let firstElement = array.first {
            schema["items"] = [
                "type": getType(of: firstElement)
            ]
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: schema, options: [.prettyPrinted])
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return "Error generating schema"
        }
    }
    
    private func generateTypeScriptInterface(from json: Any) -> String {
        var result = "interface Root {\n"
        
        if let dict = json as? [String: Any] {
            for (key, value) in dict {
                let type = getTypeScriptType(of: value)
                result += "  \(key): \(type);\n"
            }
        }
        
        result += "}"
        return result
    }
    
    private func generateSwiftStruct(from json: Any) -> String {
        var result = "struct Root: Codable {\n"
        
        if let dict = json as? [String: Any] {
            for (key, value) in dict {
                let type = getSwiftType(of: value)
                let propertyName = key.replacingOccurrences(of: "_", with: "")
                result += "    let \(propertyName): \(type)\n"
            }
        }
        
        result += "}"
        return result
    }
    
    private func getType(of value: Any) -> String {
        switch value {
        case is String: return "string"
        case is Int, is Double: return "number"
        case is Bool: return "boolean"
        case is [Any]: return "array"
        case is [String: Any]: return "object"
        default: return "null"
        }
    }
    
    private func getTypeScriptType(of value: Any) -> String {
        switch value {
        case is String: return "string"
        case is Int, is Double: return "number"
        case is Bool: return "boolean"
        case is [Any]: return "any[]"
        case is [String: Any]: return "object"
        default: return "any"
        }
    }
    
    private func getSwiftType(of value: Any) -> String {
        switch value {
        case is String: return "String"
        case is Int: return "Int"
        case is Double: return "Double"
        case is Bool: return "Bool"
        case is [Any]: return "[Any]"
        case is [String: Any]: return "[String: Any]"
        default: return "Any"
        }
    }
    
    private func generateProperties(from dict: [String: Any]) -> [String: Any] {
        var properties: [String: Any] = [:]
        
        for (key, value) in dict {
            properties[key] = ["type": getType(of: value)]
        }
        
        return properties
    }
    
    private func saveSchemaToHistory() {
        HistoryManager.shared.addItem(
            type: .schema,
            content: "Input: \(inputJSON)\n\nSchema (\(schemaType.rawValue)):\n\(generatedSchema)",
            timestamp: Date()
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SchemaGeneratorView()
} 