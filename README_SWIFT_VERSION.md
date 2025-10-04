# LWContactManager Swift Version

This document describes how to use the Swift/SwiftUI version of LWContactManager.

## Overview

LWContactManager_swift is a modern Swift/SwiftUI implementation of the LWContactManager library. It provides a comprehensive, privacy-aware contact management solution with full support for SwiftUI, Combine framework, and the iOS Contacts framework.

## Requirements

- iOS 14.0+
- Swift 5.0+
- Xcode 12.0+

## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'LWContactManager_swift'
```

Then run:
```bash
pod install
```

## Key Features

- **Contacts Framework Integration** - Modern iOS Contacts API support
- **SwiftUI Native** - Built-in SwiftUI contact picker view
- **Pinyin Support** - Chinese name sorting and searching with Pinyin
- **Privacy First** - Proper permission handling and user consent
- **Contact Grouping** - Automatic grouping by first letter/initial
- **Real-time Search** - Fast, responsive contact filtering
- **Combine Publishers** - Reactive contact updates
- **Type Safe** - Full Swift type safety with structured models

## Quick Start

### Basic Contact Fetching

```swift
import LWContactManager_swift

// Request permission and fetch contacts
let service = LWContactService.shared

Task {
    let authorized = await service.requestAccess()

    if authorized {
        let contacts = await service.fetchAllContacts()
        print("Fetched \(contacts.count) contacts")
    }
}
```

### SwiftUI Contact Picker

```swift
import SwiftUI
import LWContactManager_swift

struct ContentView: View {
    @State private var selectedContact: LWContactModel?
    @State private var showPicker = false

    var body: some View {
        VStack {
            Button("Select Contact") {
                showPicker = true
            }

            if let contact = selectedContact {
                VStack(alignment: .leading) {
                    Text(contact.fullName)
                        .font(.headline)
                    Text(contact.phoneNumber ?? "No phone")
                        .font(.subheadline)
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            LWContactPickerView(selectedContact: $selectedContact)
        }
    }
}
```

### Using Contact View Model

```swift
import SwiftUI
import LWContactManager_swift

struct ContactListView: View {
    @StateObject private var viewModel = LWContactViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                SearchBar(text: $viewModel.searchText)

                // Contact list
                List {
                    ForEach(viewModel.groupedContacts.keys.sorted(), id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(viewModel.groupedContacts[key] ?? []) { contact in
                                ContactRow(contact: contact)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Contacts")
            .task {
                await viewModel.loadContacts()
            }
        }
    }
}

struct ContactRow: View {
    let contact: LWContactModel

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text(contact.fullName)
                    .font(.headline)

                if let phone = contact.phoneNumber {
                    Text(phone)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
```

## Advanced Usage

### Contact Service

```swift
import LWContactManager_swift

class ContactManager: ObservableObject {
    private let service = LWContactService.shared
    @Published var contacts: [LWContactModel] = []
    @Published var authorizationStatus: CNAuthorizationStatus = .notDetermined

    func checkAuthorization() async {
        authorizationStatus = await service.authorizationStatus()
    }

    func requestPermission() async -> Bool {
        return await service.requestAccess()
    }

    func loadAllContacts() async {
        contacts = await service.fetchAllContacts()
    }

    func searchContacts(query: String) async {
        contacts = await service.searchContacts(query: query)
    }

    func getContact(by identifier: String) async -> LWContactModel? {
        return await service.fetchContact(identifier: identifier)
    }
}
```

### Pinyin-based Search

```swift
import LWContactManager_swift

// Search with Pinyin support
let viewModel = LWContactViewModel()

// Search by name
viewModel.searchText = "张三"  // Will find contacts

// Search by Pinyin
viewModel.searchText = "zhang"  // Will find "张三" and other "Zhang" surnames
viewModel.searchText = "zs"     // Will find "张三" using initials

// The PinyinHelper automatically handles:
// - Full Pinyin matching
// - Pinyin initial matching
// - Chinese character matching
```

### Contact Grouping

```swift
import LWContactManager_swift

class ContactGrouper {
    func groupContactsByInitial(_ contacts: [LWContactModel]) -> [String: [LWContactModel]] {
        var grouped: [String: [LWContactModel]] = [:]

        for contact in contacts {
            let initial = PinyinHelper.getFirstLetter(of: contact.fullName)
            if grouped[initial] == nil {
                grouped[initial] = []
            }
            grouped[initial]?.append(contact)
        }

        return grouped
    }

    func sortedKeys(from grouped: [String: [LWContactModel]]) -> [String] {
        grouped.keys.sorted { key1, key2 in
            // Special characters and numbers go to end
            if key1.rangeOfCharacter(from: .letters) == nil { return false }
            if key2.rangeOfCharacter(from: .letters) == nil { return true }
            return key1 < key2
        }
    }
}
```

### Custom Contact Picker

```swift
struct CustomContactPicker: View {
    @StateObject private var viewModel = LWContactViewModel()
    @Binding var selectedContacts: [LWContactModel]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)

                List(viewModel.filteredContacts) { contact in
                    ContactSelectionRow(
                        contact: contact,
                        isSelected: selectedContacts.contains(where: { $0.id == contact.id })
                    ) {
                        toggleSelection(contact)
                    }
                }
            }
            .navigationTitle("Select Contacts")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") { dismiss() }
            )
            .task {
                await viewModel.loadContacts()
            }
        }
    }

