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

struct Question: Codable {
    let text: String
    let answer: String
    let answers: [String]
}

struct Quiz: Codable {
    let title: String
    let desc: String
    let questions: [Question]
    
    enum CodingKeys: String, CodingKey {
        case title
        case desc
        case questions
    }
}
