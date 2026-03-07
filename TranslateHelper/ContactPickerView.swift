//  ContactPickerView.swift
//  TalkSwitch

import SwiftUI
import Contacts
import ContactsUI

/// Wraps CNContactPickerViewController so the user can pick a contact
/// from their address book. No contacts permission required — the system
/// picker handles privacy internally.
struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var phoneNumber: String
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return picker
    }

    func updateUIViewController(_ vc: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerView
        init(_ parent: ContactPickerView) { self.parent = parent }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.isPresented = false
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            if let phone = contact.phoneNumbers.first?.value.stringValue {
                // Strip everything that isn't a digit
                let digits = phone.filter { $0.isNumber }
                parent.phoneNumber = digits
            }
            parent.isPresented = false
        }
    }
}