    private func toggleSelection(_ contact: LWContactModel) {
        if let index = selectedContacts.firstIndex(where: { $0.id == contact.id }) {
            selectedContacts.remove(at: index)
        } else {
            selectedContacts.append(contact)
        }
    }
}
```

## SwiftUI-Specific Features

### Contact Permission View

```swift
struct ContactPermissionView: View {
    @State private var authStatus: CNAuthorizationStatus = .notDetermined
    let service = LWContactService.shared

    var body: some View {
        VStack(spacing: 20) {
            switch authStatus {
            case .notDetermined:
                Text("We need access to your contacts")
                Button("Grant Permission") {
                    Task {
                        _ = await service.requestAccess()
                        authStatus = await service.authorizationStatus()
                    }
                }

            case .authorized:
                Text("Permission Granted")
                    .foregroundColor(.green)

            case .denied, .restricted:
                Text("Permission Denied")
                    .foregroundColor(.red)
                Text("Please enable in Settings")
                    .font(.caption)

            @unknown default:
                Text("Unknown status")
            }
        }
        .task {
            authStatus = await service.authorizationStatus()
        }
    }
}
```

### Indexed Contact List

```swift
struct IndexedContactList: View {
    @StateObject private var viewModel = LWContactViewModel()

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.sortedSectionKeys, id: \.self) { key in
                    Section(header: Text(key).id(key)) {
                        ForEach(viewModel.groupedContacts[key] ?? []) { contact in
                            ContactRow(contact: contact)
                        }
                    }
                }
            }
            .overlay(alignment: .trailing) {
                IndexView(keys: viewModel.sortedSectionKeys) { key in
                    withAnimation {
                        proxy.scrollTo(key, anchor: .top)
                    }
                }
            }
        }
    }
}

struct IndexView: View {
    let keys: [String]
    let onTap: (String) -> Void

    var body: some View {
        VStack(spacing: 2) {
            ForEach(keys, id: \.self) { key in
                Text(key)
                    .font(.caption2)
                    .onTapGesture {
                        onTap(key)
                    }
            }
        }
        .padding(.trailing, 4)
    }
}
```

## API Reference

### LWContactModel

```swift
struct LWContactModel: Identifiable, Codable {
    let id: String
    let fullName: String
    let givenName: String?
    let familyName: String?
    let phoneNumber: String?
    let emailAddress: String?
    let organizationName: String?
    let thumbnailImage: Data?

    var displayName: String { get }
    var initials: String { get }
}
```

### LWContactService

```swift
class LWContactService {
    static let shared: LWContactService

    func authorizationStatus() async -> CNAuthorizationStatus
    func requestAccess() async -> Bool
    func fetchAllContacts() async -> [LWContactModel]
    func fetchContact(identifier: String) async -> LWContactModel?
    func searchContacts(query: String) async -> [LWContactModel]
    func createContact(_ contact: LWContactModel) async -> Bool
    func updateContact(_ contact: LWContactModel) async -> Bool
    func deleteContact(identifier: String) async -> Bool
}
```

### LWContactViewModel

```swift
class LWContactViewModel: ObservableObject {
    @Published var contacts: [LWContactModel] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    var filteredContacts: [LWContactModel] { get }
    var groupedContacts: [String: [LWContactModel]] { get }
    var sortedSectionKeys: [String] { get }

