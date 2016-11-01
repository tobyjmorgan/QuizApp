//
//  QuestionsModel.swift
//  TrueFalseStarter
//
//  Created by redBred LLC on 10/27/16.
//  Copyright © 2016 redBred LLC. All rights reserved.
//

import Foundation
import GameKit

struct QuestionsModel {
    
    // enumeration to distinguish between different available quiz types
    enum GameType {
        case politicalHistory
        case customQuiz
        case dynamicMath
        
        // creating a convenient way to count or iterate the cases
        static let allValues = [GameType.politicalHistory, GameType.customQuiz, GameType.dynamicMath]
        
        // providing useful external descriptions for each case
        func description() -> String {
            
            switch self {
            case .politicalHistory:
                return "Treehouse Quiz"
            case .customQuiz:
                return "My Swift Quiz"
            case .dynamicMath:
                return "My Math Quiz"
            }
        }
        
        // providing background image filename if appropriate
        func backgroundImage() -> String? {
            
            switch self {
            case .politicalHistory:
                return "treehouse.png"
            case .customQuiz:
                return "swift.png"
            case .dynamicMath:
                return "math.png"
            }
        }
    }
    
    // toggle value for lightning mode
    var lightningMode: Bool = false
    
    // variable not constant because this can vary based on the type of game being played
    var numberOfQuestionsPerRound = 4
    
    // keeping track of the questions already asked, to avoid repetition within a round
    private var usedQuestionIndexes: [Int] = []
    
    // will be the collection of available questions which will change based on game type
    private var questions: [Question] = []
    
    // the current active question
    private var currentQuestion: Question?
    
    // variables to keep track of players progress
    var numberOfQuestionsAnswered: Int = 0
    var numberOfCorrectAnswers: Int = 0
    var secondsRemaining: Int = 15
    
    // this variable determines which type of quiz is being played
    // the didSet code allows the set of questions to be automatically
    // changed whenever the game type is changed
    var gameType: GameType? {

        didSet {
            
            // if there is no change in the value, then do nothing
            guard gameType != oldValue else {
                return
            }

            // a change in game type should reset the player progress
            resetModel()
            
            // unwrap optional
            if let gameType = gameType {
                
                // set up available questions based on GameType
                switch gameType {
                                        
                case .politicalHistory:
                    numberOfQuestionsPerRound = 4
                    questions = [
                        Question(wording: "This was the only US President to serve more than two consecutive terms.", answers: ["George Washington", "Franklin D. Roosevelt", "Woodrow Wilson", "Andrew Jackson"], correctAnswer: 2),
                        Question(wording: "Which of the following countries has the most residents?", answers: ["Nigeria", "Russia", "Iran", "Vietnam"], correctAnswer: 1),
                        Question(wording: "In what year was the United Nations founded?", answers: ["1918", "1919", "1945", "1954"], correctAnswer: 3),
                        Question(wording: "The Titanic departed from the United Kingdom, where was it supposed to arrive?", answers: ["Paris", "Washington D.C.", "New York City", "Boston"], correctAnswer: 3),
                        Question(wording: "Which nation produces the most oil?", answers: ["Iran", "Iraq", "Brazil", "Canada"], correctAnswer: 4),
                        Question(wording: "Which country has most recently won consecutive World Cups in Soccer?", answers: ["Italy", "Brazil", "Argetina", "Spain"], correctAnswer: 2),
                        Question(wording: "Which of the following rivers is longest?", answers: ["Yangtze", "Mississippi", "Congo", "Mekong"], correctAnswer: 2),
                        Question(wording: "Which city is the oldest?", answers: ["Mexico City", "Cape Town", "San Juan", "Sydney"], correctAnswer: 1),
                        Question(wording: "Which country was the first to allow women to vote in national elections?", answers: ["Poland", "United States", "Sweden", "Senegal"], correctAnswer: 1),
                        Question(wording: "Which of these countries won the most medals in the 2012 Summer Games?", answers: ["France", "Germany", "Japan", "Great Britian"], correctAnswer: 4)
                    ]
                    
                case .customQuiz:
                    numberOfQuestionsPerRound = 4
                    questions = [
                        Question(wording: "In which year was Swift publicly released?", answers: ["2013", "2014", "2015"], correctAnswer: 2),
                        Question(wording: "Who was Swift initially designed by?", answers: ["Steve Jobs", "Tim Cook", "Chris Lattner", "Andy Hertzfeld"], correctAnswer: 3),
                        Question(wording: "Swift is a dynamically typed language.", answers: ["True", "False"], correctAnswer: 2),
                        Question(wording: "Swift is a protocol-oriented language.", answers: ["True", "False"], correctAnswer: 1),
                        Question(wording: "Swift is an object-oriented language.", answers: ["True", "False"], correctAnswer: 1),
                        Question(wording: "A struct in Swift is a...", answers: ["Reference Type", "Value Type", "Protocol Type"], correctAnswer: 2),
                        Question(wording: "The Swift programming language is...", answers: ["Safe", "Fast", "Expressive", "All of the above"], correctAnswer: 4)
                        
                    ]
                    
                case .dynamicMath:
                    numberOfQuestionsPerRound = 10
                    questions = []
                    
                }
                
            } else {
                
                // dynamic math quiz does not have a predefined set of questions
                // we will generate math problems dynamically if this is the selected game type
                questions = []
            }
            
        }
    }
    
