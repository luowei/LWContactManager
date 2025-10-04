# LWContactManager - Swift Version

A modern Swift/SwiftUI library for managing iOS contacts with Chinese pinyin sorting support.

## Overview

LWContactManagerSwift is a complete rewrite of the original Objective-C LWContactManager library, built with modern Swift features including async/await, SwiftUI, and Combine support. It uses the native iOS Contacts framework with no external dependencies.

## Features

- ✅ **Native Contacts Framework** - Uses iOS native Contacts framework (no APAddressBook dependency)
- ✅ **Async/Await Support** - Modern Swift concurrency for iOS 13+
- ✅ **Callback-based API** - Compatible with iOS 12+
- ✅ **SwiftUI Views** - Built-in contact picker and view models
- ✅ **Combine Support** - Reactive programming with @Published properties
- ✅ **Chinese Pinyin Sorting** - Automatic sorting by pinyin for Chinese names
- ✅ **Search/Filter** - Built-in contact search functionality
- ✅ **Type Safe** - Strongly typed Swift models
- ✅ **No External Dependencies** - Pure Swift implementation

## Requirements

- iOS 12.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

### CocoaPods

```ruby
pod 'LWContactManagerSwift', '~> 1.0'
```

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/luowei/LWContactManager.git", from: "1.0.0")
]
```

Or in Xcode:
1. File > Add Packages...
2. Enter package URL: `https://github.com/luowei/LWContactManager.git`

## Quick Start

### 1. Add Privacy Description

Add to your `Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts to help you select recipients.</string>
```

### 2. Request Access and Load Contacts (Async/Await)

```swift
import LWContactManager

let service = LWContactService()

// Request access
let granted = try await service.requestAccess()

// Load contacts
let contacts = try await service.loadContacts()

// Search contacts
let results = try await service.loadContacts(searchText: "John")
```

### 3. Using SwiftUI Contact Picker

```swift
import SwiftUI
import LWContactManager

struct ContentView: View {
    @State private var showPicker = false
    @State private var selectedContact: LWContact?

    var body: some View {
        VStack {
            Button("Select Contact") {
                showPicker = true
            }

            if let contact = selectedContact {
                Text("Selected: \(contact.displayName)")
            }
        }
        .sheet(isPresented: $showPicker) {
            LWContactPickerView { contact in
                selectedContact = contact
            }
        }
    }
}
```

## API Documentation

### LWContactService

Main service class for accessing contacts.

#### Initialization

```swift
// Default initialization
let service = LWContactService()

// With specific language for sorting
let service = LWContactService(primaryLanguage: "zh")
```

#### Methods (Async/Await)

```swift
// Request contacts access
func requestAccess() async throws -> Bool

// Load all contacts
func loadContacts(searchText: String? = nil) async throws -> [LWContact]
```

#### Methods (Callback-based)

```swift
// Request contacts access
func requestAccess(completion: @escaping (Bool, Error?) -> Void)

// Load contacts
func loadContacts(searchText: String? = nil,
                 completion: @escaping ([LWContact], Error?) -> Void)
```

### LWContact

Contact model with essential information.

```swift
struct LWContact {
    let id: String
    let firstName: String
    let lastName: String
    let phoneNumbers: [LWPhoneNumber]
    let thumbnailImageData: Data?

    var fullName: String { get }
    var displayName: String { get }
}
```

### LWPhoneNumber

Phone number model.

```swift
struct LWPhoneNumber {
    let number: String
    let label: String?
}
```

### LWContactViewModel

SwiftUI ViewModel for managing contacts.

```swift
@MainActor
class LWContactViewModel: ObservableObject {
    @Published var contacts: [LWContact]
    @Published var searchText: String
    @Published var isLoading: Bool
    @Published var errorMessage: String?

    func requestAccess() async
    func loadContacts() async
    func refresh() async
}
```

### LWContactPickerView

SwiftUI view for picking contacts.

```swift
LWContactPickerView(
    primaryLanguage: "zh",  // Optional
    onContactSelected: { contact in
        print("Selected: \(contact.displayName)")
    }
)
```

### PinyinHelper

Utility for Chinese character to pinyin conversion.

```swift
class PinyinHelper {
    static func pinyinFirstLetter(for character: Character) -> Character
    static func pinyinFirstLetter(for string: String) -> Character
}
```

