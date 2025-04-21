//
//  GameView.swift
//  BubblePop
//
//  Created by user on 2025/04/02.
//

import SwiftUI


struct GameView: View {
    @ObservedObject var gameManager:GameManager
    @State private var showCountdown: Bool = true
    
    
    var body: some View {
            ZStack{
                Color.white.ignoresSafeArea()

                if !showCountdown{
                    ZStack{
    //                    display bubbles
                        ForEach(gameManager.bubbles) { bubble in
                            if !bubble.isPopped {
                                BubbleView(bubble: bubble,gameManager: gameManager)
                                    .transition(.opacity)
                            }
                        }
                        
    //                    display point
                        ForEach(gameManager.activePoints){ point in
                            PointEffectView(point: point)
                        }
                        
                        ScoreView(score: gameManager.score,time:gameManager.timeRemaining,highScore: gameManager.getHighScore())
                        
                    }


                }
                
//                display gameover view
                if gameManager.isGameOver{
                    GameoverView(gameManager: gameManager)
                        .transition(.scale)
                        .zIndex(1)
                }
                
//                display start countdown
                if showCountdown{
                    CountdownView(showCountdown: $showCountdown){
                        gameManager.startGame()
                    }
                    .zIndex(2)
                    .transition(.opacity)
                }
            }

            .animation(.easeInOut(duration:0.3),value: gameManager.isGameOver)
            .navigationBarBackButtonHidden(true)

            
        }
        
            

    
    
}

    
