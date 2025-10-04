//
// ExampleUsage.swift
// LWContactManager Examples
//
// This file demonstrates how to use LWContactManager in your Swift/SwiftUI projects
//

import SwiftUI
import LWContactManager

// MARK: - Example 1: Using the Service with Async/Await (iOS 13+)

@available(iOS 13.0, *)
class ContactsViewController {

    let service = LWContactService()

    func loadContacts() async {
        do {
            // Request access
            let granted = try await service.requestAccess()
            guard granted else {
                print("Access denied")
                return
            }

            // Load all contacts
            let contacts = try await service.loadContacts()
            print("Loaded \(contacts.count) contacts")

            // Load contacts with search
            let searchResults = try await service.loadContacts(searchText: "John")
            print("Found \(searchResults.count) contacts matching 'John'")

        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: - Example 2: Using the Service with Callbacks (iOS 12+)

class LegacyContactsViewController {

    let service = LWContactService()

    func loadContacts() {
        // Request access
        service.requestAccess { granted, error in
            guard granted else {
                print("Access denied: \(error?.localizedDescription ?? "unknown")")
                return
            }

            // Load all contacts
            self.service.loadContacts { contacts, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }

                print("Loaded \(contacts.count) contacts")
            }
        }
    }

    func searchContacts(query: String) {
        service.loadContacts(searchText: query) { contacts, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            print("Found \(contacts.count) contacts")
        }
    }
}

// MARK: - Example 3: Using SwiftUI ViewModel (iOS 13+)

@available(iOS 13.0, *)
struct ContactListView: View {

    @StateObject private var viewModel = LWContactViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.contacts) { contact in
                VStack(alignment: .leading) {
                    Text(contact.displayName)
                        .font(.headline)
                    if let phone = contact.phoneNumbers.first {
                        Text(phone.number)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $viewModel.searchText)
            .task {
                await viewModel.requestAccess()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

// MARK: - Example 4: Using SwiftUI Contact Picker (iOS 14+)

@available(iOS 14.0, *)
struct MyView: View {

    @State private var showingPicker = false
    @State private var selectedContact: LWContact?

    var body: some View {
        VStack {
            if let contact = selectedContact {
                Text("Selected: \(contact.displayName)")
                if let phone = contact.phoneNumbers.first {
                    Text(phone.number)
                        .foregroundColor(.secondary)
                }
            }

            Button("Pick Contact") {
                showingPicker = true
            }
        }
        .sheet(isPresented: $showingPicker) {
            LWContactPickerView { contact in
                selectedContact = contact
            }
        }
    }
}

// MARK: - Example 5: Chinese Language Sorting

@available(iOS 13.0, *)
class ChineseContactsViewController {

    // Explicitly set Chinese for sorting
    let service = LWContactService(primaryLanguage: "zh")

    func loadChineseContacts() async {
        do {
            let granted = try await service.requestAccess()
            guard granted else { return }

            // Contacts will be sorted by pinyin
            let contacts = try await service.loadContacts()
            print("Loaded \(contacts.count) contacts (sorted by pinyin)")

        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: - Example 6: Accessing Contact Details

func printContactDetails(contact: LWContact) {
    print("ID: \(contact.id)")
    print("Name: \(contact.displayName)")
    print("First Name: \(contact.firstName)")
    print("Last Name: \(contact.lastName)")

    print("Phone Numbers:")
    for phone in contact.phoneNumbers {
        print("  - \(phone.number) (\(phone.label ?? "unlabeled"))")
    }

    if let imageData = contact.thumbnailImageData {
        print("Has thumbnail image: \(imageData.count) bytes")
    }
}

// MARK: - Example 7: Custom Contact Filtering

@available(iOS 13.0, *)
class CustomFilterViewController {

    let service = LWContactService()

    func loadContactsWithAreaCode(_ areaCode: String) async {
        do {
            let allContacts = try await service.loadContacts()

            // Filter contacts with specific area code
            let filtered = allContacts.filter { contact in
                contact.phoneNumbers.contains { phone in
                    phone.number.hasPrefix(areaCode)
                }
            }

            print("Found \(filtered.count) contacts with area code \(areaCode)")

        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: - Example 8: Using Pinyin Helper Directly

func demonstratePinyinHelper() {
    let chineseText = "张三"

    // Get first letter of first character
    let firstLetter = PinyinHelper.pinyinFirstLetter(for: chineseText)
    print("First letter: \(firstLetter)") // Output: Z

    // Get first letter of a specific character
    if let firstChar = chineseText.first {
        let letter = PinyinHelper.pinyinFirstLetter(for: firstChar)
        print("Letter: \(letter)") // Output: Z
    }
}
