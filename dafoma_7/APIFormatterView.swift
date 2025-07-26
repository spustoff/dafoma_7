//
//  APIFormatterView.swift
//  dafoma_7
//
//  Created by AI Assistant on 1/27/25.
//

import SwiftUI

struct APIFormatterView: View {
    @State private var inputText = ""
    @State private var formattedOutput = ""
    @State private var selectedFormat: FormatType = .json
    @State private var isValid = false
    @State private var errorMessage = ""
    @State private var showOutput = false
    @State private var analysisResults: AnalysisResults?
    
    enum FormatType: String, CaseIterable {
        case json = "JSON"
        case xml = "XML"
        case url = "URL Params"
        case headers = "HTTP Headers"
        
        var icon: String {
            switch self {
            case .json: return "doc.text"
            case .xml: return "chevron.left.forwardslash.chevron.right"
            case .url: return "link"
            case .headers: return "list.bullet"
            }
        }
        
        var placeholder: String {
            switch self {
            case .json: return "Paste your JSON response here..."
            case .xml: return "Paste your XML response here..."
            case .url: return "Paste URL parameters (key=value&key2=value2)..."
            case .headers: return "Paste HTTP headers here..."
            }
        }
    }
    
    struct AnalysisResults {
        let size: String
        let structure: String
        let keyCount: Int?
        let arrayCount: Int?
        let nestedLevels: Int?
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
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.appAccent)
                                        .font(.title2)
                                    Text("API Formatter")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appTextPrimary)
                                    Spacer()
                                }
                                
                                Text("Format and analyze API responses")
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                            }
                            .padding(.horizontal)
                            
                            // Format Type Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Response Type")
                                    .font(.headline)
                                    .foregroundColor(.appTextPrimary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(FormatType.allCases, id: \.self) { type in
                                            Button(action: {
                                                selectedFormat = type
                                                if !inputText.isEmpty {
                                                    formatInput()
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: type.icon)
                                                    Text(type.rawValue)
                                                }
                                                .font(.subheadline)
                                                .foregroundColor(selectedFormat == type ? .white : .appTextSecondary)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .background(
                                                    selectedFormat == type 
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
                            
                            // Input Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Raw Response")
                                        .font(.headline)
                                        .foregroundColor(.appTextPrimary)
                                    Spacer()
                                    
                                    if !inputText.isEmpty {
                                        Button("Clear") {
                                            inputText = ""
                                            formattedOutput = ""
                                            isValid = false
                                            errorMessage = ""
                                            analysisResults = nil
                                            showOutput = false
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
                                                .stroke(isValid ? Color.appAccent : (inputText.isEmpty ? Color.gray.opacity(0.3) : Color.red), lineWidth: 1)
                                        )
                                    
                                    TextEditor(text: $inputText)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.appTextPrimary)
                                        .background(Color.clear)
                                        .padding(12)
                                        .onChange(of: inputText) { _ in
                                            formatInput()
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
                                    
                                    if inputText.isEmpty {
                                        Text(selectedFormat.placeholder)
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
                                        Text("Format Error")
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
                            
                            // Analysis Results
                            if let analysis = analysisResults {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Analysis")
                                        .font(.headline)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    VStack(spacing: 8) {
                                        AnalysisRow(title: "Size", value: analysis.size)
                                        AnalysisRow(title: "Type", value: analysis.structure)
                                        
                                        if let keyCount = analysis.keyCount {
                                            AnalysisRow(title: "Keys", value: "\(keyCount)")
                                        }
                                        
                                        if let arrayCount = analysis.arrayCount {
                                            AnalysisRow(title: "Arrays", value: "\(arrayCount)")
                                        }
                                        
                                        if let nestedLevels = analysis.nestedLevels {
                                            AnalysisRow(title: "Nesting", value: "\(nestedLevels) levels")
                                        }
                                    }
                                    .padding()
                                    .background(Color.appSecondaryBackground.opacity(0.5))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Formatted Output Section
                            if showOutput && !formattedOutput.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Formatted \(selectedFormat.rawValue)")
                                            .font(.headline)
                                            .foregroundColor(.appTextPrimary)
                                        Spacer()
                                        
                                        Button("Copy") {
                                            UIPasteboard.general.string = formattedOutput
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
                                            Text(formattedOutput)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.appTextPrimary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(12)
                                        }
                                    }
                                    .frame(height: geometry.size.height * 0.3)
                                    
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            UIPasteboard.general.string = formattedOutput
                                        }) {
                                            HStack {
                                                Image(systemName: "doc.on.doc")
                                                Text("Copy Formatted")
                                            }
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 24)
                                            .background(Color.appAccent)
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
    
    private func formatInput() {
        guard !inputText.isEmpty else {
            isValid = false
            formattedOutput = ""
            errorMessage = ""
            analysisResults = nil
            showOutput = false
            return
        }
        
        switch selectedFormat {
        case .json:
            formatJSON()
        case .xml:
            formatXML()
        case .url:
            formatURLParams()
        case .headers:
            formatHeaders()
        }
    }
    
    private func formatJSON() {
        do {
            let data = inputText.data(using: .utf8) ?? Data()
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            let formattedData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            formattedOutput = String(data: formattedData, encoding: .utf8) ?? ""
            isValid = true
            errorMessage = ""
            showOutput = true
            
            // Generate analysis
            analysisResults = analyzeJSON(json: json, data: data)
        } catch {
            isValid = false
            errorMessage = error.localizedDescription
            showOutput = false
            analysisResults = nil
        }
    }
    
    private func formatXML() {
        // Basic XML formatting (simplified)
        let lines = inputText.components(separatedBy: .newlines)
        var formatted = ""
        var indentLevel = 0
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            
            if trimmed.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            formatted += String(repeating: "  ", count: indentLevel) + trimmed + "\n"
            
            if trimmed.hasPrefix("<") && !trimmed.hasPrefix("</") && !trimmed.hasSuffix("/>") {
                indentLevel += 1
            }
        }
        
        formattedOutput = formatted
        isValid = true
        errorMessage = ""
        showOutput = true
        
        let size = ByteCountFormatter.string(fromByteCount: Int64(inputText.utf8.count), countStyle: .file)
        analysisResults = AnalysisResults(
            size: size,
            structure: "XML Document",
            keyCount: nil,
            arrayCount: nil,
            nestedLevels: indentLevel
        )
    }
    
    private func formatURLParams() {
        let params = inputText.components(separatedBy: "&")
        var formatted = ""
        
        for param in params {
            let parts = param.components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                formatted += "\(key) = \(value)\n"
            }
        }
        
        formattedOutput = formatted
        isValid = true
        errorMessage = ""
        showOutput = true
        
        let size = ByteCountFormatter.string(fromByteCount: Int64(inputText.utf8.count), countStyle: .file)
        analysisResults = AnalysisResults(
            size: size,
            structure: "URL Parameters",
            keyCount: params.count,
            arrayCount: nil,
            nestedLevels: nil
        )
    }
    
    private func formatHeaders() {
        let lines = inputText.components(separatedBy: .newlines)
        var formatted = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            
            let parts = trimmed.components(separatedBy: ":")
            if parts.count >= 2 {
                let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
                formatted += "\(key): \(value)\n"
            } else {
                formatted += trimmed + "\n"
            }
        }
        
        formattedOutput = formatted
        isValid = true
        errorMessage = ""
        showOutput = true
        
        let size = ByteCountFormatter.string(fromByteCount: Int64(inputText.utf8.count), countStyle: .file)
        analysisResults = AnalysisResults(
            size: size,
            structure: "HTTP Headers",
            keyCount: lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count,
            arrayCount: nil,
            nestedLevels: nil
        )
    }
    
    private func analyzeJSON(json: Any, data: Data) -> AnalysisResults {
        let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
        
        var keyCount = 0
        var arrayCount = 0
        var maxNesting = 0
        
        func analyze(_ object: Any, level: Int = 0) {
            maxNesting = max(maxNesting, level)
            
            if let dict = object as? [String: Any] {
                keyCount += dict.count
                for (_, value) in dict {
                    analyze(value, level: level + 1)
                }
            } else if let array = object as? [Any] {
                arrayCount += 1
                for item in array {
                    analyze(item, level: level + 1)
                }
            }
        }
        
        analyze(json)
        
        let structureType: String
        if json is [String: Any] {
            structureType = "Object"
        } else if json is [Any] {
            structureType = "Array"
        } else {
            structureType = "Primitive"
        }
        
        return AnalysisResults(
            size: size,
            structure: structureType,
            keyCount: keyCount > 0 ? keyCount : nil,
            arrayCount: arrayCount > 0 ? arrayCount : nil,
            nestedLevels: maxNesting > 0 ? maxNesting : nil
        )
    }
    
    private func saveToHistory() {
        HistoryManager.shared.addItem(
            type: .formatting,
            content: "Type: \(selectedFormat.rawValue)\n\nInput:\n\(inputText)\n\nFormatted:\n\(formattedOutput)",
            timestamp: Date()
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Analysis Row Component
struct AnalysisRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.appTextPrimary)
        }
    }
}

#Preview {
    APIFormatterView()
} 