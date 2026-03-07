//  ContactPickerView.swift
//  TalkSwitch
//
//  CNContactPickerViewController presented from an embedded UIViewController
//  so its internal dismiss() never bubbles up into SwiftUI's sheet stack.

import SwiftUI
import Contacts
import ContactsUI

struct ContactPickerPresenter: UIViewControllerRepresentable {
    @Binding var phoneNumber: String
    @Binding var shouldPresent: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.host
    }

    func updateUIViewController(_ vc: UIViewController, context: Context) {
        guard shouldPresent, context.coordinator.picker == nil else { return }
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        context.coordinator.picker = picker
        DispatchQueue.main.async {
            context.coordinator.host.present(picker, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerPresenter
        let host = UIViewController()
        var picker: CNContactPickerViewController?

        init(_ parent: ContactPickerPresenter) { self.parent = parent }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            self.picker = nil
            DispatchQueue.main.async { self.parent.shouldPresent = false }
        }

        func contactPicker(_ picker: CNContactPickerViewController,
                           didSelect contact: CNContact) {
            if let phone = contact.phoneNumbers.first?.value.stringValue {
                let digits = phone.filter { $0.isNumber }
                DispatchQueue.main.async { self.parent.phoneNumber = digits }
            }
            self.picker = nil
            DispatchQueue.main.async { self.parent.shouldPresent = false }
        }
    }
}