    func loadContacts() async
    func refresh() async
    func search(_ query: String)
}
```

### PinyinHelper

```swift
enum PinyinHelper {
    static func getPinyin(of text: String) -> String
    static func getFirstLetter(of text: String) -> String
    static func getPinyinInitials(of text: String) -> String
    static func matches(text: String, query: String) -> Bool
}
```

### LWContactPickerView

```swift
struct LWContactPickerView: View {
    @Binding var selectedContact: LWContactModel?
    var allowsMultipleSelection: Bool = false
    var onDismiss: (() -> Void)?

    init(
        selectedContact: Binding<LWContactModel?>,
        allowsMultipleSelection: Bool = false,
        onDismiss: (() -> Void)? = nil
    )
}
```

## Best Practices

### 1. Handle Permissions Properly

```swift
// Always check permission before accessing contacts
func loadContacts() async {
    let status = await service.authorizationStatus()

    switch status {
    case .authorized:
        contacts = await service.fetchAllContacts()

    case .notDetermined:
        if await service.requestAccess() {
            contacts = await service.fetchAllContacts()
        }

    case .denied, .restricted:
        showPermissionDeniedAlert = true

    @unknown default:
        break
    }
}
```

### 2. Use Async/Await for Contact Operations

```swift
// Good - Using async/await
Task {
    let contacts = await service.fetchAllContacts()
    updateUI(with: contacts)
}

// Avoid - Blocking main thread
let contacts = service.fetchAllContactsSync()  // Don't do this
```

### 3. Implement Efficient Search

```swift
// Use debouncing for search
import Combine

class SearchableViewModel: ObservableObject {
    @Published var searchText = ""
    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] query in
                Task {
                    await self?.performSearch(query)
                }
            }
            .store(in: &cancellables)
    }

    func performSearch(_ query: String) async {
        // Perform search
    }
}
```

### 4. Cache Contact Images

```swift
// Cache thumbnail images
actor ImageCache {
    private var cache: [String: UIImage] = [:]

    func image(for contactId: String) -> UIImage? {
        cache[contactId]
    }

    func store(_ image: UIImage, for contactId: String) {
        cache[contactId] = image
    }
}
```

## Migration from Objective-C Version

### Before (Objective-C)
```objective-c
LWContactManager *manager = [LWContactManager sharedManager];
[manager requestAccessWithCompletion:^(BOOL granted) {
    if (granted) {
        NSArray *contacts = [manager fetchAllContacts];
        // Use contacts
    }
}];
```

### After (Swift)
```swift
let service = LWContactService.shared

Task {
    if await service.requestAccess() {
        let contacts = await service.fetchAllContacts()
        // Use contacts
    }
}
```

## Privacy Considerations

### Info.plist Configuration

Add the following to your `Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts to help you connect with friends</string>
```

### Permission Best Practices

1. **Request permission at the right time** - Don't ask immediately on app launch
2. **Explain why you need access** - Provide context before requesting
3. **Handle denial gracefully** - Offer alternative workflows
4. **Respect user privacy** - Only access contacts when necessary

## Troubleshooting

**Q: Contacts not loading**
- Verify NSContactsUsageDescription is in Info.plist
- Check authorization status
- Ensure you're using async/await properly

**Q: Pinyin search not working**
- PinyinHelper requires Chinese locale support
- Verify text encoding is correct
- Test with simplified Chinese characters

**Q: UI not updating after contact changes**
- Make sure you're using @Published properties
- Check that updates are on MainActor
- Verify view model is declared with @StateObject

**Q: Performance issues with large contact lists**
- Implement pagination or lazy loading
- Use List instead of ScrollView + ForEach
- Consider caching frequently accessed data

## Examples

Check the `Swift/ExampleUsage.swift` file for complete working examples including:

- Basic contact fetching
- SwiftUI picker implementation
- Search and filtering
- Permission handling
- Contact grouping

## License

LWContactManager_swift is available under the MIT license. See the LICENSE file for more information.

## Author

**luowei**
- Email: luowei@wodedata.com
- GitHub: [@luowei](https://github.com/luowei)
