//
//  SettingsViewController.swift
//  iQuiz
//
//  Created by Cleo Reyes on 5/14/25.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var intervalTextField: UITextField!
    @IBOutlet weak var checkNowButton: UIButton!
    @IBOutlet weak var openSettingsButton: UIButton!

    var onSettingsChanged: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
    }
    
    private func setupUI() {
        openSettingsButton.setTitle("Open Settings App", for: .normal)
        openSettingsButton.addTarget(self, action: #selector(openSettingsApp), for: .touchUpInside)
    }
    
    private func loadSettings() {
        urlTextField.text = UserDefaults.standard.string(forKey: "quizDataURL") ?? "http://tednewardsandbox.site44.com/questions.json"
        intervalTextField.text = "\(UserDefaults.standard.double(forKey: "refreshInterval"))"
    }

    @IBAction func saveSettings(_ sender: Any) {
        let url = urlTextField.text ?? ""
        let interval = Double(intervalTextField.text ?? "") ?? 0
        UserDefaults.standard.set(url, forKey: "quizDataURL")
        UserDefaults.standard.set(interval, forKey: "refreshInterval")
        onSettingsChanged?()
        dismiss(animated: true)
    }

    @IBAction func checkNowTapped(_ sender: Any) {
        onSettingsChanged?()
        dismiss(animated: true)
    }
    
    @objc private func openSettingsApp() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
