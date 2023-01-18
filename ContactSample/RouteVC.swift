//
//  RouteVC.swift
//  ContactSample
//
//  Created by jefferson.setiawan on 29/11/22.
//

import UIKit

class RouteVC: UIViewController {
    private let cnContactPickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open CNContactPicker", for: .normal)
        return button
    }()
    private let cnStoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open CNStore", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [cnContactPickerButton, cnStoreButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        cnContactPickerButton.addTarget(self, action: #selector(openPickerVC), for: .touchUpInside)
        cnStoreButton.addTarget(self, action: #selector(openContactStoreVC), for: .touchUpInside)
    }
    
    @objc private func openPickerVC() {
        self.navigationController?.pushViewController(ContactFromPickerVC(), animated: true)
    }
    
    @objc private func openContactStoreVC() {
        self.navigationController?.pushViewController(ContactFromContactStoreVC(), animated: true)
    }
}

import ContactsUI

class ContactFromPickerVC: UIViewController, CNContactPickerDelegate {
    private let openPickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Contact", for: .normal)
        return button
    }()
    private let phoneTextField = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [phoneTextField, openPickerButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        openPickerButton.addTarget(self, action: #selector(openContact), for: .touchUpInside)
    }
    
    @objc func openContact() {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        contactPickerViewController.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        
        present(contactPickerViewController, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        guard let phoneNumber = contactProperty.value as? CNPhoneNumber else { return }

        var contactNumber = phoneNumber.stringValue.replacingOccurrences(of: "-", with: "")
        contactNumber = contactNumber.replacingOccurrences(of: "(", with: "")
        contactNumber = contactNumber.replacingOccurrences(of: ")", with: "")
        contactNumber = contactNumber.replacingOccurrences(of: " ", with: "")
        
        phoneTextField.text = contactNumber
    }
}

class ContactFromContactStoreVC: UIViewController {
    private let openPickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Contact", for: .normal)
        return button
    }()
    private let logLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [logLabel, openPickerButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        openPickerButton.addTarget(self, action: #selector(openContact), for: .touchUpInside)
    }
    
    @objc func openContact() {
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { [logLabel] granted, err in
            if let err = err {
                logLabel.text = String(describing: err)
                return
            }
            guard granted else {
                logLabel.text = "Not granted!"
                return
            }
            let keys = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey
            ]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    var contactTotal = 0
                    var firstContact: String? = nil
                    
                    try contactStore.enumerateContacts(with: request) { contact, _ in
                        contactTotal += 1
                        for number in contact.phoneNumbers {
                            let phoneNumber = number.value.stringValue
                            if firstContact == nil {
                                firstContact = phoneNumber
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        logLabel.text = "Found: \(contactTotal), first: \(firstContact)"
                    }
                } catch {
                    DispatchQueue.main.async {
                        logLabel.text = String(describing: err)
                    }
                }
            }
        }
    }
}
