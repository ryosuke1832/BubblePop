//
//  BubbleView.swift
//  BubblePop
//
//  Created by user on 2025/04/05.
//

import SwiftUI


struct BubbleView: View {
    let bubble: Bubble
    @ObservedObject var gameManager: GameManager

    
    var body: some View {
        ZStack{
            Circle()
                .fill(bubble.color)
                .frame(width: 80, height: 80)
            
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [.white.opacity(0.7), .clear]), center: .topTrailing, startRadius: 0, endRadius: 100
                ))
                .frame(width: 20, height: 20)
                .offset(x: 10, y: -10)
                .blur(radius: 3)
                .opacity(bubble.isPopped ? 0 : 1)


        }
        .frame(width: 50, height: 50)
        .position(bubble.position)
        .onTapGesture {
            if !bubble.isPopped {
                gameManager.popBubble(bubble)
            }
        }

    }
}

    
