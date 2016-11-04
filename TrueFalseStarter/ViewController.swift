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
    
    // using a homegrown extension to UIColor called TMRGBA which makes it easier to generate
    // colors if you know the 0-255 vallues of the color's RGBA values
    static let buttonBgColor = UIColor.TMRGBA(red: 52, green: 101, blue: 131, alpha: 255)
    static let deEmphasizedButtonBgColor = UIColor.TMRGBA(red: 52, green: 101, blue: 131, alpha: 85)
    static let correctAnswerTextColor = UIColor.TMRGBA(red: 64, green: 130, blue: 115, alpha: 255)
    static let incorrectAnswerTextColor = UIColor.TMRGBA(red: 227, green: 145, blue: 80, alpha: 255)
    static let answerBGColorCorrect = UIColor.TMRGBA(red: 80, green: 255, blue: 80, alpha: 150)
    static let answerBGColorIncorrect = UIColor.TMRGBA(red: 255, green: 80, blue: 80, alpha: 150)
    
    // sounds
    var gameSound: SystemSoundID = 0
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 0
    var quizOver: SystemSoundID = 0
    
    // create an instance of the model
    var model = QuestionsModel()
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var correctLabel: UILabel!
    @IBOutlet var quizTypeLbl: UILabel!
    @IBOutlet var nextQuestionButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var timerLabelBox: UIView!
    @IBOutlet var lightningModeSwitch: UISwitch!
    @IBOutlet var lightningModeLabel: UILabel!
    @IBOutlet var bgImage: UIImageView!
    
    @IBAction func onLightningModeSwitch(_ sender: AnyObject) {
        model.lightningMode = sender.isOn
        
        if model.lightningMode {
            
            timerLabelBox.isHidden = false
            
        } else {
            
            timerLabelBox.isHidden = true
        }
    }
    
    var answerButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // round the corners of the buttons
        // and make them initially hidden
        playAgainButton.layer.cornerRadius = 8
        playAgainButton.isHidden = true
        nextQuestionButton.layer.cornerRadius = 8
        nextQuestionButton.isHidden = true
        
        // hide the quiz header
        quizTypeLbl.isHidden = true
        
        loadGameSounds()
        
        // display the choices of different available quizzes
        displayQuizOptions()
        
        // set up timer label
        timerLabelBox.layer.borderWidth = 2
        timerLabelBox.layer.borderColor = UIColor.white.cgColor
        timerLabelBox.layer.cornerRadius = 20
        
        // set lightning mode to off initially
        lightningModeSwitch.isOn = false
        timerLabelBox.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////
    // MARK: Quiz Selection
    
    // display a list of answer buttons corresponding to the different 
    // available quizzes
    func displayQuizOptions() {
        
        hideQuizCustomizations()

        questionField.text = "Please pick the quiz you would\nlike to play:"
        
        // hide or show the relevant screen elements
        correctLabel.isHidden = true
        playAgainButton.isHidden = true
        nextQuestionButton.isHidden = true
        lightningModeSwitch.isHidden = false
        lightningModeLabel.isHidden = false

        // make sure to reset any lingering progress from previous rounds
        model.resetModel()
        
        refreshTimerLabel()
        
        // clear out any lingering buttons from previous activity
        clearOutAnswerButtons()
        
        // iterate through the game types generating option buttons
        for option in QuestionsModel.GameType.allValues {
            
            // generate a button to use
            let button = getAnswerButton(label: option.description())
            
            // tag it for use in response detection later
            button.tag = QuestionsModel.GameType.allValues.index(of: option)!
            
            // specify the method to call on button touch
            button.addTarget(self, action: #selector(onChooseQuizOption(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            
            // keep a reference to it for indicating response later
            answerButtons.append(button)
        }
    }
    
    // customize the GUI for the quiz selected
    func showQuizCustomizations() {
        
        if let gameType = model.gameType {
            
             // set the quiz header to the description of the game type
            quizTypeLbl.text = gameType.description()
            quizTypeLbl.isHidden = false
            
            // set the background image to an image related to the quiz selected
            if let filename = gameType.backgroundImage() {

                bgImage.image = UIImage(named: filename)
                
            } else {
                
                bgImage.image = nil
            }
            
        } else {
            
            hideQuizCustomizations()
        }
    }
    
    // hide the quiz customizations
    func hideQuizCustomizations() {
        
        quizTypeLbl.isHidden = true
        bgImage.image = nil
    }
    
    // method called when a quiz option (game type) is selected
    func onChooseQuizOption(_ sender: UIButton) {
        
        // only move forward if the sender's tag exists as an index of the game type list
        if QuestionsModel.GameType.allValues.indices.contains(sender.tag) {
            
            lightningModeSwitch.isHidden = true
            lightningModeLabel.isHidden = true
            
            disableAnswerButtons()
            indicateResponse(answerButton: sender)
            
            // set the desired game type
            let desiredQuiz = QuestionsModel.GameType.allValues[sender.tag]
            model.gameType = desiredQuiz
            
            // Start game
            perform(#selector(ViewController.startQuiz), with: nil, afterDelay: 1.0)
        }
    }
    
    // called to kick off the quiz
    func startQuiz() {
        
        showQuizCustomizations()
        playGameStartSound()
        
        // display a question
        startRound()
    }
    

    

    /////////////////////////////////////////////////////////////////
    // MARK: Answer Button Creation and Handling

    // remove any buttons in the stack view
    // remove any buttons we kept a reference to in the answerButtons array
    func clearOutAnswerButtons() {
        
        for subview in stackView.subviews {
            
            subview.removeFromSuperview()
        }
        
        answerButtons.removeAll()
    }
    
    // just a factory method to create a standard answer button
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
    
    // disable all answer buttons
    func disableAnswerButtons() {
        
        for button in answerButtons {
            
            button.isEnabled = false
        }
    }
    
    // deemphasize all answer buttons
    // but if it is the correct button leave the text white
    // also indicate if the response was correct or not with 
    // a background color change
    func indicateResponse(answerButton: UIButton?) {
        
        // iterate through all the buttons
        for button in answerButtons {
            
            // deemphasize
            button.backgroundColor = ViewController.deEmphasizedButtonBgColor
            
            // if this was the answer buttons
            if button === answerButton {
                
                // fetch the correct answer from the model
                if let correctAnswer = model.getCorrectAnswerForCurrentQuestion() {
                    
                    // change background color based on if the answer was correct or not
                    if let answerButton = answerButton,
                        correctAnswer == answerButton.tag {
                        button.backgroundColor = ViewController.answerBGColorCorrect
                    } else {
                        button.backgroundColor = ViewController.answerBGColorIncorrect
                    }
                }
                
            } else {
                
                button.setTitleColor(UIColor(white: 1.0, alpha: 0.3), for: .normal)
            }
        }
    }

    
    
    
    /////////////////////////////////////////////////////////////////
    // MARK: Question Processing
    
    // handle displaying the next question and its answer buttons
    func startRound() {

        // hide the irrelevant screen elements (if they aren't already hidden)
        playAgainButton.isHidden = true
        nextQuestionButton.isHidden = true
        correctLabel.isHidden = true
        
        clearOutAnswerButtons()
        
        // get a new question from the model
        if let question = model.getNextQuestion() {
            
            // show the question wording
            questionField.text = question.wording
            
            // initialize the tag counter
            // this tag is used later to recognize which answer button responded
            var tagNumber = 1
            
            // iterate through the different answers
            for answer in question.answers {
                
                // generate an answer button to use
                let button = getAnswerButton(label: answer)
                
                // tag it for use in response detection later
                button.tag = tagNumber
                
                // increment the tag counter
                tagNumber += 1
                
                // specify the method to call on button touch
                button.addTarget(self, action: #selector(checkAnswer(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
                
                // keep a reference to it for indicating response later
                answerButtons.append(button)
            }
            
            // only do this bit if we are in lightning mode
            if model.lightningMode {
                
                model.resetTimer()
                refreshTimerLabel()
                
                // wait one second then decrement the counter
                perform(#selector(ViewController.decrementCounter), with: nil, afterDelay: 1.0)
            }
            

        } else {
            
            // if no question could be generated (perhaps all questions have been used)
            // then ask the player to start over
            questionField.text = "Oops! Couldn't generate a new question. Please try starting over."
            playAgainButton.isHidden = false
        }
    }
    
    // update the label with model's current value
    func refreshTimerLabel() {
        
        timerLabel.text = String(model.secondsRemaining)
    }
    
    // decrement the counter and determine if we have run out of time
    func decrementCounter() {
        
        // decrement number of seconds
        model.secondsRemaining -= 1
        
        // have we run out of time?
        if model.secondsRemaining <= 0 {

            // ensure timer never goes below zero
            model.secondsRemaining = 0
            
            refreshTimerLabel()
            
            // ok, so we ran out of time
            checkAnswer(nil)
        
        } else {
            
            refreshTimerLabel()

            // wait one second then decrement the counter again
            perform(#selector(ViewController.decrementCounter), with: nil, afterDelay: 1.0)
        }
    }
    
    // evaluate response from answer button
    func checkAnswer(_ sender: UIButton?) {
        
        if model.lightningMode {
            
            // make sure that the perform selector will not be called again for now
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.decrementCounter), object: nil)
        }
        
        disableAnswerButtons()
        indicateResponse(answerButton: sender)
        
        // unwrap the optional sender
        if let sender = sender {
            
            // ask the model if this response was correct
            if model.isCorrectResponse(response: sender.tag) {
                
                // increment the number of correct answers
                model.numberOfCorrectAnswers += 1
                
                // correct feedback
                correctLabel.text = "Correct!"
                correctLabel.textColor = ViewController.correctAnswerTextColor
                playCorrectSound()
                
            } else {
                
                // incorrect feedback
                correctLabel.text = "Sorry, that's not it."
                correctLabel.textColor = ViewController.incorrectAnswerTextColor
                playIncorrectSound()
            }
            
        } else {
            
            // sender was nil, so if we are also in lightning mode
            // that means the player ran out of time before selecting an answer
            if model.lightningMode {
                
                // time's up feedback
                correctLabel.text = "Times Up!"
                correctLabel.textColor = ViewController.incorrectAnswerTextColor
                playIncorrectSound()
            }
        }
        
        // show the feedback label
        correctLabel.isHidden = false
        
        // increment the number of questions asked
        model.numberOfQuestionsAnswered += 1
        
        // pause for a moment then do whatever comes next
        perform(#selector(ViewController.doWhatsNext), with: nil, afterDelay: 2.0)
    }

    // decide if we have finished the quiz or not
    func doWhatsNext() {
        
        // reinforce what the correct answer was
        indicateCorrectAnswer()
        
        if model.numberOfQuestionsAnswered == model.numberOfQuestionsPerRound {
            
            // we've reached the end of the quiz
            endQuiz()
            
        } else {
            
            // we're ready for the next question
            nextQuestionButton.isHidden = false
        }
    }
    
    // indicate the correct answer by changing the background color
    func indicateCorrectAnswer() {
        
        if let correctAnswer = model.getCorrectAnswerForCurrentQuestion() {
            
            for button in answerButtons {
                
                if button.tag == correctAnswer {
                    
                    button.backgroundColor = UIColor.TMRGBA(red: 80, green: 255, blue: 80, alpha: 150)
                    button.setTitleColor(UIColor.white, for: .normal)
                    break
                }
            }
        }
    }
    
    @IBAction func onNextQuestion() {
        startRound()
    }
    

    
    
    /////////////////////////////////////////////////////////////////
    // MARK: End of Round Processing
    
    func endQuiz() {
        
        nextQuestionButton.isHidden = true
        
        // Display play again button
        playAgainButton.isHidden = false
        
        // figure out what a half decent score would be
        let threshold = Int(model.numberOfQuestionsPerRound / 2)
        
        // assess the player's performance
        if model.numberOfCorrectAnswers == model.numberOfQuestionsPerRound {
            
            // perfect score feedback
            questionField.text = "Wow, perfect score!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"
            
        } else if model.numberOfCorrectAnswers > threshold {
            
            // good feedback
            questionField.text = "Way to go!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"
            
        } else {
            
            // not so great feedback
            questionField.text = "Better luck next time!\nYou got \(model.numberOfCorrectAnswers) out of \(model.numberOfQuestionsAnswered) correct!"
            
        }
    }
    
    // handle play again button
    @IBAction func playAgain() {
        
        displayQuizOptions()
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////
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

