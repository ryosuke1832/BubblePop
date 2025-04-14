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
    //                    display point
                            ForEach(gameManager.activePoints){ point in
                                Text("+\(point.points)")
                                    .font(.system(size: 24,weight:.bold))
                                    .foregroundColor(.green)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                    .position(x:point.position.x,y:point.position.y + CGFloat(point.offset)
                                    )
                                    .opacity(point.opacity)
                                    .onAppear{
                                        withAnimation(.easeOut(duration:1)){
                                            if let index = gameManager.activePoints.firstIndex(where: {$0.id == point.id}){
                                                gameManager.activePoints[index].offset = -50
                                                gameManager.activePoints[index].opacity = 0
                                            }
                                        }
                                    }
                                
                                
                            }
                            
                            
                        }
                        
                        ScoreView(score: gameManager.score,time:gameManager.timeRemaining)

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

    
