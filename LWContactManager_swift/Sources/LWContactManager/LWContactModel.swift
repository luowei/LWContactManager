//
// LWContactModel.swift
// LWContactManager
//
// Created by Swift Migration on 2025/10/03.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import Contacts

/// Represents a simplified contact model
public struct LWContact: Identifiable, Hashable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let phoneNumbers: [LWPhoneNumber]
    public let thumbnailImageData: Data?

    public var fullName: String {
        "\(lastName) \(firstName)".trimmingCharacters(in: .whitespaces)
    }

    public var displayName: String {
        fullName.isEmpty ? "Unknown" : fullName
    }

    public init(id: String, firstName: String, lastName: String, phoneNumbers: [LWPhoneNumber], thumbnailImageData: Data?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumbers = phoneNumbers
        self.thumbnailImageData = thumbnailImageData
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: LWContact, rhs: LWContact) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents a phone number
public struct LWPhoneNumber: Identifiable, Hashable {
    public let id = UUID()
    public let number: String
    public let label: String?

    public init(number: String, label: String? = nil) {
        self.number = number
        self.label = label
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CNContact Extension
extension CNContact {
    func toLWContact() -> LWContact? {
        guard !phoneNumbers.isEmpty else { return nil }

        let phones = phoneNumbers.map { phoneNumber in
            LWPhoneNumber(
                number: phoneNumber.value.stringValue,
                label: phoneNumber.label.flatMap { CNLabeledValue<NSString>.localizedString(forLabel: $0) }
            )
        }

        return LWContact(
            id: identifier,
            firstName: givenName,
            lastName: familyName,
            phoneNumbers: phones,
            thumbnailImageData: thumbnailImageData
        )
    }
}
