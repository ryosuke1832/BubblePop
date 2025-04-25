
//
//  GameManager.swift
//  BubblePop
//
//  Created by user on 2025/04/05.
//

import Foundation
import SwiftUI

/**
 * GameManager
 *
 * Main controller class for the BubblePop game that manages:
 * - Game state (score, timer, bubbles)
 * - Bubble generation and physical placement
 * - User interaction handling
 * - Score calculation and high score management
 * - Game session lifecycle
 */

class GameManager: ObservableObject {
    @Published var score: Int = 0
    @Published var bubbles:[Bubble] = []
    @Published var timeRemaining:Int = 60
    @Published var maxBubbles:Int = 15
    @Published var playerName: String = ""
    @Published var isGameOver:Bool = false
    @Published var activePoints:[PointEffect] = []
    
    private var coundownTimer: Timer?
    private var bubbleSpawnTimer: Timer?
    
    private let screenwidth = UIScreen.main.bounds.width
    private let screenheight = UIScreen.main.bounds.height
    
    private let bubbleSpawnInterval = 0.3
    private var lastPoppedColor: Color?
    private var lastPoppedScore: Int? = nil
    private let fileName = "ScoreData.json"
    
    private var initialTimeLimit: Int = 60
    
    
    private var scoresFileURL: URL{
        let documentDirectroy = FileManager.default.urls(for:.documentDirectory,in:.userDomainMask).first!
        return documentDirectroy.appendingPathComponent(fileName)
    }
    
    
// MARK: -Lifecycle
    deinit {
        coundownTimer?.invalidate()
        bubbleSpawnTimer?.invalidate()
    }
    
    
// MARK: -Game control
    func startGame() {
        resetGame()
        startSpawningBubbles()
        startCountDown()
    }
    
    func resetGame(){
        coundownTimer?.invalidate()
        bubbleSpawnTimer?.invalidate()
        score = 0
        bubbles.removeAll()
        activePoints.removeAll()
        isGameOver = false
        lastPoppedColor = nil
        lastPoppedScore = nil
        initialTimeLimit = timeRemaining
    }
    
    
// MARK: -Score management
    /**
     * Saves the current score to persistent storage
     *
     * Appends the player name and final score to the JSON file
     */
    func saveScore(){
        var scores = loadScores()
        let newScore = PlayerScore(name: playerName, score: score)
        scores.append(newScore)
        
        do {
            let data = try JSONEncoder().encode(scores)
            try data.write(to: scoresFileURL)
            print("Score saved successfully at \(scoresFileURL)")
        } catch {
            print("Error saving scores: \(error.localizedDescription)")
        }
    }
    

    /**
     * Loads saved score data from persistent storage
     *
     * @return Array of all saved player scores
     */
    func loadScores() -> [PlayerScore]{
        guard FileManager.default.fileExists(atPath: scoresFileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: scoresFileURL)
            return try JSONDecoder().decode([PlayerScore].self, from: data)
        } catch {
            print("Error loading scores: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func getHighScore() -> Int {
        let scores = loadScores()
        let sortedScores = scores.sorted { $0.score > $1.score } //sort high score
        return sortedScores.first?.score ?? 0
    }



// MARK: - Timer Functions

    /**
     * Starts the bubble generation timer
     *
     * Creates a timer that spawns bubbles at regular intervals
     * as long as the current bubble count is below maximum
     */
    func startSpawningBubbles(){
        bubbleSpawnTimer?.invalidate()
        
        bubbleSpawnTimer = Timer.scheduledTimer(withTimeInterval: bubbleSpawnInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.bubbles.count < self.maxBubbles {
                self.spawnBubbles()
            }
            
        }
        
        
    }
    
    
    
    /**
     * Starts the game countdown timer
     *
     * Creates a timer that decrements the remaining time every second
     * When time reaches zero, the game ends and score is saved
     */
    private func startCountDown(){
        coundownTimer?.invalidate()
        
        coundownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] timer in
            guard let self = self  else {
                timer.invalidate()
                return
            }
            
            if self.timeRemaining > 0{
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.bubbleSpawnTimer?.invalidate()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.saveScore()
                    self.isGameOver = true
                }
            }
        }
        
    }
    
    
