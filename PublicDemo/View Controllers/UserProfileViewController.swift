//
//  UserProfileViewController.swift
//  WebEngageExampleSwift
//
//  Created by Yogesh Singh on 30/10/18.
//  Copyright © 2018 Yogesh Singh. All rights reserved.
//

import UIKit
import WebEngage

class UserProfileViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var hashedEmailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var hashedPhoneField: UITextField!
    @IBOutlet weak var companyField: UITextField!
    @IBOutlet weak var birthDateField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var locationField: UITextField!

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func logoutTapped(_ sender: UIButton) {

        WebEngage.sharedInstance()?.user.logout()
        UserDefaults.standard.removeObject(forKey: Constants.loginID)

        let alert = UIAlertController(title: "User Logout Successful ✅", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cool", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Regular Attributes Handlers
extension UserProfileViewController {

    @IBAction func saveTapped(_ sender: UIButton) {

        if !(firstNameField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setFirstName(firstNameField.text)
        }

        if !(lastNameField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setLastName(lastNameField.text)
        }

        if !(emailField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setEmail(emailField.text)
        }

        if !(hashedEmailField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setHashedEmail(hashedEmailField.text)
        }

        if !(phoneField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setPhone(phoneField.text)
        }

        if !(hashedPhoneField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setHashedPhone(hashedPhoneField.text)
        }

        if !(companyField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setCompany(companyField.text)
        }

        if !(birthDateField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setBirthDateString(birthDateField.text)
        }

        if !(genderField.text?.isEmpty)! {
            WebEngage.sharedInstance()?.user.setGender(genderField.text)
        }

        if !(locationField.text?.isEmpty)! {

            guard let locationArray = locationField.text?.split(separator: ",").map({ String($0) }),
                locationArray.count == 2,
                let lat = Int(locationArray[0]),
                let long = Int(locationArray[1]) else {

                let alert = UIAlertController.init(title: "Incorrect Location format", message: "Enter location as \"19,72\"", preferredStyle: .alert)

                    alert.addAction(UIAlertAction.init(title: "Got It", style: .default, handler: { (_) in
                        self.locationField.becomeFirstResponder()
                    }))

                self.present(alert, animated: true, completion: nil)

                return
            }

            WebEngage.sharedInstance()?.user.setUserLocationWithLatitude(NSNumber(value: lat), andLongitude: NSNumber(value: long))
        }

        let alert = UIAlertController.init(title: "User Profile Updated!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Okay", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Opt-In Channels Handlers
extension UserProfileViewController {

    @IBAction func pushOptInChanged(_ sender: UISwitch) {
        WebEngage.sharedInstance()?.user.setOptInStatusFor(.push, status: sender.isOn)
    }

    @IBAction func inAppOptInChanged(_ sender: UISwitch) {
        WebEngage.sharedInstance()?.user.setOptInStatusFor(.inApp, status: sender.isOn)
    }

    @IBAction func smsOptInChanged(_ sender: UISwitch) {
        WebEngage.sharedInstance()?.user.setOptInStatusFor(.SMS, status: sender.isOn)
    }

    @IBAction func emailOptInChanged(_ sender: UISwitch) {
        WebEngage.sharedInstance()?.user.setOptInStatusFor(.email, status: sender.isOn)
    }
}

// MARK: - Delete Custom Attributes Handlers
extension UserProfileViewController {

    @IBAction func deleteCustomTapped(_ sender: UIButton) {

        let alert = UIAlertController.init(title: "Delete Custom Attribute", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction.init(title: "Delete Single Key", style: .default, handler: { (_) in
            self.presentDeleteAlert(for: "Single")
        }))

        alert.addAction(UIAlertAction.init(title: "Delete Multiple Keys", style: .default, handler: { (_) in
            self.presentDeleteAlert(for: "Multiple")
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func presentDeleteAlert(for type: String) {

        let alert = UIAlertController.init(title: "Enter \(type) key" + (type == "Single" ? "":"s") + " to be deleted", message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in

            textField.placeholder = "Enter key" + (type == "Single" ? "":"s") + " to be deleted"

            if type == "Multiple" {
                textField.text = "[\"key1\",\"key2\",\"key3\"]"
            }
        }

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler: { (_) in

            guard let text = alert.textFields![0].text, !text.isEmpty else {
                self.showDeleteFailureAlert(for: alert.textFields![0].text ?? "nil")
                return
            }

            print("Key to be deleted: \(text)")

            switch type {
            case "Single":
                WebEngage.sharedInstance()?.user.deleteAttribute(text)
                self.showDeleteSuccessAlert(for: text)

            case "Multiple":
                guard let data = text.data(using: String.Encoding.utf8) else {
                    self.showDeleteFailureAlert(for: text)
                    return
                }

                do {

                    if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                        WebEngage.sharedInstance()?.user.deleteAttributes(array)
                        self.showDeleteSuccessAlert(for: text)
                    } else {
                        self.showDeleteFailureAlert(for: text)
                    }

                } catch let error as NSError {
                    print(error)
                    self.showDeleteFailureAlert(for: text)
                }

            default:
                print("Exception! Should not reach default state")
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }

    private func showDeleteFailureAlert(for key: String) {

        let alert = UIAlertController.init(title: "Key Deletion Failed ❌", message: "Entered key: \"\(key)\"", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Damn!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showDeleteSuccessAlert(for key: String) {

        let alert = UIAlertController.init(title: "Key Deletion Success ✅", message: "Deleted key: \"\(key)\"", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Cool", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Add Custom Attributes Handlers
extension UserProfileViewController {

    @IBAction func addCustomTapped(_ sender: UIButton) {

        let alert = UIAlertController.init(title: "Select Attribute Type", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction.init(title: "String Value", style: .default, handler: { (_) in
            self.presentAlert(for: "String")
        }))

        alert.addAction(UIAlertAction.init(title: "Boolean Value", style: .default, handler: { (_) in
            self.presentAlert(for: "Boolean")
        }))

        alert.addAction(UIAlertAction.init(title: "Date Value", style: .default, handler: { (_) in
            self.presentAlert(for: "Date")
        }))

        alert.addAction(UIAlertAction.init(title: "Array Value", style: .default, handler: { (_) in
            self.presentAlert(for: "Array")
        }))

        alert.addAction(UIAlertAction.init(title: "Dictionary Value", style: .default, handler: { (_) in
            self.presentAlert(for: "Dictionary")
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func presentAlert(for type: String) {

        let alert = UIAlertController.init(title: "Add \(type) Attribute", message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Key"
            textField.becomeFirstResponder()
        }

        var valuePlaceholder = ""
        var text: String?
        var keyboardType: UIKeyboardType = .default

        switch type {
        case "String":
            valuePlaceholder = "Enter String value"

        case "Boolean":
            valuePlaceholder = "Enter 1(true) or 0(false)"
            keyboardType = .phonePad

        case "Date":
            valuePlaceholder = "Enter Date"

        case "Array":
            valuePlaceholder = "Enter Array value"
            text = "[\"value 1\",\"value 2\", \"value 3\"]"

        case "Dictionary":
            valuePlaceholder = "Enter Dictionary value"
            text = "{\"key1\": \"value1\", \"key2\": \"value2\"}"

        default:
            print("Incorrect switch type")
        }

        alert.addTextField { (textField) in

            textField.placeholder = valuePlaceholder
            textField.keyboardType = keyboardType
            textField.text = text

            if type == "Date" {
                let (toolBar, picker) = self.getDatePicker(for: textField)
                textField.inputAccessoryView = toolBar
                textField.inputView = picker
            }
        }

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction.init(title: "ADD", style: .default, handler: { (_) in

            let key = alert.textFields![0].text
            let value = alert.textFields![1].text

            guard (key != nil), (value != nil), !(key?.isEmpty)!, !(value?.isEmpty)! else {

                self.showFailAlert(key: key, value: value)
                return
            }

            switch type {

            case "String":
                WebEngage.sharedInstance()?.user.setAttribute(key, withStringValue: value)
                self.showSuccessAlert(key: key!, value: value!)

            case "Boolean":
                WebEngage.sharedInstance()?.user.setAttribute(key, withValue: NSNumber(value: Int(value ?? "-1") ?? -1))
                self.showSuccessAlert(key: key!, value: value!)

            case "Date":

                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"

                guard let date = formatter.date(from: value!) else {
                    self.showFailAlert(key: key, value: value)
                    return
                }

                WebEngage.sharedInstance()?.user.setAttribute(key, withDateValue: date)
                self.showSuccessAlert(key: key!, value: value!)

            case "Array":

                guard let data = value!.data(using: String.Encoding.utf8) else {
                    self.showFailAlert(key: key, value: value)
                    return
                }

                do {
                    if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                        WebEngage.sharedInstance()?.user.setAttribute(key, withArrayValue: array)
                        self.showSuccessAlert(key: key!, value: value!)
                    } else {
                        self.showFailAlert(key: key, value: value)
                    }

                } catch let error as NSError {
                    print(error)
                    self.showFailAlert(key: key, value: value)
                }

            case "Dictionary":

                guard let data = value!.data(using: String.Encoding.utf8) else {
                    self.showFailAlert(key: key, value: value)
                    return
                }

                do {
                    if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                        WebEngage.sharedInstance()?.user.setAttribute(key, withDictionaryValue: dict)
                        self.showSuccessAlert(key: key!, value: value!)
                    } else {
                        self.showFailAlert(key: key, value: value)
                    }

                } catch let error as NSError {
                    print(error)
                    self.showFailAlert(key: key, value: value)
                }

            default:
                print("Nothing to do")
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }

    private func showSuccessAlert(key: String, value: String) {

        let alert = UIAlertController.init(title: "Attribute Added Successfully ✅",
                                           message: "Entered key: \(key) & value: \(value)", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Cool", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showFailAlert(key: String?, value: String?) {

        let failAlert = UIAlertController.init(title: "Attribute Key/Value format incorrect ❌",
                                               message: "Incorrect Entered key: \(key ?? "nil") & value: \(value ?? "nil")", preferredStyle: .alert)
        failAlert.addAction(UIAlertAction.init(title: "Damn!", style: .cancel, handler: nil))
        self.present(failAlert, animated: true, completion: nil)
    }

    private func getDatePicker(for textField: UITextField) -> (UIToolbar, UIDatePicker) {

        let picker = UIDatePicker.init()

        picker.datePickerMode = .date

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = CustomBarButton(title: "Done", style: .done, target: self, action: #selector(donePickerTapped(_:)))
        doneButton.textField = textField
        doneButton.picker = picker

        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)

        return (toolbar, picker)
    }

    @objc func donePickerTapped(_ sender: CustomBarButton) {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        sender.textField?.text = formatter.string(from: sender.picker!.date)
        self.view.endEditing(true)
    }

    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
}

class CustomBarButton: UIBarButtonItem {
    weak var textField: UITextField?
    weak var picker: UIDatePicker?
}
