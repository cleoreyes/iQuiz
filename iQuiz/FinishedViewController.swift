//
//  FinishedViewController.swift
//  iQuiz
//
//  Created by Cleo Reyes on 5/13/25.
//

import UIKit

class FinishedViewController: UIViewController {

    // MARK: - Properties to receive data

        var finalScore: Int!
        var totalQuestions: Int!


        // MARK: - Outlets

        @IBOutlet weak var performanceMessageLabel: UILabel!
        @IBOutlet weak var scoreLabel: UILabel!
        @IBOutlet weak var finishedButton: UIButton!


        // MARK: - Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()
            
            let backArrowImage = UIImage(systemName: "chevron.backward")
                let customView = UIView()
                let imageView = UIImageView(image: backArrowImage)
                imageView.tintColor = .systemBlue
                imageView.contentMode = .scaleAspectFit
                customView.addSubview(imageView)
                let label = UILabel()
                label.text = "Back"
                label.textColor = .systemBlue
                label.font = UIFont.systemFont(ofSize: 17)
                customView.addSubview(label)
                imageView.frame = CGRect(x: 0, y: 0, width: 12, height: 20)
                label.frame = CGRect(x: imageView.frame.width + 4, y: 0, width: 40, height: 20)
                customView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width + 4 + label.frame.width, height: 20)
                let customBackButton = UIBarButtonItem(customView: customView)
                self.navigationItem.leftBarButtonItem = customBackButton
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quitQuizButtonTapped))
               customView.addGestureRecognizer(tapGesture)
               customView.isUserInteractionEnabled = true

            guard finalScore != nil, totalQuestions != nil else {
                print("Error: Missing score data in FinishedViewController.")
                scoreLabel.text = "Score Error"
                performanceMessageLabel.text = "Could not load results."
                finishedButton.isEnabled = false
                return
            }

            scoreLabel.text = "You got \(finalScore!) out of \(totalQuestions!) correct."

            let percentage = (Double(finalScore) / Double(totalQuestions)) * 100

            if finalScore == totalQuestions {
                performanceMessageLabel.text = "Perfect!"
                performanceMessageLabel.textColor = UIColor.systemGreen
            } else if percentage >= 70 { 
                performanceMessageLabel.text = "Great Job!"
                 performanceMessageLabel.textColor = UIColor.systemYellow
            } else if percentage >= 40 {
                 performanceMessageLabel.text = "Almost!"
                 performanceMessageLabel.textColor = UIColor.systemOrange
            }
            else {
                performanceMessageLabel.text = "Keep Practicing!"
                performanceMessageLabel.textColor = UIColor.systemRed
            }

             print("FinishedVC loaded. Final Score: \(finalScore!) / \(totalQuestions!)")
        }
    
        @objc func quitQuizButtonTapped() {
            print("Custom back button tapped on QuestionVC. Returning to root.")
            self.navigationController?.popToRootViewController(animated: true)
        }

        // MARK: - Actions

        @IBAction func finishedButtonTapped(_ sender: UIButton) {
            print("Finished button tapped on Finished screen. Returning to quiz list.")

            self.navigationController?.popToRootViewController(animated: true)
        }
}
