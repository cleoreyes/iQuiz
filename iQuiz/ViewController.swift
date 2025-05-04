//
//  ViewController.swift
//  iQuiz
//
//  Created by Cleo Reyes on 5/3/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let quizTopics: [QuizTopic] = [
        QuizTopic(icon: UIImage(systemName: "function"), title: "Mathematics", description: "Test your math skills!"),
        QuizTopic(icon: UIImage(systemName: "atom"), title: "Science", description: "Explore the world of science!"),
        QuizTopic(icon: UIImage(systemName: "star.fill"), title: "Marvel Super Heroes", description: "Are you a Marvel expert?")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTopicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "QuizTopicCell")

        let topic = quizTopics[indexPath.row]

        cell.imageView?.image = topic.icon
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.description
        
        cell.accessoryType = .disclosureIndicator


        return cell
    }
}
