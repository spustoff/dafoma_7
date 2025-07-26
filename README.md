# JSON Dev Tools

A sophisticated iOS developer tool for JSON validation, schema generation, and API response formatting, built with SwiftUI and targeting iOS 15.6+.

## Features

### 🔍 JSON Validator
- Real-time JSON syntax validation
- Visual validation status indicators
- Clear error messages with detailed descriptions
- Copy and save functionality
- Monospaced text editor for better readability

### 📋 Schema Generator
- Generate JSON Schema from sample JSON data
- Support for multiple output formats:
  - JSON Schema (Draft 07)
  - TypeScript interfaces
  - Swift structs
- Real-time schema generation as you type
- Export and sharing capabilities

### 🎨 API Formatter
- Format and beautify various response types:
  - JSON responses
  - XML documents
  - URL parameters
  - HTTP headers
- Detailed analysis including:
  - File size calculation
  - Structure analysis
  - Key/array counting
  - Nesting level detection

### 📚 History
- Persistent storage of recent work
- Search and filter functionality
- Categorized by operation type
- Export and deletion options

## Design & Accessibility

### Color Scheme
- **Background**: Deep gradient from #090F1E to #1A2339
- **Interactive Elements**: Bright blue #01A2FF
- **Modern, developer-focused aesthetic**

### Accessibility Features
- Full VoiceOver support
- Dynamic Type compatibility
- High contrast mode support
- Voice Control optimization
- Switch Control compatibility
- Reduced motion respect

## Technical Details

- **Platform**: iOS 15.6+
- **Framework**: SwiftUI
- **Architecture**: MVVM with ObservableObject state management
- **Data Persistence**: UserDefaults with JSON encoding
- **Build Target**: Universal (iPhone/iPad)

## App Store Compliance

This app is designed to comply with Apple's App Store Review Guidelines:

- **Guideline 4.3**: Unique functionality in developer tools category
- **Guideline 4.3(a)**: Distinctive features and user interface
- **Guideline 2.1.3**: Clear purpose and functionality

## Installation

1. Clone the repository
2. Open `dafoma_7.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device
4. Minimum iOS version: 15.6

## Usage

### JSON Validation
1. Navigate to the "Validator" tab
2. Paste or type JSON content
3. View real-time validation status
4. Format valid JSON or fix errors
5. Save to history for later reference

### Schema Generation
1. Go to "Schema" tab
2. Paste sample JSON data
3. Select desired output format
4. View generated schema instantly
5. Copy or save the generated schema

### API Response Formatting
1. Open "Formatter" tab
2. Choose response type (JSON, XML, URL, Headers)
3. Paste raw response data
4. View formatted output and analysis
5. Export formatted results

## Contributing

This project follows Swift coding standards and SwiftUI best practices. Please ensure any contributions maintain:

- iOS 15.6+ compatibility
- Accessibility compliance
- Dark mode support
- Consistent color scheme usage

## License

Developed as a unique developer tool for the iOS ecosystem.

## Contact

For questions or support regarding this developer tool, please refer to the in-app documentation or contact through the App Store. 