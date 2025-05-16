//
//  ViewController.swift
//  iQuiz
//
//  Created by Cleo Reyes on 5/3/25.
//

import UIKit
import Network

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var currentQuiz: Quiz?
    var currentQuestionIndexInQuiz: Int = 0
    var currentScoreInQuiz: Int = 0
    var quizTopics: [Quiz] = []
    var refreshTimer: Timer?
    let monitor = NWPathMonitor()
    var isNetworkAvailable = true
    var hasShownFetchError = false
    
    @IBAction func unwindToQuizList(segue: UIStoryboardSegue) {
        print("Unwinding back to Quiz List from \(segue.source).")

        if let sourceVC = segue.source as? AnswerViewController {
            self.currentQuiz = sourceVC.quiz
            self.currentQuestionIndexInQuiz = sourceVC.currentQuestionIndex
            self.currentScoreInQuiz = sourceVC.score

            print("Unwind received state: Index \(self.currentQuestionIndexInQuiz), Score \(self.currentScoreInQuiz)")

            if let quiz = self.currentQuiz, self.currentQuestionIndexInQuiz < quiz.questions.count {

                performSegue(withIdentifier: "ShowQuestion", sender: self)

            } else {
                print("Unwind: Quiz finished or unexpected source.")
                self.currentQuiz = nil
                self.currentQuestionIndexInQuiz = 0
                self.currentScoreInQuiz = 0
            }

        } else {
            self.currentQuiz = nil
            self.currentQuestionIndexInQuiz = 0
            self.currentScoreInQuiz = 0
            print("Unwind from non-AnswerVC source.")
        }
    }