## Usage Examples

### Example 1: Basic Contact Loading

```swift
import LWContactManager

class ContactsViewController: UIViewController {
    let service = LWContactService()

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            do {
                let granted = try await service.requestAccess()
                guard granted else {
                    print("Access denied")
                    return
                }

                let contacts = try await service.loadContacts()
                print("Loaded \(contacts.count) contacts")

                // Display contacts in UI
                updateUI(with: contacts)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

### Example 2: Search Contacts

```swift
func searchContacts(query: String) async {
    do {
        let contacts = try await service.loadContacts(searchText: query)
        print("Found \(contacts.count) matching contacts")
    } catch {
        print("Error: \(error)")
    }
}
```

### Example 3: SwiftUI List View

```swift
import SwiftUI
import LWContactManager

struct ContactListView: View {
    @StateObject private var viewModel = LWContactViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.contacts) { contact in
                ContactRow(contact: contact)
            }
            .navigationTitle("Contacts")
            .searchable(text: $viewModel.searchText)
            .task {
                await viewModel.requestAccess()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

struct ContactRow: View {
    let contact: LWContact

    var body: some View {
        VStack(alignment: .leading) {
            Text(contact.displayName)
                .font(.headline)
            if let phone = contact.phoneNumbers.first {
                Text(phone.number)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

### Example 4: Chinese Pinyin Sorting

```swift
// Create service with Chinese language
let service = LWContactService(primaryLanguage: "zh")

// Contacts will be automatically sorted by pinyin
let contacts = try await service.loadContacts()
```

### Example 5: Callback-based API (iOS 12 Compatible)

```swift
service.requestAccess { granted, error in
    guard granted else {
        print("Access denied")
        return
    }

    self.service.loadContacts { contacts, error in
        if let error = error {
            print("Error: \(error)")
            return
        }

        DispatchQueue.main.async {
            self.updateUI(with: contacts)
        }
    }
}
```

### Example 6: Direct Pinyin Conversion

```swift
import LWContactManager

let name = "张三"
let firstLetter = PinyinHelper.pinyinFirstLetter(for: name)
print(firstLetter) // Output: Z

// Use for custom sorting
let sortedNames = names.sorted { name1, name2 in
    let pinyin1 = PinyinHelper.pinyinFirstLetter(for: name1)
    let pinyin2 = PinyinHelper.pinyinFirstLetter(for: name2)
    return pinyin1 < pinyin2
}
```

## Migration from Objective-C

See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for detailed migration instructions from the Objective-C version.

### Quick Comparison

**Objective-C:**
```objc
LWAddressBookService *service = [LWAddressBookService new];
[service requestAccess:^(BOOL granted, NSError *error) {
    [service loadContactsWithSearchText:nil successBlock:^(NSArray *contacts, NSError *error) {
        // Use contacts
    }];
}];
```

**Swift:**
```swift
let service = LWContactService()
let granted = try await service.requestAccess()
let contacts = try await service.loadContacts()
```

## Architecture

```
LWContactManager/
├── LWContactManager.swift      # Main entry point
├── LWContactService.swift      # Core service with Contacts framework
├── LWContactModel.swift        # Contact and phone number models
├── PinyinHelper.swift          # Chinese pinyin conversion
├── LWContactViewModel.swift    # SwiftUI ViewModel
└── LWContactPickerView.swift   # SwiftUI contact picker
```

## Advantages Over Objective-C Version

1. **No External Dependencies** - Uses native Contacts framework instead of APAddressBook
2. **Modern Swift** - Async/await, property wrappers, result builders
3. **SwiftUI Support** - Built-in views and view models
4. **Better Type Safety** - Strongly typed models and APIs
5. **Reactive** - Combine integration via @Published properties
6. **Performance** - Direct framework access without wrapper overhead
7. **Maintainability** - Pure Swift codebase, easier to maintain
8. **Future-Proof** - Uses non-deprecated APIs

## License

MIT License - See LICENSE file for details

## Author

luowei - luowei@wodedata.com

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

- GitHub Issues: https://github.com/luowei/LWContactManager/issues
- Email: luowei@wodedata.com

## Changelog

### Version 1.0.0
- Initial Swift version release
- Async/await support
- SwiftUI components
- Chinese pinyin sorting
- No external dependencies
- iOS 12+ support
