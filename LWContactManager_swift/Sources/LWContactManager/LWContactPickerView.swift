//
// LWContactPickerView.swift
// LWContactManager
//
// Created by Swift Migration on 2025/10/03.
// Copyright (c) 2025 luowei. All rights reserved.
//

import SwiftUI

/// SwiftUI view for picking contacts
@available(iOS 14.0, *)
public struct LWContactPickerView: View {

    @StateObject private var viewModel: LWContactViewModel
    @Environment(\.dismiss) private var dismiss
    public var onContactSelected: (LWContact) -> Void

    public init(
        primaryLanguage: String? = nil,
        onContactSelected: @escaping (LWContact) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: LWContactViewModel(primaryLanguage: primaryLanguage))
        self.onContactSelected = onContactSelected
    }

    public var body: some View {
        NavigationView {
            ZStack {
                contactList
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Select Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search contacts")
            .task {
                await viewModel.requestAccess()
            }
        }
    }

    @ViewBuilder
    private var contactList: some View {
        if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Button("Retry") {
                    Task {
                        await viewModel.requestAccess()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        } else if viewModel.contacts.isEmpty && !viewModel.isLoading {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                Text(viewModel.searchText.isEmpty ? "No contacts found" : "No matching contacts")
                    .foregroundColor(.secondary)
            }
        } else {
            List(viewModel.contacts) { contact in
                ContactRow(contact: contact)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onContactSelected(contact)
                        dismiss()
                    }
            }
            .listStyle(.plain)
        }
    }
}

/// Row view for displaying a single contact
@available(iOS 14.0, *)
struct ContactRow: View {
    let contact: LWContact

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail or placeholder
            if let imageData = contact.thumbnailImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.displayName)
                    .font(.body)
                    .fontWeight(.medium)

                if let firstPhone = contact.phoneNumbers.first {
                    Text(firstPhone.number)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

@available(iOS 14.0, *)
struct LWContactPickerView_Previews: PreviewProvider {
    static var previews: some View {
        LWContactPickerView { contact in
            print("Selected: \(contact.displayName)")
        }
    }
}
