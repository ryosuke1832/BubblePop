
//
//  GameManager.swift
//  BubblePop
//
//  Created by user on 2025/04/05.
//

import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var score: Int = 0
    @Published  var bubbles:[Bubble] = []
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
    private var lastPoppedScore: Double?
    private let fileName = "ScoreData.json"
    
    private var initialTimeLimit: Int = 60
    
    
    private var scoresFileURL: URL{
        let documentDirectroy = FileManager.default.urls(for:.documentDirectory,in:.userDomainMask).first!
        return documentDirectroy.appendingPathComponent(fileName)
    }

    deinit {
        coundownTimer?.invalidate()
        bubbleSpawnTimer?.invalidate()
    }
    
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
        let timeProgress = Double(initialTimeLimit - timeRemaining) / Double(initialTimeLimit)
        let speedFactor = 1.0 + timeProgress * speedCoefficient
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
        
        let baseSpeed: Double = 75.0
        let speedCoefficient: Double = 2.5
        let timeProgress = Double(initialTimeLimit - timeRemaining) / Double(initialTimeLimit)
        let speedFactor = 1.0 + timeProgress * speedCoefficient
        let currentSpeed = baseSpeed * speedFactor
        
        let startY: Double = screenheight + 50
        let endY: Double = -150
        let totalDistance = startY - endY
        let screenPassTime = totalDistance / currentSpeed

        let safetyFactor = 0.15
        
        let dynamicMinTime = screenPassTime * safetyFactor
        
        let timeSinceLatestBubble = Date().timeIntervalSince(latestOverlappingBubble!.creationTime)

        return timeSinceLatestBubble < dynamicMinTime
    }
    
    
    private func moveBubble(withID id:UUID,to newPosition:CGPoint){
        if let index = bubbles.firstIndex(where: {$0.id == id}){
            DispatchQueue.main.async{[weak self] in
                guard let self = self else {return}
                var updatedBubble = self.bubbles[index]
                updatedBubble.position = newPosition
                self.bubbles[index] = updatedBubble
                
            }
        }
    }
    

    
    func popBubble(_ bubble: Bubble,position:CGPoint){
        guard let index = bubbles.firstIndex(where: {$0.id == bubble.id}),!bubbles[index].isPopped else {return}

        bubbles[index].isPopped = true
        
        let pointToAdd = self.calculatePoints(bubble, at:index)
        
        createPointEffect(at:position, points: pointToAdd)
        
        scheduledBubbleRemoval(bubble)
    }
    
    
    
//        calculate point
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
        lastPoppedScore = Double(pointToAdd)
        
        return pointToAdd
    }
    
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
    
    private func scheduledBubbleRemoval(_ bubble:Bubble){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){ [weak self] in
            guard let self = self else {return}
            
            if let index = self.bubbles.firstIndex(where: {$0.id == bubble.id}){
                self.bubbles.remove(at: index)
            }
        }
    }
    
    private func scheduledPointEffectRemoval(_ pointEffect:PointEffect){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [weak self] in
            guard let self = self else {return}
            
            if let pointIndex = self.activePoints.firstIndex(where: {$0.id == pointEffect.id}){
                self.activePoints.remove(at: pointIndex)
                print("remove pointEffect")
            }
        }
    }
    
    func getHighScore() -> Int {
        let scores = loadScores()
        let sortedScores = scores.sorted { $0.score > $1.score }
        return sortedScores.first?.score ?? 0
    }
    
    
}
