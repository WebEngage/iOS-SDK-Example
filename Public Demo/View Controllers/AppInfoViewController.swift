//
//  AppInfoViewController.swift
//  WebEngageExampleSwift
//
//  Created by Yogesh Singh on 16/11/18.
//  Copyright © 2018 Yogesh Singh. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController {
    
    var plistItems: [String: Any]? {
        didSet {
    
            let keys = Array(plistItems!.keys)
            plistItemKeys = keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            plistItemKeys =  plistItemKeys?.filter { $0 != "CFBundleShortVersionString" }
            plistItemKeys?.insert("CFBundleShortVersionString", at: 0)
        }
    }
    
    var plistItemKeys: [String]?
    
    
    @IBOutlet weak var table: UITableView! {
        didSet {
            
            table.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
            
            plistItems = Utils.getAppInfoPlistItems()
            
            table.reloadData()
        }
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AppInfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plistItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let version = plistItems!["CFBundleShortVersionString"] as! String
        let buildNumber = plistItems!["CFBundleVersion"] as! String
        return "App Version " + version + " (" + buildNumber + ")"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(UITableViewCell.self))
        
        self.update(cell, at: indexPath)

        return cell
    }
    
    private func update(_ cell: UITableViewCell, at index: IndexPath) {
        
        let key = plistItemKeys![index.row]
        
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = "\(plistItems![key] ?? "Couldn't parse value")"
        
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        cell.detailTextLabel?.textColor = .darkGray
    }
}

extension AppInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return (tableView.cellForRow(at: indexPath)?.detailTextLabel?.text) != nil
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let cell = tableView.cellForRow(at: indexPath)
            let pasteboard = UIPasteboard.general
            pasteboard.string = cell?.detailTextLabel?.text
        }
    }
}
