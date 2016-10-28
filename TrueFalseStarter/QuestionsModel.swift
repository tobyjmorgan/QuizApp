//
//  QuestionsModel.swift
//  TrueFalseStarter
//
//  Created by redBred LLC on 10/27/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import GameKit

struct QuestionsModel {
    
    enum GameMode {
        case original
        case politicalHistory
        case customQuiz
        case dynamicMath
        
        static let allValues = [GameMode.original, GameMode.politicalHistory, GameMode.customQuiz, GameMode.dynamicMath]
        
        func description() -> String {
            
            switch self {
            case .original:
                return "Original Quiz Questions"
            case .politicalHistory:
                return "Provided Sample Quiz Questions"
            case .customQuiz:
                return "Welsh Castles Quiz"
            case .dynamicMath:
                return "Math Quiz"
            }
        }
    }
    
    enum MathOperator: Int {
        case add
        case subtract
        case multiply
        case divide
        
        static let allValues = [MathOperator.add, MathOperator.subtract, MathOperator.multiply, MathOperator.divide]
        
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
    
    var numberOfQuestionsPerRound = 4
    
    private var usedQuestionIndexes: [Int] = []
    private var questions: [Question] = []
    private var currentQuestion: Question?
    
    var numberOfQuestionsAnswered: Int = 0
    var numberOfCorrectAnswers: Int = 0
    var secondsRemaining: Int = 15
    
    var gameMode: GameMode? {

        didSet {
            
            guard gameMode != oldValue else {
                return
            }

            resetModel()
            
            // unwrap optional
            if let gameMode = gameMode {
                
                // set up available questions based on gameMode
                switch gameMode {
                    
                case .original:
                    numberOfQuestionsPerRound = 4
                    questions = [
                        Question(wording: "Only female koalas can whistle", answers: ["True", "False"], correctAnswer: 2),
                        Question(wording: "Blue whales are technically whales", answers: ["True", "False"], correctAnswer: 1),
                        Question(wording: "Camels are cannibalistic", answers: ["True", "False"], correctAnswer: 2),
                        Question(wording: "All ducks are birds", answers: ["True", "False"], correctAnswer: 1)
                    ]
                    
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
                        Question(wording: "Only female koalas can whistle", answers: ["True", "False"], correctAnswer: 2),
                        Question(wording: "Blue whales are technically whales", answers: ["True", "False"], correctAnswer: 1),
                        Question(wording: "Camels are cannibalistic", answers: ["True", "False"], correctAnswer: 2),
                        Question(wording: "All ducks are birds", answers: ["True", "False"], correctAnswer: 1)
                    ]
                    
                case .dynamicMath:
                    numberOfQuestionsPerRound = 10
                    questions = []
                    
                }
                
            } else {
                
                questions = []
            }
            
        }
    }
    
    mutating func resetModel() {
     
        // clear out in-progress stuff
        usedQuestionIndexes = []
        currentQuestion = nil
        numberOfQuestionsAnswered = 0
        numberOfCorrectAnswers = 0
        secondsRemaining = 15
    }
    
    mutating func getNextQuestion() -> Question? {
        
        if gameMode == .dynamicMath {
            
            // generate math question
            
            currentQuestion = generateMathQuestion()
            
            return currentQuestion
            
        } else {
            
            guard questions.count > 0 else {
                return nil
            }
            
            var newQuestionIndex: Int
            
            repeat {
                newQuestionIndex = GKRandomSource.sharedRandom().nextInt(upperBound: questions.count)
            } while usedQuestionIndexes.contains(newQuestionIndex)
            
            currentQuestion = questions[newQuestionIndex]
            usedQuestionIndexes.append(newQuestionIndex)
            return currentQuestion
        }
    }
    
    func isCorrectResponse(response: Int) -> Bool {
        
        if let currentQuestion = currentQuestion {
            
            if currentQuestion.correctAnswer == response {
                
                return true
            }
        }
        
        return false
    }

    
    // MARK: Dynamic Math Question generation
    
    func getAnIncorrectAnswer(correctAnswer: Int, existingAnswers: [Int]) -> Int {
        
        var candidateAnswer: Int
        
        repeat {
            candidateAnswer = correctAnswer + GKRandomSource.sharedRandom().nextInt(upperBound: 20) - 10
        } while existingAnswers.contains(candidateAnswer)
        
        return candidateAnswer
    }
    
    func getAnswerSet(correctAnswer: Int) -> ([String], Int) {
        
        let wrongAnswerA = getAnIncorrectAnswer(correctAnswer: correctAnswer, existingAnswers: [correctAnswer])
        let wrongAnswerB = getAnIncorrectAnswer(correctAnswer: correctAnswer, existingAnswers: [correctAnswer, wrongAnswerA])
        let wrongAnswerC = getAnIncorrectAnswer(correctAnswer: correctAnswer, existingAnswers: [correctAnswer, wrongAnswerA, wrongAnswerB])
        
        var answers = [String(wrongAnswerA), String(wrongAnswerB), String(wrongAnswerC)]
        
        let answerPosition = GKRandomSource.sharedRandom().nextInt(upperBound: answers.count + 1)

        answers.insert(String(correctAnswer), at: answerPosition)
        
        return (answers, answerPosition + 1)
    }
    
    func generateMathQuestion() -> Question {
     
        let randomOperator = MathOperator(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: MathOperator.allValues.count))!
            
        let operandA = GKRandomSource.sharedRandom().nextInt(upperBound: 19) + 1 // no zeroes
        let operandB = GKRandomSource.sharedRandom().nextInt(upperBound: 19) + 1 // no zeroes
        
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
            let tmp = operandA * operandB
            let correctAnswer = operandB
            let (answers, answerPosition) = getAnswerSet(correctAnswer: correctAnswer)
            let wording = "Solve: \(tmp) \(randomOperator.description()) \(operandA) ="
            return Question(wording: wording, answers: answers, correctAnswer: answerPosition)
            
        }
    }
    
}
