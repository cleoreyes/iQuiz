import Foundation

class StorageManager {
    static let shared = StorageManager()
    private let quizzesKey = "savedQuizzes"
    private let lastFetchDateKey = "lastFetchDate"
    
    private init() {}
    
    func saveQuizzes(_ quizzes: [Quiz]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(quizzes)
            UserDefaults.standard.set(data, forKey: quizzesKey)
            UserDefaults.standard.set(Date(), forKey: lastFetchDateKey)
            print("Saved \(quizzes.count) quizzes to local storage")
        } catch {
            print("Error saving quizzes: \(error)")
        }
    }
    
    func loadQuizzesFromBundle() -> [Quiz]? {
        guard let url = Bundle.main.url(forResource: "quizzes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not find quizzes.json in bundle.")
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let quizzes = try decoder.decode([Quiz].self, from: data)
            print("Loaded \(quizzes.count) quizzes from bundle.")
            return quizzes
        } catch {
            print("Error decoding quizzes from bundle: \(error)")
            return nil
        }
    }
    
    func loadQuizzes() -> [Quiz]? {
        if let data = UserDefaults.standard.data(forKey: quizzesKey) {
            do {
                let decoder = JSONDecoder()
                let quizzes = try decoder.decode([Quiz].self, from: data)
                print("Loaded \(quizzes.count) quizzes from local storage")
                return quizzes
            } catch {
                print("Error loading quizzes: \(error)")
            }
        }
        return loadQuizzesFromBundle()
    }
    
    func fetchQuizzes(from urlString: String, completion: @escaping ([Quiz]?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error)")
                if let cachedQuizzes = self?.loadQuizzes() {
                    completion(cachedQuizzes, nil)
                } else {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: -2))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let quizzes = try decoder.decode([Quiz].self, from: data)
                self?.saveQuizzes(quizzes)
                completion(quizzes, nil)
            } catch {
                print("Decoding error: \(error)")
                if let cachedQuizzes = self?.loadQuizzes() {
                    completion(cachedQuizzes, nil)
                } else {
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
    func clearQuizzes() {
        UserDefaults.standard.removeObject(forKey: quizzesKey)
        UserDefaults.standard.removeObject(forKey: lastFetchDateKey)
        print("Cleared saved quizzes")
    }
    
    func getLastFetchDate() -> Date? {
        return UserDefaults.standard.object(forKey: lastFetchDateKey) as? Date
    }
} 