//    let quizTopics: [Quiz] = [
//        Quiz(title: "Mathematics", description: "Test your math skills!", iconName: "function", questions: [
//            Question(text: "What is 2 + 2?", options: ["3", "4", "5", "6"], correctAnswerIndex: 1),
//            Question(text: "What is the square root of 9?", options: ["2", "3", "4", "5"], correctAnswerIndex: 1),
//            Question(text: "What is 5 * 3?", options: ["10", "12", "15", "20"], correctAnswerIndex: 2),
//            Question(text: "What is 10 / 2?", options: ["4", "5", "6", "7"], correctAnswerIndex: 1),
//            Question(text: "What is 7 + 6?", options: ["11", "12", "13", "14"], correctAnswerIndex: 2)
//        ]),
//        Quiz(title: "Science", description: "Explore the world of science!", iconName: "atom", questions: [
//            Question(text: "What is the chemical symbol for water?", options: ["O2", "H2O", "CO2", "HO"], correctAnswerIndex: 1),
//            Question(text: "What planet is known as the Red Planet?", options: ["Earth", "Mars", "Jupiter", "Venus"], correctAnswerIndex: 1),
//            Question(text: "What gas do plants absorb from the atmosphere?", options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"], correctAnswerIndex: 1),
//            Question(text: "What is the center of an atom called?", options: ["Electron", "Proton", "Nucleus", "Neutron"], correctAnswerIndex: 2),
//            Question(text: "What is the boiling point of water in Celsius?", options: ["50", "75", "100", "150"], correctAnswerIndex: 2),
//        ]),
//        Quiz(title: "Marvel Super Heroes", description: "Are you a Marvel expert?", iconName: "star.fill", questions: [
//            Question(text: "What is the name of Thor's hammer?", options: ["Stormbreaker", "Mjolnir", "Gungnir", "Diva"], correctAnswerIndex: 1),
//            Question(text: "Who is the alter ego of Captain America?", options: ["Tony Stark", "Bruce Banner", "Steve Rogers", "Peter Parker"], correctAnswerIndex: 2),
//            Question(text: "What is Iron Man's real name?", options: ["Bruce Wayne", "Tony Stark", "Clark Kent", "Steve Rogers"], correctAnswerIndex: 1),
//            Question(text: "What is the name of Black Panther's home country?", options: ["Wakanda", "Asgard", "Latveria", "Genosha"], correctAnswerIndex: 0),
//            Question(text: "Who is the villain in Avengers: Infinity War?", options: ["Loki", "Thanos", "Ultron", "Red Skull"], correctAnswerIndex: 1)
//        ])
//    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "pullToRefreshHintShown") {
            let alert = UIAlertController(title: "Tip", message: "Pull down to refresh quizzes!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            UserDefaults.standard.set(true, forKey: "pullToRefreshHintShown")
        }
        
        tableView.dataSource = self
        tableView.delegate = self

        let titleLabel = UILabel()
        titleLabel.text = "iQuiz"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.sizeToFit()

        navigationItem.titleView = titleLabel
        
        setupNetworkMonitor()
        loadSettingsAndFetch()
        setupPullToRefresh()
    }
    
    func setupNetworkMonitor() {
            monitor.pathUpdateHandler = { path in
                self.isNetworkAvailable = (path.status == .satisfied)
                if !self.isNetworkAvailable {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Network Error", message: "No network connection.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
            let queue = DispatchQueue(label: "NetworkMonitor")
            monitor.start(queue: queue)
        }

        func loadSettingsAndFetch() {
            let url = UserDefaults.standard.string(forKey: "quizDataURL") ?? "https://tednewardsandbox.site44.com/questions.json"
            let interval = UserDefaults.standard.double(forKey: "refreshInterval")
            fetchQuizData(from: url)
            if interval > 0 {
                startTimedRefresh(interval: interval)
            }
        }

        func fetchQuizData(from urlString: String) {
            guard isNetworkAvailable else {
                print("Network is not available")
                return
            }
            guard let url = URL(string: urlString) else {
                print("Invalid URL: \(urlString)")
                return
            }
            print("Fetching quiz data from: \(urlString)")
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.refreshTimer?.invalidate() // Stop timed refresh on error
                        if !self.hasShownFetchError && self.presentedViewController == nil { // Only show once
                            self.hasShownFetchError = true
                            let alert = UIAlertController(title: "Error", message: "Failed to fetch quiz data: \(error.localizedDescription)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                // After OK, do not show again until a successful fetch
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP error: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Server returned error: \(httpResponse.statusCode)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                // Print the received JSON data for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received JSON data: \(jsonString)")
                }
                
                do {
                    let quizzes = try JSONDecoder().decode([Quiz].self, from: data)
                    print("Successfully decoded \(quizzes.count) quizzes")
                    DispatchQueue.main.async {
                        self.hasShownFetchError = false // Reset error flag on success
                        self.quizTopics = quizzes
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Decoding error: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("Key '\(key)' not found: \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("Type '\(type)' mismatch: \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("Value of type '\(type)' not found: \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context.debugDescription)")
                        @unknown default:
                            print("Unknown decoding error: \(decodingError)")
                        }
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Failed to parse quiz data: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
            task.resume()
        }

        func setupPullToRefresh() {
           print("Setting up pull to refresh")
           let refreshControl = UIRefreshControl()
           refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
           tableView.refreshControl = refreshControl
        }

        @objc func refreshData() {
           print("refreshData() called")
           let url = UserDefaults.standard.string(forKey: "quizDataURL") ?? "https://tednewardsandbox.site44.com/questions.json"
           fetchQuizData(from: url)
           tableView.refreshControl?.endRefreshing()
           print("Refreshed data")
        }

        func startTimedRefresh(interval: TimeInterval) {
            refreshTimer?.invalidate()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                self.refreshData()
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowQuestion" {
        if let destinationVC = segue.destination as? QuestionViewController {
            if let selectedQuiz = sender as? Quiz {
                destinationVC.quiz = selectedQuiz
                destinationVC.currentQuestionIndex = 0
                destinationVC.score = 0
            } else if let currentQuiz = currentQuiz {
                destinationVC.quiz = currentQuiz
                destinationVC.currentQuestionIndex = currentQuestionIndexInQuiz
                destinationVC.score = currentScoreInQuiz
            }
        }
    }
}
        
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.onSettingsChanged = { [weak self] in
            self?.loadSettingsAndFetch()
        }
        present(settingsVC, animated: true)
    }
    
}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTopicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "QuizTopicCell")

        let topic = quizTopics[indexPath.row]

//        if let iconName = topic.iconName {
//            cell.imageView?.image = UIImage(systemName: iconName)
//        } else {
//            cell.imageView?.image = nil
//        }
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.desc
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuiz = quizTopics[indexPath.row]

        performSegue(withIdentifier: "ShowQuestion", sender: selectedQuiz)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