    // reset player progress
    mutating func resetModel() {
     
        // clear out in-progress stuff
        usedQuestionIndexes = []
        currentQuestion = nil
        numberOfQuestionsAnswered = 0
        numberOfCorrectAnswers = 0
        
        resetTimer()
    }
    
    // determines the next question
    // sets it as the current question
    // and returns the question to the caller
    mutating func getNextQuestion() -> Question? {
        
        if gameType == .dynamicMath {
            
            // generate math question
            
            currentQuestion = generateMathQuestion()
            
            return currentQuestion
            
        } else {
            
            // if there are no questions set up, or if we have used all the available questions
            // then there's nothing we can do here so return a nil question
            guard questions.count > 0 &&
                usedQuestionIndexes.count < questions.count else {
                return nil
            }
            
            var newQuestionIndex: Int
            
            // keep picking a random question index, until we are sure it hasn't already been used
            repeat {
                newQuestionIndex = GKRandomSource.sharedRandom().nextInt(upperBound: questions.count)
            } while usedQuestionIndexes.contains(newQuestionIndex)
            
            // capture this index as a question index we have already used (for next time)
            usedQuestionIndexes.append(newQuestionIndex)
            
            // now get the actual question ready to be returned
            currentQuestion = questions[newQuestionIndex]

            return currentQuestion
        }
    }
    
    // determines if the response was the correct response
    func isCorrectResponse(response: Int) -> Bool {
        
        // unwrap the optional
        if let currentQuestion = currentQuestion {
            
            // validate the response is the correct one
            if currentQuestion.correctAnswer == response {
                
                return true
            }
        }
        
        return false
    }

