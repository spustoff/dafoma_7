//
//  AccessibilityHelper.swift
//  dafoma_7
//
//  Created by AI Assistant on 1/27/25.
//

import SwiftUI

// MARK: - Accessibility Extensions
extension View {
    /// Adds comprehensive accessibility support for developer tools
    func developerToolAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        isButton: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(isButton ? .isButton : [])
    }
    
    /// Adds accessibility for text input fields
    func textInputAccessibility(
        label: String,
        hint: String,
        isSecure: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isSearchField)
    }
    
    /// Adds accessibility for validation status
    func validationAccessibility(isValid: Bool, errorMessage: String = "") -> some View {
        self
            .accessibilityLabel(isValid ? "Valid" : "Invalid")
            .accessibilityValue(isValid ? "Content is valid" : "Error: \(errorMessage)")
            .accessibilityAddTraits(.updatesFrequently)
    }
    
    /// Adds accessibility for tab navigation
    func tabAccessibility(title: String, isSelected: Bool) -> some View {
        self
            .accessibilityLabel(title)
            .accessibilityHint("Tab")
            .accessibilityAddTraits(.isSelected)
            .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

// MARK: - Dynamic Type Support
extension Font {
    static func dynamicTitle() -> Font {
        return .custom("System", size: UIFontMetrics.default.scaledValue(for: 28), relativeTo: .title)
    }
    
    static func dynamicHeadline() -> Font {
        return .custom("System", size: UIFontMetrics.default.scaledValue(for: 17), relativeTo: .headline)
    }
    
    static func dynamicBody() -> Font {
        return .custom("System", size: UIFontMetrics.default.scaledValue(for: 16), relativeTo: .body)
    }
    
    static func dynamicCaption() -> Font {
        return .custom("System", size: UIFontMetrics.default.scaledValue(for: 12), relativeTo: .caption)
    }
}

// MARK: - High Contrast Support
struct AccessibilityColors {
    static func textColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return .white
        case .light:
            return .black
        @unknown default:
            return .primary
        }
    }
    
    static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color.appBackground
        case .light:
            return .white
        @unknown default:
            return Color.appBackground
        }
    }
    
    static func accentColor(for colorScheme: ColorScheme) -> Color {
        // Use higher contrast in light mode for better accessibility
        switch colorScheme {
        case .dark:
            return Color.appAccent
        case .light:
            return Color.appAccent.opacity(0.8)
        @unknown default:
            return Color.appAccent
        }
    }
}

// MARK: - Accessibility Announcements
struct AccessibilityAnnouncer {
    static func announce(_ message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    static func announceValidation(isValid: Bool, type: String) {
        let message = isValid 
            ? "\(type) is valid" 
            : "\(type) validation failed"
        announce(message)
    }
    
    static func announceCompletion(action: String) {
        announce("\(action) completed")
    }
    
    static func announceError(_ error: String) {
        announce("Error: \(error)")
    }
}

// MARK: - Voice Control Support
extension View {
    func voiceControlIdentifier(_ identifier: String) -> some View {
        self.accessibilityIdentifier(identifier)
            .accessibilityRemoveTraits(.isImage)
    }
}

// MARK: - Reduced Motion Support
struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    let animation: Animation
    
    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? .none : animation, value: UUID())
    }
}

extension View {
    func respectingReducedMotion(animation: Animation = .default) -> some View {
        self.modifier(ReducedMotionModifier(animation: animation))
    }
}

// MARK: - Focus Management
struct AccessibilityFocusState {
    static func moveFocus(to element: AccessibilityFocusable) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .screenChanged, argument: element)
        }
    }
}

protocol AccessibilityFocusable {
    var accessibilityIdentifier: String { get }
}

// MARK: - Content Size Category Support
extension View {
    @ViewBuilder
    func adaptiveLayout() -> some View {
        GeometryReader { geometry in
            if geometry.size.width < 400 {
                // Compact layout for smaller screens or larger text
                VStack(alignment: .leading, spacing: 8) {
                    self
                }
            } else {
                // Regular layout
                HStack(alignment: .top, spacing: 16) {
                    self
                }
            }
        }
    }
} 