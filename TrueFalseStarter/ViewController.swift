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
    
    static let buttonColor = UIColor(red: 0.14, green: 0.365, blue: 0.475, alpha: 1.0)
    static let deEmphasizedButtonColor = UIColor(red: 0.14, green: 0.365, blue: 0.475, alpha: 0.3)
    
    var gameSound: SystemSoundID = 0
    
    var model = QuestionsModel()
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var correctLabel: UILabel!
    
    var answerButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.gameMode = .politicalHistory
        
        loadGameStartSound()
        
        // Start game
        playGameStartSound()
        displayQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayQuestion() {

        correctLabel.isHidden = true
        
        for subview in stackView.subviews {
            
            subview.removeFromSuperview()
        }
        
        answerButtons.removeAll()
        
        if let question = model.getNextQuestion() {
            
            questionField.text = question.wording
            
            var tagNumber = 1
            
            for answer in question.answers {
                
                let button = UIButton()
                
                button.heightAnchor.constraint(equalToConstant: 40).isActive = true
                button.setTitle(answer, for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = ViewController.buttonColor
                button.layer.cornerRadius = 10
                
                button.tag = tagNumber
                tagNumber += 1
                
                button.addTarget(self, action: #selector(checkAnswer(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
                
                answerButtons.append(button)
            }
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        playAgainButton.isHidden = true
    }
    
    func displayScore() {
        
        // Display play again button
        playAgainButton.isHidden = false
        
        questionField.text = "Way to go!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"
        
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        
        for button in answerButtons {
            
            button.backgroundColor = ViewController.deEmphasizedButtonColor
            
            if button === sender {
                
                // do nothing
                
            } else {
                
                button.setTitleColor(UIColor(white: 1.0, alpha: 0.3), for: .normal)
            }
        }
        
        if model.isCorrectResponse(response: sender.tag) {
            
            model.numberOfCorrectAnswers += 1
            
            correctLabel.text = "Correct!"
            
        } else {
            
            correctLabel.text = "Sorry, that's not it."
        }
        
        correctLabel.isHidden = false
        
        model.numberOfQuestionsAnswered += 1
        
        perform(#selector(ViewController.displayQuestion), with: nil, afterDelay: 2.0)
        
//        if sender === firstButton {
//            response = 1
//        } else if sender === secondButton {
//            response = 2
//        } else if sender === thirdButton {
//            response = 3
//        } else if sender === fourthButton {
//            response = 4
//        }
//
//        if let response = response {
//            
//        }
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
    
    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
}

