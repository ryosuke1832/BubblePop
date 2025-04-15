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
    
    private let screenwidth = UIScreen.main.bounds.width
    private let screenheight = UIScreen.main.bounds.height
    private let bubbleSpawnInterval = 1.0
    private var lastPoppedColor: Color?
    private var lastPoppedScore: Double?
    private let fileName = "ScoreData.json"
    
    private var scoresFileURL: URL{
        let documentDirectroy = FileManager.default.urls(for:.documentDirectory,in:.userDomainMask).first!
        return documentDirectroy.appendingPathComponent(fileName)
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
        score = 0
        bubbles.removeAll()
        activePoints.removeAll()
        isGameOver = false
        lastPoppedColor = nil
        lastPoppedScore = nil
        
    }

    
    func startSpawningBubbles(){
        Timer.scheduledTimer(withTimeInterval: bubbleSpawnInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.isGameOver{
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
                DispatchQueue.main.async {
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
        
        let randomXposition = CGFloat.random(in: 50..<(screenwidth - 50))
        let randomSpeed = Double.random(in: 5...10)
        let initialPosition = CGPoint(x: randomXposition, y: screenheight + 50)
        var bubble = Bubble(position: initialPosition, color: selected.color, speed: randomSpeed,point:selected.points)
        bubbles.append(bubble)
        
        withAnimation(.linear (duration: randomSpeed)){
            moveBubbleToTop(&bubble)
        }
        
    }
    
    
    private func moveBubbleToTop(_ bubble: inout Bubble){
        let endPosition = CGPoint(x:bubble.position.x,y:-150)
        bubble.position = endPosition
        
        if let index = bubbles.firstIndex(where: {$0.id == bubble.id}){
            bubbles[index] = bubble
            
        }
    }
    
    func popBubble(_ bubble: Bubble,position:CGPoint){
        guard let index = bubbles.firstIndex(where: {$0.id == bubble.id}),!bubbles[index].isPopped else {return}
        
        print("Popping bubble at user specified position: \(position)")
        
        bubbles[index].isPopped = true
                
        let pointToAdd = calculatePoints(bubble, at:index)
        
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
        print("Creating point effect at position: \(position)")
        
//        add point effect
        let pointEffect = PointEffect(
            points: points,
            position: position
        )
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            
            self.activePoints.append(pointEffect)
            print("add pointEffect")
            
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
    
    
}
