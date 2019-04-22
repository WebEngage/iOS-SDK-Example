//
//  ScreensViewController.swift
//  WebEngageExampleSwift
//
//  Created by Yogesh Singh on 02/11/18.
//  Copyright © 2018 Yogesh Singh. All rights reserved.
//

import UIKit
import WebEngage

class ScreensViewController: UIViewController {

    @IBOutlet weak var screenField: UITextField! {
        didSet {
            screenField.becomeFirstResponder()
        }
    }
    
    @IBOutlet weak var dataField: UITextField!
    
    @IBAction func doneTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setScreenNameTapped(_ sender: UIButton) {
        
        guard let text = screenField.text, !text.isEmpty else {
            self.showFailAlert(key: screenField.text, value: nil, type: "name")
            return
        }
        
        WebEngage.sharedInstance()?.analytics.navigatingToScreen(withName: text)
        self.showSuccessAlert(key: text, value: nil, type: "name")
    }
    
    
    @IBAction func setScreenDataTapped(_ sender: UIButton) {
        
        guard let text = dataField.text, !text.isEmpty else {
            self.showFailAlert(key: dataField.text, value: nil, type: "data")
            return
        }
        
        if let data = text.data(using: String.Encoding.utf8) {
            
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                    
                    WebEngage.sharedInstance()?.analytics.updateCurrentScreenData(dict)
                    self.showSuccessAlert(key: text, value: nil, type: "data")
                }
                else {
                    self.showFailAlert(key: text, value: nil, type: "data")
                }
                
            } catch let error as NSError {
                self.showFailAlert(key: text, value: nil, type: "data")
                print(error)
            }
            
        }
        else {
            self.showFailAlert(key: text, value: nil, type: "data")
        }
    }
    
    @IBAction func customAttributeTapped(_ sender: UIButton) {
        
        let alert = UIAlertController.init(title: "Set Custom Screen Event", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Screen Name"
            textField.becomeFirstResponder()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Screen Data"
            textField.text = "{\"key1\": \"value1\", \"key2\": \"value2\"}"
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Set", style: .default, handler: { (action) in
            
            let key = alert.textFields![0].text
            let value = alert.textFields![1].text
            
            guard (key != nil), (value != nil), !(key?.isEmpty)!, !(value?.isEmpty)! else {
                self.showFailAlert(key: key, value: value, type: "custom")
                return
            }
            
            if let data = value!.data(using: String.Encoding.utf8) {
                
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                        
                        WebEngage.sharedInstance()?.analytics.navigatingToScreen(withName: key!, andData: dict)

                        self.showSuccessAlert(key: key, value: value, type: "custom")
                    }
                    else {
                        self.showFailAlert(key: key, value: value, type: "custom")
                    }
                    
                } catch let error as NSError {
                    self.showFailAlert(key: key, value: value, type: "custom")
                    print(error)
                }
                
            }
            else {
                self.showFailAlert(key: key, value: value, type: "custom")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showFailAlert(key: String?, value: String?, type: String) {
        
        var message: String?
        switch type {
        case "name":
            message = "Entered  name: \(key ?? "nil")"
        case "data":
            message = "Entered data: \(key ?? "nil")"
        case "custom":
            message = "Entered name: \(key ?? "nil") data: \(value ?? "nil")"
            
        default:
            message = nil
        }
        
        let alert = UIAlertController.init(title: "Screen event Failed ❌", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Damn!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showSuccessAlert(key: String?, value: String?, type: String) {
        
        var message: String?
        switch type {
        case "name":
            message = "Entered  name: \(key ?? "nil")"
        case "data":
            message = "Entered data: \(key ?? "nil")"
        case "custom":
            message = "Entered name: \(key ?? "nil") data: \(value ?? "nil")"
            
        default:
            message = nil
        }
        
        let alert = UIAlertController.init(title: "Screen event Success ✅", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Cool", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
