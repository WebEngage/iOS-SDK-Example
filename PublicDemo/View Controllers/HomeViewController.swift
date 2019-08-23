//
//  HomeViewController.swift
//  Public Demo
//
//  Created by Yogesh Singh on 28/09/18.
//  Copyright © 2018 Yogesh Singh. All rights reserved.
//

import UIKit
import WebEngage

class HomeViewController: UIViewController {

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationView()
        setLeftBarButton()
        checkLicenseCode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        table.reloadData()
    }

    // MARK: View Helpers

    @IBOutlet weak var table: UITableView! {
        didSet {
            table.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        }
    }

    private func setLeftBarButton() {

        let button = UIButton()

        button.setTitleColor(UIColor.init(red: 21/255.0, green: 124/255.0, blue: 247/255.0, alpha: 1), for: .normal)

        button.addTarget(self, action: #selector(handleLeftBarButtonTap(_:)), for: .touchUpInside)

        if let currentLoginID = UserDefaults.standard.value(forKey: Constants.loginID) as? String {
            button.setTitle(currentLoginID, for: .normal)
        } else {
            button.setTitle("Login", for: .normal)
        }

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }

    private func setNavigationView() {

        var wegSDKVersion = "0.0.0"

        if let infoDictionary = Bundle.init(for: WebEngage.self).infoDictionary {
            if let version = infoDictionary["CFBundleShortVersionString"] as? String {
                wegSDKVersion = version
            }
        }

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "WebEngageIcon")

        let label = UILabel()
        label.text = "WebEngage" + " " + wegSDKVersion
        label.sizeToFit()
        label.frame = CGRect(x: 35, y: 0, width: label.frame.size.width, height: 30)

        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 35+label.frame.size.width, height: 30))
        view.addSubview(imageView)
        view.addSubview(label)

        self.navigationItem.titleView = view
    }

    private func checkLicenseCode() {
        if let licenseCode = Bundle.main.object(forInfoDictionaryKey: "WEGLicenseCode") as? String {
            if licenseCode == "YOUR_LICENSE_CODE" {
                showLicenseCodeAlert()
            }
        } else {
            showLicenseCodeAlert()
        }
    }

    private func showLicenseCodeAlert() {

        let alert = UIAlertController(title: "License Code Missing", message: "Enter your License Code in Info.plist", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Action Helpers

    private func performLogin() {

        let alert = UIAlertController(title: "Login", message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Enter Login ID"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in

            let loginID = alert.textFields![0].text!

            print("loginID: \(loginID)")

            WebEngage.sharedInstance()?.user.login(loginID)

            UserDefaults.standard.set(loginID, forKey: Constants.loginID)

            self.table.reloadData()

            self.setLeftBarButton()

            let confirmAlert = UIAlertController(title: "Login Success", message: "You are logged in now with ID: \(loginID)",
                preferredStyle: .alert)

            confirmAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

            self.present(confirmAlert, animated: true, completion: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    private func performLogout() {

        if let loginID = UserDefaults.standard.value(forKey: Constants.loginID) as? String {

            let alert = UIAlertController.init(title: "Logout: \(loginID)", message: nil, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in

                WebEngage.sharedInstance()?.user.logout()
                UserDefaults.standard.removeObject(forKey: Constants.loginID)

                self.table.reloadData()

                self.setLeftBarButton()
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func infoTapped(_ sender: UIBarButtonItem) {
        self.presentViewController(for: "AppInfo")
    }

    @objc private func handleLeftBarButtonTap(_ sender: UIButton) {

        if ((UserDefaults.standard.value(forKey: Constants.loginID) as? String) != nil) {
            performLogout()
        } else {
            performLogin()
        }
    }
}

// MARK: Table Data Source

extension HomeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
       return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return 3
        } else if section == 1 {
            return 5
        } else if section == 2 {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(UITableViewCell.self))

        if indexPath.section == 0 {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(UITableViewCell.self))
        }

        update(cell, at: indexPath)

        return cell
    }

    private func update(_ cell: UITableViewCell, at indexPath: IndexPath) {

        cell.accessoryType = .none
        cell.textLabel?.textColor = .black

        var text: String?

        switch indexPath.section {
        case 0:
            cell.detailTextLabel?.textColor = .black
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.detailTextLabel?.adjustsFontSizeToFitWidth = true

            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Environment"
                #if STAGING
                    cell.detailTextLabel?.text = "Staging"
                #else
                    cell.detailTextLabel?.text = "Production"
                #endif

            case 1:
                cell.textLabel?.text = "Current License Code"
                cell.detailTextLabel?.text = Constants.defaultCode
            case 2:
                cell.textLabel?.text = "Current User LoginID"
                cell.detailTextLabel?.text = (UserDefaults.standard.value(forKey: Constants.loginID) as? String) ?? "Anonymous"
            default:
                print("Exception! Shouldn't hit default case")
            }

        case 1:

            cell.accessoryType = .disclosureIndicator

            switch indexPath.row {
            case 0:
                text = "Set User Profile"
            case 1:
                text = "Fire Events"
            case 2:
                text = "Set Screen Info"
            case 3:
                text = "Location Tracking"
            case 4:
                text = "WebView Bridge"
            default:
                print("Exception! Shouldn't hit default case")
            }

        case 2:

            cell.accessoryType = .disclosureIndicator

            switch indexPath.row {
            case 0:
                text = "Open iPhone Settings"
            default:
                print("Exception! Shouldn't hit default case")
            }

        default:
            print("Exception! Shouldn't hit default case")
        }

        if indexPath.section != 0 {
            cell.textLabel?.text = text
        }

        cell.textLabel?.adjustsFontSizeToFitWidth = true
    }
}

// MARK: Table Delegates

extension HomeViewController: UITableViewDelegate {

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        handleDidSelectCell(at: indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func handleDidSelectCell(at indexPath: IndexPath) {

        switch indexPath.section {
        case 0:

            switch indexPath.row {
            default:
                print("Exception! Shouldn't hit default case")
            }

        case 1:
            switch indexPath.row {
            case 0:
                self.presentViewController(for: "UserProfile")
            case 1:
                self.presentViewController(for: "Events")
            case 2:
                self.presentViewController(for: "Screens")
            case 3:
                self.locationTapped()
            case 4:
                self.presentViewController(for: "WebViewBridge")
            default:
                print("Exception! Shouldn't hit default case")
            }

        case 2:
            switch indexPath.row {
            case 0:
                self.openSettings()
            default:
                print("Exception! Shouldn't hit default case")
            }

        case 3:
            switch indexPath.row {
            default:
                print("Exception! Shouldn't hit default case")
            }

        default:
            print("Exception! Shouldn't hit default case")
        }
    }

    private func presentViewController(for storyboard: String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        self.present(storyboard.instantiateInitialViewController()!, animated: true, completion: nil)
    }

    private func locationTapped() {

        let alert = UIAlertController(title: "Set Location Tracking", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Best Accuracy", style: .default, handler: { (_) in
            WebEngage.sharedInstance()?.autoTrackUserLocation(with: .best)
        }))

        alert.addAction(UIAlertAction(title: "City Accuracy", style: .default, handler: { (_) in
            WebEngage.sharedInstance()?.autoTrackUserLocation(with: .forCity)
        }))

        alert.addAction(UIAlertAction(title: "Country Accuracy", style: .default, handler: { (_) in
            WebEngage.sharedInstance()?.autoTrackUserLocation(with: .forCountry)
        }))

        alert.addAction(UIAlertAction(title: "Disable Location Tracking", style: .destructive, handler: { (_) in
            WebEngage.sharedInstance()?.autoTrackUserLocation(with: .disable)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func openSettings() {

        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {

            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings are opened: \(success)")
            })
        }
    }

}