    func getCorrectAnswerForCurrentQuestion() -> Int? {
        
        // unwrap the optional
        if let currentQuestion = currentQuestion {
            
            return currentQuestion.correctAnswer
        }
        
        return nil
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////
    // MARK: Dynamic Math Question generation
    
    // enumeration to capture the math operators that will be available
    // for the dynamic math quiz questions
    enum MathOperator: Int {
        case add
        case subtract
        case multiply
        case divide
        
        // creating a convenient way to count or iterate the cases
        static let allValues = [MathOperator.add, MathOperator.subtract, MathOperator.multiply, MathOperator.divide]
        
        // providing useful external descriptions for each case
        func description() -> String {
            
            switch self {
            case .add:
                return "+"
            case .subtract:
                return "-"
            case .multiply:
                return "*"
            case .divide:
                return "/"
            }
        }
    }
    
    // create a random answer based on the actual answer, but that does not match
    // any other answers previously generated (existing answers array)
    func getAnIncorrectAnswer(correctAnswer: Int, existingAnswers: [Int]) -> Int {
        
        var candidateAnswer: Int
        
        repeat {
            candidateAnswer = correctAnswer + GKRandomSource.sharedRandom().nextInt(upperBound: 20) - 10
        } while existingAnswers.contains(candidateAnswer)
        
        return candidateAnswer
    }
    
    // get the full answer set to be used, with randomly generated incorrect answers and
    // the correct answer randomly placed in the answer set
    // we are also returning the correct answer's position in the answer set
    // (using a tuple to return both the answer set and the answer position at the same time)
    // (love those tuples!)
    func getAnswerSet(correctAnswer: Int) -> ([String], Int) {
        
        let wrongAnswerA = getAnIncorrectAnswer(correctAnswer: correctAnswer, existingAnswers: [correctAnswer])
        let wrongAnswerB = getAnIncorrectAnswer(correctAnswer: correctAnswer, existingAnswers: [correctAnswer, wrongAnswerA])
        let wrongAnswerC = getAnIncorrectAnswer(correctAnswer: correctAnswer, existingAnswers: [correctAnswer, wrongAnswerA, wrongAnswerB])
        
        // put the three wrong answers in an array of strings
        var answers = [String(wrongAnswerA), String(wrongAnswerB), String(wrongAnswerC)]
        
        // randomly create the index position to insert the correct answer
        let answerPosition = GKRandomSource.sharedRandom().nextInt(upperBound: answers.count + 1)

        // insert the correct answer
        answers.insert(String(correctAnswer), at: answerPosition)
        
        // N.B. adding one the the answer position, because the conventioned used by
        // all the question data in this app is the index position plus one
        // i.e. index positions (0...n), correct answer positions (1...n+1)
        return (answers, answerPosition + 1)
    }
    
    // generate a dynamically created math problem, with a set of answers, only one of which is correct
    func generateMathQuestion() -> Question {
     
        // randomly pick the operator to use
        let randomOperator = MathOperator(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: MathOperator.allValues.count))!
        
        // randomly pick two operands to use
        let operandA = GKRandomSource.sharedRandom().nextInt(upperBound: 19) + 1 // no zeroes
        let operandB = GKRandomSource.sharedRandom().nextInt(upperBound: 19) + 1 // no zeroes
        
        // based on the operator, create and return a Quesiton object
        switch randomOperator {
        case .add:
            let correctAnswer = operandA + operandB
            let (answers, answerPosition) = getAnswerSet(correctAnswer: correctAnswer)
            let wording = "Solve: \(operandA) \(randomOperator.description()) \(operandB) ="
            return Question(wording: wording, answers: answers, correctAnswer: answerPosition)
            
        case .subtract:
            let correctAnswer = operandA - operandB
            let (answers, answerPosition) = getAnswerSet(correctAnswer: correctAnswer)
            let wording = "Solve: \(operandA) \(randomOperator.description()) \(operandB) ="
            return Question(wording: wording, answers: answers, correctAnswer: answerPosition)
            
        case .multiply:
            let correctAnswer = operandA * operandB
            let (answers, answerPosition) = getAnswerSet(correctAnswer: correctAnswer)
            let wording = "Solve: \(operandA) \(randomOperator.description()) \(operandB) ="
            return Question(wording: wording, answers: answers, correctAnswer: answerPosition)
            
        case .divide:
            // division questions are a little different
            // to avoid floating point answers, the result of multiplying the operands
            // will appear in the question along with one of the operands
            // and the other operand will appear as the correct answer
            let tmp = operandA * operandB
            let correctAnswer = operandB
            let (answers, answerPosition) = getAnswerSet(correctAnswer: correctAnswer)
            let wording = "Solve: \(tmp) \(randomOperator.description()) \(operandA) ="
            return Question(wording: wording, answers: answers, correctAnswer: answerPosition)
            
        }
    }
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////
    // MARK: Lightning Mode 
    
    mutating func resetTimer() {
        secondsRemaining = 15
    }    
}
