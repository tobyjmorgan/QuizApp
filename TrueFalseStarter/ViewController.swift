//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    static let buttonBgColor = UIColor.TMRGBA(red: 52, green: 101, blue: 131, alpha: 255)
    static let deEmphasizedButtonBgColor = UIColor.TMRGBA(red: 52, green: 101, blue: 131, alpha: 85)
    static let correctAnswerTextColor = UIColor.TMRGBA(red: 64, green: 130, blue: 115, alpha: 255)
    static let incorrectAnswerTextColor = UIColor.TMRGBA(red: 227, green: 145, blue: 80, alpha: 255)
    
    var gameSound: SystemSoundID = 0
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 0
    var quizOver: SystemSoundID = 0
    
    var model = QuestionsModel()
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var correctLabel: UILabel!
    
    var answerButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        model.gameMode = .dynamicMath
        
        loadGameSounds()
        
        displayQuizOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearOutButtons() {
        
        for subview in stackView.subviews {
            
            subview.removeFromSuperview()
        }
        
        answerButtons.removeAll()
    }
    
    func getAnswerButton(label: String) -> UIButton {
        
        let button = UIButton()
        
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(label, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ViewController.buttonBgColor
        button.layer.cornerRadius = 8
        
        return button
    }
    
    func deemphasizeButtons(answerButton: UIButton) {
        
        for button in answerButtons {
            
            button.backgroundColor = ViewController.deEmphasizedButtonBgColor
            
            if button === answerButton {
                
                // do nothing
                
            } else {
                
                button.setTitleColor(UIColor(white: 1.0, alpha: 0.3), for: .normal)
            }
        }
    }
    
    func displayQuizOptions() {
        
        questionField.text = "Please pick the quiz you would like to play:"
        
        correctLabel.isHidden = true
        
        clearOutButtons()

        for option in QuestionsModel.GameMode.allValues {
            
            let button = getAnswerButton(label: option.description())
            
            button.tag = QuestionsModel.GameMode.allValues.index(of: option)!
            
            button.addTarget(self, action: #selector(onChooseQuizOption(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            
            answerButtons.append(button)
            
        }
    }
    
    func onChooseQuizOption(_ sender: UIButton) {
        
        if QuestionsModel.GameMode.allValues.indices.contains(sender.tag) {
            
            deemphasizeButtons(answerButton: sender)
            
            let desiredMode = QuestionsModel.GameMode.allValues[sender.tag]
            model.gameMode = desiredMode
            
            // Start game
            perform(#selector(ViewController.displayQuestion), with: nil, afterDelay: 2.0)
            perform(#selector(ViewController.playGameStartSound), with: nil, afterDelay: 2.0)
        }
    }
    
    func displayQuestion() {

        correctLabel.isHidden = true
        
        clearOutButtons()
        
        if let question = model.getNextQuestion() {
            
            questionField.text = question.wording
            
            var tagNumber = 1
            
            for answer in question.answers {
                
                let button = getAnswerButton(label: answer)
                
                button.tag = tagNumber
                tagNumber += 1
                
                button.addTarget(self, action: #selector(checkAnswer(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
                
                answerButtons.append(button)
            }
            
//            stackView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        playAgainButton.isHidden = true
    }
    
    func displayScore() {
        
        // Display play again button
        playAgainButton.isHidden = false
        
        questionField.text = "Way to go!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"
        
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        
        deemphasizeButtons(answerButton: sender)
        
        if model.isCorrectResponse(response: sender.tag) {
            
            model.numberOfCorrectAnswers += 1
            
            correctLabel.text = "Correct!"
            correctLabel.textColor = ViewController.correctAnswerTextColor
            playCorrectSound()
            
        } else {
            
            correctLabel.text = "Sorry, that's not it."
            correctLabel.textColor = ViewController.incorrectAnswerTextColor
            playIncorrectSound()
        }
        
        correctLabel.isHidden = false
        
        model.numberOfQuestionsAnswered += 1
        
        perform(#selector(ViewController.displayQuestion), with: nil, afterDelay: 2.0)
        
//        
//        // Increment the questions asked counter
//        questionsAsked += 1
//        
//        let selectedQuestionDict = trivia[indexOfSelectedQuestion]
//        let correctAnswer = selectedQuestionDict["Answer"]
//        
//        if (sender === trueButton &&  correctAnswer == "True") || (sender === falseButton && correctAnswer == "False") {
//            correctQuestions += 1
//            questionField.text = "Correct!"
//        } else {
//            questionField.text = "Sorry, wrong answer!"
//        }
//        
//        loadNextRoundWithDelay(seconds: 2)
    }
    
    func nextRound() {
//        if questionsAsked == questionsPerRound {
//            // Game is over
//            displayScore()
//        } else {
//            // Continue game
//            displayQuestion()
//        }
    }
    
    @IBAction func playAgain() {
//        // Show the answer buttons
//        trueButton.isHidden = false
//        falseButton.isHidden = false
//        
//        questionsAsked = 0
//        correctQuestions = 0
//        nextRound()
    }
    

    
    // MARK: Helper Methods
    
    func loadNextRoundWithDelay(seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
    func loadSound(filename: String, systemSound: inout SystemSoundID) {
        
        if let pathToSoundFile = Bundle.main.path(forResource: filename, ofType: "wav") {
            
            let soundURL = URL(fileURLWithPath: pathToSoundFile)
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &systemSound)
        }
    }
    
    func loadGameSounds() {
        
        loadSound(filename: "GameSound", systemSound: &gameSound)
        loadSound(filename: "Correct", systemSound: &correctSound)
        loadSound(filename: "Incorrect", systemSound: &incorrectSound)
        loadSound(filename: "QuizOver", systemSound: &quizOver)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func playCorrectSound() {
        AudioServicesPlaySystemSound(correctSound)
    }

    func playIncorrectSound() {
        AudioServicesPlaySystemSound(incorrectSound)
    }

    func playQuizOverSound() {
        AudioServicesPlaySystemSound(quizOver)
    }
}