// MARK: - Bubble Management
 
    
    /**
     * Spawns a new bubble on the screen
     *
     * - Selects bubble color and points based on probability distribution
     * - Calculates position to avoid overlap with existing bubbles
     * - Sets up animation for bubble movement
     * - Schedules automatic removal when the bubble exits the screen
     */
    private func spawnBubbles(){
        let colorDistribution: [(color: Color, points: Int, threshold: Double)] = [
            ( Color(red: 1.0, green: 0.1, blue: 0.1), 1, 0.40),
            ( Color(red: 1.0, green: 0.7, blue: 0.9), 2, 0.70),  // 40% + 30%
            (.green, 5, 0.85),  // 70% + 15%
            (.blue, 8, 0.95),   // 85% + 10%
            (.black, 10, 1.0)  // 95% + 5%
        ]
        let randomValue = Double.random(in: 0..<1)
        
        guard let selected = colorDistribution.first(where: {$0.threshold > randomValue}) else {
            return
        }
        let bubbleRadius:CGFloat = 40
        let maxAttempts = 20
        var currentAttempt = 0
        var validPositionFound = false
        var randomXposition : CGFloat = 0
        
        let baseSpeed :Double = 75.0
        let speedCoefficient:Double = 2.5
        
        var adjustedTimeProgress: Double
        if initialTimeLimit < 60 {
            let startOffset = (60.0 - Double(initialTimeLimit)) / 60.0
            let currentProgress = Double(initialTimeLimit - timeRemaining) / Double(initialTimeLimit)
            adjustedTimeProgress = startOffset + currentProgress * (1.0 - startOffset)
            adjustedTimeProgress = min(max(adjustedTimeProgress, 0.0), 1.0)
        } else {
            adjustedTimeProgress = Double(initialTimeLimit - timeRemaining) / Double(initialTimeLimit)
        }
        
        let maxSpeedFactor: Double = 3.0
        let speedFactor = min(1.0 + adjustedTimeProgress * speedCoefficient, maxSpeedFactor)
        let randomSpeed = baseSpeed * speedFactor
        
        let startY:Double = screenheight + 50
        let endY:Double = -150
        let totalDistance = startY - endY
        
        while currentAttempt < maxAttempts && !validPositionFound {
            randomXposition = CGFloat.random(in: (bubbleRadius + 10)..<(screenwidth - bubbleRadius - 10))
            
            let overlapping = findOverlappingBubbles(xPosition:randomXposition,radius:bubbleRadius)
            
            if !overlapping {
                validPositionFound = true
            }

            currentAttempt += 1
        }
        
        if !validPositionFound {
            return
        }
        
        let animationDuration = totalDistance / randomSpeed
        let initialPosition = CGPoint(x:randomXposition,y: startY)
        let newBubble = Bubble(position: initialPosition, color: selected.color, speed: randomSpeed,point:selected.points)
        
        bubbles.append(newBubble)
        
        withAnimation(.linear(duration: animationDuration)) {
            if let index = bubbles.firstIndex(where: {$0.id == newBubble.id}) {
                var updatedBubble = bubbles[index]
                updatedBubble.position = CGPoint(x:randomXposition,y:endY)
                bubbles[index] = updatedBubble
            }
        }
        
        let timeToExitScreen = animationDuration + 0.1
        Timer.scheduledTimer(withTimeInterval: timeToExitScreen, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            
            if let index = self.bubbles.firstIndex(where: { $0.id == newBubble.id }) {
                if !self.bubbles[index].isPopped {
                    self.bubbles.remove(at: index)
                }
            }
        }
        
        
    

    }
    
    
    
    /**
     * Checks if a new bubble at the specified position would overlap with existing bubbles
     *
     * @param xPosition X-coordinate for the new bubble
     * @param radius Radius of the bubble
     * @return true if overlap detected, false otherwise
     */
    private func findOverlappingBubbles(xPosition:CGFloat,radius:CGFloat) -> Bool {
        let bubbleDiameter = radius * 2
        var latestOverlappingBubble: Bubble?
        
        for bubble in bubbles {
            if bubble.isPopped {
                continue
            }
            let xDistance = abs(xPosition - bubble.position.x)
            
            
            if xDistance < bubbleDiameter {
                if latestOverlappingBubble == nil || bubble.creationTime > latestOverlappingBubble!.creationTime  {
                    latestOverlappingBubble = bubble
                }
            }
        }
        
        if latestOverlappingBubble == nil {
            return false
        }
        
        let safetyFactor = 0.2
        let baseSpeed: Double = 75.0
        let speedCoefficient: Double = 2.5
        
        var adjustedTimeProgress:Double
        if initialTimeLimit < 60 {
            // For short game times, start at the equivalent of a 60-second game
            let startOffset = (60.0 - Double(initialTimeLimit)) / 60.0
            let currentProgress = Double(initialTimeLimit - timeRemaining) / Double(initialTimeLimit)
            adjustedTimeProgress = startOffset + currentProgress * (1.0 - startOffset)
            adjustedTimeProgress = min(max(adjustedTimeProgress, 0.0), 1.0)
        } else {
            // For normal 60-second games, calculation as before
            adjustedTimeProgress = Double(initialTimeLimit - timeRemaining) / Double(initialTimeLimit)
        }


        let maxSpeedFactor: Double = 3.0
        let speedFactor = min(1.0 + adjustedTimeProgress * speedCoefficient, maxSpeedFactor)
        let currentSpeed = baseSpeed * speedFactor
        
        let startY: Double = screenheight + 50
        let endY: Double = -150
        let totalDistance = startY - endY
        let screenPassTime = totalDistance / currentSpeed


        
        let dynamicMinTime = screenPassTime * safetyFactor
        
        let timeSinceLatestBubble = Date().timeIntervalSince(latestOverlappingBubble!.creationTime)

        return timeSinceLatestBubble < dynamicMinTime
    }
    
    
    

