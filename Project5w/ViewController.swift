//
//  ViewController.swift
//  Project5w
//
//  Created by Guga Dolidze on 8/23/23.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()   // Array to store all possible words
    var usedWords = [String]()  // Array to store words already used

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up "Add" button on the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        // Set up "Restart" button on the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restart", style: .plain, target: self, action: #selector(startGame))

        // Load initial word list from a file, or use a default word
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }

        startGame()  // Start the game with a random initial word
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count  // Number of rows to display in the table
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]  // Set text for each cell
        return cell
    }

    @objc func startGame() {
        title = allWords.randomElement()  // Set the current word as the title
        usedWords.removeAll(keepingCapacity: true)  // Clear used words array
        tableView.reloadData()  // Reload table view to reflect changes
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()  // Add a text field to the alert

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] action in
            let answer = ac.textFields![0]  // Get user input from the text field
            self.submit(answer: answer.text!)  // Process the submitted answer
        }

        ac.addAction(submitAction)  // Add the submit action to the alert

        present(ac, animated: true)  // Present the alert to the user
    }

    // Check if a word can be formed using the letters of the current title
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()

        // Iterate through each letter in the word
        for letter in word {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)  // Remove matched letters
            } else {
                return false  // Letter not found in the current title
            }
        }

        return true
    }

    // Check if a word has already been used
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    // Check if a word is a valid English word
    func isReal(word: String) -> Bool {
        
        if word.utf16.count < 3 || word.lowercased() == title!.lowercased() {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
        
        
    }

    // Process the submitted answer
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    // Insert valid answer into the usedWords array
                    usedWords.insert(lowerAnswer, at: 0)

                    // Insert a new row in the table for the new word
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)

                    return
                } else {
                    showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(title: "Word used already", message: "Be more original!")
            }
        } else {
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from '\(title!.lowercased())'!")
        }
    }

    // Show an alert with the given error message and title
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}





