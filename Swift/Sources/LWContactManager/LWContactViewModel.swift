//
// LWContactViewModel.swift
// LWContactManager
//
// Created by Swift Migration on 2025/10/03.
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for managing contact selection in SwiftUI
@available(iOS 13.0, *)
@MainActor
public class LWContactViewModel: ObservableObject {

    @Published public private(set) var contacts: [LWContact] = []
    @Published public var searchText: String = ""
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var authorizationStatus: AuthorizationStatus = .notDetermined

    private let service: LWContactService
    private var cancellables = Set<AnyCancellable>()

    public enum AuthorizationStatus {
        case notDetermined
        case authorized
        case denied
    }

    public init(primaryLanguage: String? = nil) {
        self.service = LWContactService(primaryLanguage: primaryLanguage)

        // Setup search debouncing
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.loadContacts()
                }
            }
            .store(in: &cancellables)
    }

    /// Request contacts access authorization
    @available(iOS 13.0, *)
    public func requestAccess() async {
        isLoading = true
        errorMessage = nil

        do {
            let granted = try await service.requestAccess()
            authorizationStatus = granted ? .authorized : .denied

            if granted {
                await loadContacts()
            } else {
                errorMessage = "Contacts access denied. Please enable in Settings."
            }
        } catch {
            errorMessage = "Failed to request access: \(error.localizedDescription)"
            authorizationStatus = .denied
        }

        isLoading = false
    }

    /// Load contacts with current search text
    @available(iOS 13.0, *)
    public func loadContacts() async {
        isLoading = true
        errorMessage = nil

        do {
            let searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            contacts = try await service.loadContacts(searchText: searchQuery.isEmpty ? nil : searchQuery)
        } catch {
            errorMessage = "Failed to load contacts: \(error.localizedDescription)"
            contacts = []
        }

        isLoading = false
    }

    /// Refresh contacts
    @available(iOS 13.0, *)
    public func refresh() async {
        await loadContacts()
    }
}
