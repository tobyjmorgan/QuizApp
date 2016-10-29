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
        
        playAgainButton.layer.cornerRadius = 8
        playAgainButton.isHidden = true
        
        model.gameType = .dynamicMath
        
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
            
            button.isEnabled = false
            button.backgroundColor = ViewController.deEmphasizedButtonBgColor
            
            if button === answerButton {
                
                // do nothing
                
            } else {
                
                button.setTitleColor(UIColor(white: 1.0, alpha: 0.3), for: .normal)
            }
        }
    }
    
    func displayQuizOptions() {
        
        playAgainButton.isHidden = true
        questionField.text = "Please pick the quiz you would like to play:"
        
        correctLabel.isHidden = true
        
        clearOutButtons()

        for option in QuestionsModel.GameType.allValues {
            
            let button = getAnswerButton(label: option.description())
            
            button.tag = QuestionsModel.GameType.allValues.index(of: option)!
            
            button.addTarget(self, action: #selector(onChooseQuizOption(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            
            answerButtons.append(button)
            
        }
    }
    
    func onChooseQuizOption(_ sender: UIButton) {
        
        if QuestionsModel.GameType.allValues.indices.contains(sender.tag) {
            
            deemphasizeButtons(answerButton: sender)
            
            let desiredMode = QuestionsModel.GameType.allValues[sender.tag]
            model.gameType = desiredMode
            
            // Start game
            perform(#selector(ViewController.displayQuestion), with: nil, afterDelay: 1.0)
            perform(#selector(ViewController.playGameStartSound), with: nil, afterDelay: 1.0)
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
        
        let threshold = Int(model.numberOfQuestionsPerRound / 2)
        
        if model.numberOfCorrectAnswers == model.numberOfQuestionsPerRound {
            
            questionField.text = "Wow, perfect score!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"

        } else if model.numberOfCorrectAnswers > threshold {
            
            questionField.text = "Way to go!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"

        } else {
            
            questionField.text = "Better luck next time!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"

        }
        
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
        
        perform(#selector(ViewController.doWhatsNext), with: nil, afterDelay: 2.0)
    }
    
    func doWhatsNext() {
        
        if model.numberOfQuestionsAnswered == model.numberOfQuestionsPerRound {
            displayScore()
        } else {
            perform(#selector(ViewController.displayQuestion), with: nil, afterDelay: 2.0)
        }
    }
    
    @IBAction func playAgain() {
        
        model.resetModel()
        displayQuizOptions()
    }
    

    
    // MARK: Sound Methods
    
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

