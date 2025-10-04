# Migration Guide: Objective-C to Swift

This guide helps you migrate from the Objective-C version of LWContactManager to the Swift version.

## Key Differences

### 1. Framework Changes

**Objective-C Version:**
- Uses APAddressBook (third-party dependency)
- Uses deprecated AddressBook framework

**Swift Version:**
- Uses native Contacts framework (iOS 9+)
- No external dependencies
- Modern async/await support

### 2. API Comparison

#### Initialization

**Objective-C:**
```objc
LWAddressBookService *service = [LWAddressBookService serviceWithPrimaryLanguage:@"zh"];
```

**Swift:**
```swift
let service = LWContactService(primaryLanguage: "zh")
```

#### Request Access

**Objective-C:**
```objc
[service requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        // Access granted
    }
}];
```

**Swift (Callback):**
```swift
service.requestAccess { granted, error in
    if granted {
        // Access granted
    }
}
```

**Swift (Async/Await - Recommended):**
```swift
let granted = try await service.requestAccess()
if granted {
    // Access granted
}
```

#### Load Contacts

**Objective-C:**
```objc
[service loadContactsWithSearchText:@"John"
                       successBlock:^(NSArray<APContact *> *contacts, NSError *error) {
    // Handle contacts
}];
```

**Swift (Callback):**
```swift
service.loadContacts(searchText: "John") { contacts, error in
    // Handle contacts
}
```

**Swift (Async/Await - Recommended):**
```swift
let contacts = try await service.loadContacts(searchText: "John")
// Handle contacts
```

### 3. Model Mapping

| Objective-C (APContact) | Swift (LWContact) |
|------------------------|-------------------|
| `contact.name.firstName` | `contact.firstName` |
| `contact.name.lastName` | `contact.lastName` |
| `contact.phones` | `contact.phoneNumbers` |
| `contact.thumbnail` | `contact.thumbnailImageData` |
| `contact.recordID` | `contact.id` |

### 4. Phone Number Access

**Objective-C:**
```objc
APPhone *phone = contact.phones[0];
NSString *number = phone.number;
```

**Swift:**
```swift
let phone = contact.phoneNumbers[0]
let number = phone.number
```

### 5. SwiftUI Support

The Swift version includes built-in SwiftUI components:

```swift
// Show contact picker
LWContactPickerView { contact in
    print("Selected: \(contact.displayName)")
}

// Use ViewModel for custom views
@StateObject private var viewModel = LWContactViewModel()
```

### 6. Pinyin Sorting

Both versions support Chinese pinyin sorting, but the implementation differs:

**Objective-C:**
```objc
// Automatically handled by LWAddressBookService
// Uses C function: pinyinFirstLetter()
```

**Swift:**
```swift
// Automatically handled by LWContactService
// Can also use PinyinHelper directly:
let firstLetter = PinyinHelper.pinyinFirstLetter(for: "张")
```

## Migration Steps

### Step 1: Update Dependencies

**Remove from Podfile:**
```ruby
pod 'LWContactManager'
pod 'APAddressBook'
```

**Add to Podfile:**
```ruby
pod 'LWContactManagerSwift'
```

Or use Swift Package Manager:
```swift
dependencies: [
    .package(url: "https://github.com/luowei/LWContactManager.git", from: "1.0.0")
]
```

### Step 2: Update Info.plist

Both versions require the same privacy description:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to contacts to...</string>
```

### Step 3: Replace Service Class

Replace `LWAddressBookService` with `LWContactService` in your code.

### Step 4: Update Model Usage

Replace `APContact` with `LWContact` and update property access.

### Step 5: Modernize with Async/Await (Recommended)

If targeting iOS 13+, consider using async/await for cleaner code:

**Before (Objective-C):**
```objc
[service requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        [service loadContactsWithSearchText:nil successBlock:^(NSArray *contacts, NSError *error) {
            // Use contacts
        }];
    }
}];
```

**After (Swift with async/await):**
```swift
Task {
    let granted = try await service.requestAccess()
    if granted {
        let contacts = try await service.loadContacts()
        // Use contacts
    }
}
```

## Feature Parity

| Feature | Objective-C | Swift |
|---------|-------------|-------|
| Request Access | ✅ | ✅ |
| Load Contacts | ✅ | ✅ |
| Search/Filter | ✅ | ✅ |
| Chinese Pinyin Sort | ✅ | ✅ |
| Phone Numbers Only | ✅ | ✅ |
| Thumbnails | ✅ | ✅ |
| Async/Await | ❌ | ✅ |
| SwiftUI Support | ❌ | ✅ |
| Combine Support | ❌ | ✅ |
| No External Deps | ❌ | ✅ |

## Common Issues

### Issue 1: Different Contact Properties

**Problem:** `APContact` has nested `name` property, `LWContact` has flat structure.

**Solution:** Update property access:
```swift
// Old: contact.name.firstName
// New: contact.firstName
```

### Issue 2: Callbacks vs Async/Await

**Problem:** Mixing callback and async/await patterns.

**Solution:** Choose one pattern consistently. Async/await is recommended for iOS 13+.

### Issue 3: SwiftUI Integration

**Problem:** Need to integrate with SwiftUI.

**Solution:** Use provided `LWContactViewModel` and `LWContactPickerView`:
```swift
@StateObject private var viewModel = LWContactViewModel()
```

## Benefits of Swift Version

1. **No External Dependencies** - Uses native iOS frameworks
2. **Modern Swift** - Async/await, Combine, SwiftUI support
3. **Type Safety** - Strongly typed Swift models
4. **Better Performance** - Direct Contacts framework access
5. **Future-Proof** - Uses non-deprecated APIs
6. **Easier Maintenance** - Pure Swift codebase

## Support

For issues or questions:
- GitHub Issues: https://github.com/luowei/LWContactManager/issues
- Email: luowei@wodedata.com
