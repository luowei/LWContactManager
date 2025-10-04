//
// LWContactService.swift
// LWContactManager
//
// Created by Swift Migration on 2025/10/03.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import Contacts

/// Service for managing contacts access and retrieval
public class LWContactService {

    private let contactStore = CNContactStore()
    private let primaryLanguage: String

    /// Initialize with optional primary language
    /// - Parameter primaryLanguage: The primary language for sorting (e.g., "zh" for Chinese, "en" for English)
    public init(primaryLanguage: String? = nil) {
        if let language = primaryLanguage, !language.isEmpty {
            self.primaryLanguage = language
        } else {
            self.primaryLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        }
    }

    /// Request access to contacts
    /// - Returns: True if access is granted, false otherwise
    /// - Throws: Error if access request fails
    @available(iOS 13.0, *)
    public func requestAccess() async throws -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return try await contactStore.requestAccess(for: .contacts)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    /// Request access to contacts (callback-based for iOS 12 compatibility)
    /// - Parameter completion: Completion handler with granted status and optional error
    public func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized:
            completion(true, nil)
        case .notDetermined:
            contactStore.requestAccess(for: .contacts, completionHandler: completion)
        case .denied, .restricted:
            completion(false, nil)
        @unknown default:
            completion(false, nil)
        }
    }

    /// Load contacts with optional search text filtering
    /// - Parameter searchText: Optional search text to filter contacts
    /// - Returns: Array of contacts
    /// - Throws: Error if fetching contacts fails
    @available(iOS 13.0, *)
    public func loadContacts(searchText: String? = nil) async throws -> [LWContact] {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        guard status == .authorized else {
            _ = try await requestAccess()
            return []
        }

        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]

        var contacts: [LWContact] = []
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        try contactStore.enumerateContacts(with: request) { cnContact, _ in
            if let contact = cnContact.toLWContact() {
                if self.matchesSearchCriteria(contact: contact, searchText: searchText) {
                    contacts.append(contact)
                }
            }
        }

        return sortContacts(contacts)
    }

    /// Load contacts with optional search text filtering (callback-based)
    /// - Parameters:
    ///   - searchText: Optional search text to filter contacts
    ///   - completion: Completion handler with contacts array and optional error
    public func loadContacts(searchText: String? = nil, completion: @escaping ([LWContact], Error?) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        guard status == .authorized else {
            requestAccess { granted, error in
                if granted {
                    self.loadContacts(searchText: searchText, completion: completion)
                } else {
                    completion([], error)
                }
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let keysToFetch: [CNKeyDescriptor] = [
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactThumbnailImageDataKey as CNKeyDescriptor
                ]

                var contacts: [LWContact] = []
                let request = CNContactFetchRequest(keysToFetch: keysToFetch)

                try self.contactStore.enumerateContacts(with: request) { cnContact, _ in
                    if let contact = cnContact.toLWContact() {
                        if self.matchesSearchCriteria(contact: contact, searchText: searchText) {
                            contacts.append(contact)
                        }
                    }
                }

                let sortedContacts = self.sortContacts(contacts)
                DispatchQueue.main.async {
                    completion(sortedContacts, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }

    // MARK: - Private Helpers

    /// Check if a contact matches the search criteria
    private func matchesSearchCriteria(contact: LWContact, searchText: String?) -> Bool {
        guard let searchText = searchText, !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }

        let name = contact.fullName.lowercased()
        let search = searchText.lowercased()

        // Check name
        if name.contains(search) {
            return true
        }

        // Check phone numbers
        for phone in contact.phoneNumbers {
            if phone.number.contains(search) {
                return true
            }
        }

        return false
    }

    /// Sort contacts based on primary language
    private func sortContacts(_ contacts: [LWContact]) -> [LWContact] {
        if primaryLanguage.hasPrefix("zh") {
            // Chinese sorting using pinyin
            return contacts.sorted { contact1, contact2 in
                let name1 = contact1.firstName.isEmpty ? contact1.lastName : contact1.firstName
                let name2 = contact2.firstName.isEmpty ? contact2.lastName : contact2.firstName

                if name1.isEmpty || name2.isEmpty {
                    return name1.isEmpty && !name2.isEmpty
                }

                let pinyin1 = String(PinyinHelper.pinyinFirstLetter(for: name1)).uppercased()
                let pinyin2 = String(PinyinHelper.pinyinFirstLetter(for: name2)).uppercased()

                return pinyin1 < pinyin2
            }
        } else {
            // English/default sorting
            return contacts.sorted { contact1, contact2 in
                let name1 = contact1.firstName.isEmpty ? contact1.lastName : contact1.firstName
                let name2 = contact2.firstName.isEmpty ? contact2.lastName : contact2.firstName
                return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
            }
        }
    }
}
