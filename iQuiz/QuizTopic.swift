//
//  QuizTopic.swift
//  iQuiz
//
//  Created by Cleo Reyes on 5/3/25.
//

import UIKit

struct QuizTopic {
    let icon: UIImage?
    let title: String
    let description: String
}

struct Question {
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
}

struct Quiz {
    let title: String
    let description: String
    let iconName: String?
    let questions: [Question]
}
