//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by Cleo Reyes on 5/6/25.
//

import UIKit

class QuestionViewController: UIViewController {

    var quiz: Quiz!
    var currentQuestionIndex: Int = 0
    var score: Int = 0
    
    var selectedAnswerIndex: Int?

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet var answerButtons: [UIButton]!

    @IBOutlet weak var submitButton: UIButton!
    
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

            // Swipe Left to Abandon
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
            swipeLeft.direction = .left
            view.addGestureRecognizer(swipeLeft)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quitQuizButtonTapped))
           customView.addGestureRecognizer(tapGesture)
           customView.isUserInteractionEnabled = true
        
        if let quiz = quiz, currentQuestionIndex < quiz.questions.count {
                    let currentQuestion = quiz.questions[currentQuestionIndex]
                    questionLabel.text = currentQuestion.text

                } else {
                    questionLabel.text = "Error loading question."
                }
        
        guard let quiz = quiz, currentQuestionIndex < quiz.questions.count else {
                    questionLabel.text = "Error loading question."
                    submitButton.isEnabled = false
                    answerButtons.forEach { $0.isHidden = true }
                    return
                }

                let currentQuestion = quiz.questions[currentQuestionIndex]

                questionLabel.text = currentQuestion.text

                for (index, button) in answerButtons.enumerated() {
                    if index < currentQuestion.answers.count {
                        button.setTitle(currentQuestion.answers[index], for: .normal)
                        button.isHidden = false
                         button.backgroundColor = UIColor.systemBlue
                         button.setTitleColor(.white, for: .normal)

                    } else {
                        button.isHidden = true
                    }
                }

                submitButton.isEnabled = false
    }
    
    @objc func quitQuizButtonTapped() {
        print("Custom back button tapped on QuestionVC. Returning to root.")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleSwipeRight() {
        if submitButton.isEnabled {
            submitButtonTapped(submitButton)
        }
    }

    @objc func handleSwipeLeft() {
        quitQuizButtonTapped()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let selectedAnswerIndex = selectedAnswerIndex,
                      let quiz = quiz else {
                    print("Error: Data missing before submitting.")
                    return
                }

                let dataToPass = (
                    question: quiz.questions[currentQuestionIndex],
                    userAnswerIndex: selectedAnswerIndex,
                    quiz: quiz,
                    currentQuestionIndex: currentQuestionIndex,
                    score: score
                )

                performSegue(withIdentifier: "ShowAnswer", sender: dataToPass)

                submitButton.isEnabled = false
                answerButtons.forEach { $0.isEnabled = false }
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        if let tappedIndex = answerButtons.firstIndex(of: sender) {
            selectedAnswerIndex = tappedIndex

            for (index, button) in answerButtons.enumerated() {
                if index == tappedIndex {
                    button.backgroundColor = UIColor.systemGreen
                    button.setTitleColor(.black, for: .normal)
                } else {
                    button.backgroundColor = UIColor.systemBlue
                    button.setTitleColor(.white, for: .normal)
                }
            }

            submitButton.isEnabled = true

            print("Selected answer index: \(tappedIndex)")
        }
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowAnswer" {

                if let destinationVC = segue.destination as? AnswerViewController {

                    if let data = sender as? (question: Question, userAnswerIndex: Int, quiz: Quiz, currentQuestionIndex: Int, score: Int) {

                        destinationVC.question = data.question
                        destinationVC.userAnswerIndex = data.userAnswerIndex
                        destinationVC.quiz = data.quiz
                        destinationVC.currentQuestionIndex = data.currentQuestionIndex
                        destinationVC.score = data.score

                        print("Preparing for AnswerVC. User answer: \(data.userAnswerIndex), Score: \(data.score)")
                    } else {
                        print("Error: Could not cast sender data for ShowAnswer segue.")
                    }
                } else {
                     print("Error: Destination ViewController is not an AnswerViewController.")
                }
            }
        }
    

}