// MARK: - Bubble Interaction
    
    /**
     * Pops a bubble when touched by the player
     *
     * @param bubble The bubble to pop
     * @param position The position where the bubble was popped (for point effect display)
     */
    func popBubble(_ bubble: Bubble,position:CGPoint){
        guard let index = bubbles.firstIndex(where: {$0.id == bubble.id}),!bubbles[index].isPopped else {return}

        bubbles[index].isPopped = true
        
        let pointToAdd = self.calculatePoints(bubble, at:index)
        
        createPointEffect(at:position, points: pointToAdd)
        
        scheduledBubbleRemoval(bubble)
    }
    
    
    
    /**
     * Calculates points earned for popping a bubble
     *
     * Applies a 1.5x bonus multiplier if the player pops bubbles of the same color consecutively
     *
     * @param bubble The popped bubble
     * @param index The index of the bubble in the bubbles array
     * @return The points earned
     */
    private func calculatePoints(_ bubble: Bubble,at index:Int) ->Int {
        var pointToAdd: Int
        if let lastScore = lastPoppedScore, lastPoppedColor==bubble.color{
            pointToAdd = Int(Double(lastScore) * 1.5)
        } else {
            pointToAdd = bubble.point
        }
//        update point condition
        score += pointToAdd
        lastPoppedColor = bubble.color
        lastPoppedScore = pointToAdd
        
        return pointToAdd
    }
    
    
    /**
     * Creates a floating point effect at the specified position
     *
     * @param position The position where the effect should appear
     * @param points The number of points to display
     */
    private func createPointEffect(at position:CGPoint,points:Int) {
        
//        add point effect
        let pointEffect = PointEffect(
            points: points,
            position: position
        )
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            
            self.activePoints.append(pointEffect)
            
            self.scheduledPointEffectRemoval(pointEffect)
        }
        
    }
    
    
    /**
     * Schedules removal of a popped bubble after animation completes
     *
     * @param bubble The bubble to remove
     */
    private func scheduledBubbleRemoval(_ bubble:Bubble){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){ [weak self] in
            guard let self = self else {return}
            
            if let index = self.bubbles.firstIndex(where: {$0.id == bubble.id}){
                self.bubbles.remove(at: index)
            }
        }
    }
    
    
    /**
     * Schedules removal of a point effect after animation completes
     *
     * @param pointEffect The point effect to remove
     */
    private func scheduledPointEffectRemoval(_ pointEffect:PointEffect){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [weak self] in
            guard let self = self else {return}
            
            if let pointIndex = self.activePoints.firstIndex(where: {$0.id == pointEffect.id}){
                self.activePoints.remove(at: pointIndex)
            }
        }
    }

    
    
}
