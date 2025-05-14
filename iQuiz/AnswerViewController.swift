//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by Cleo Reyes on 5/11/25.
//

import UIKit

class AnswerViewController: UIViewController {

    // MARK: - Properties to receive data

    var question: Question!
    var userAnswerIndex: Int!
    var quiz: Quiz!
    var currentQuestionIndex: Int!
    var score: Int!


    // MARK: - Outlets (Connect these in Storyboard)

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!


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
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
            swipeRight.direction = .right
            view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quitQuizButtonTapped))
           customView.addGestureRecognizer(tapGesture)
           customView.isUserInteractionEnabled = true
        
        guard let question = question, userAnswerIndex != nil else {
            print("Error: Missing data in AnswerViewController.")
            correctAnswerLabel.text = "Error."
            resultLabel.text = "Could not check answer."
            nextButton.isEnabled = false
            return
        }

        questionLabel?.text = question.text

        correctAnswerLabel.text = "Correct Answer: \(question.options[question.correctAnswerIndex])"

        let isCorrect = (userAnswerIndex == question.correctAnswerIndex)

        if isCorrect {
            resultLabel.text = "Correct!"
            resultLabel.textColor = UIColor.systemGreen
            score += 1
            print("Answer is Correct. New score: \(score)")
        } else {
            resultLabel.text = "Incorrect."
            resultLabel.textColor = UIColor.systemRed
            print("Answer is Incorrect. Score remains: \(score)")
        }

        nextButton.isEnabled = true
    }
    
    @objc func quitQuizButtonTapped() {
        print("Custom back button tapped on QuestionVC. Returning to root.")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleSwipeRight() {
        if nextButton.isEnabled {
            nextButtonTapped(nextButton)
        }
    }

    @objc func handleSwipeLeft() {
        quitQuizButtonTapped()
    }


    // MARK: - Actions

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let quiz = quiz else { return }
    currentQuestionIndex += 1

    if currentQuestionIndex < quiz.questions.count {
        performSegue(withIdentifier: "ShowNextQuestion", sender: self)
    } else {
        performSegue(withIdentifier: "ShowFinished", sender: self)
    }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNextQuestion" {
        if let destinationVC = segue.destination as? QuestionViewController {
            destinationVC.quiz = quiz
            destinationVC.currentQuestionIndex = currentQuestionIndex
            destinationVC.score = score
        }
    } else if segue.identifier == "ShowFinished" {
        if let destinationVC = segue.destination as? FinishedViewController {
            destinationVC.finalScore = score
            destinationVC.totalQuestions = quiz.questions.count
        }
    }
    }

}
