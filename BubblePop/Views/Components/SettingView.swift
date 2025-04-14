//
//  settingView.swift
//  BubblePop
//
//  Created by user on 2025/04/07.
//

import SwiftUI

struct SettingView: View {
    @Binding var showSetting: Bool
    @ObservedObject var gameManager:GameManager
    
    
    var body: some View {
        
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture{
                        showSetting = false
                }
            
            VStack(spacing: 30){
                Text("Setting")
                    .font(.title)
                    .padding(.top)
                
                VStack(alignment: .leading){
                    Text("Time Limit")
                    Slider(value: Binding(
                        get:{Double(gameManager.timeRemaining)},
                        set:{gameManager.timeRemaining = Int($0)}
                    ), in: 15...60,step: 1)
                    Text("\(gameManager.timeRemaining)")
                }
                
                VStack(alignment: .leading){
                    Text("Max Bubbles")
                    Slider(value: Binding(
                        get:{Double(gameManager.maxBubbles)},
                        set:{gameManager.maxBubbles = Int($0)}
                    ), in: 1...15,step: 1)
                    Text("\(gameManager.maxBubbles)")
                }
                Button("Close") {
                    withAnimation {
                        showSetting = false
                    }
                }
                .padding(.top)

            }
            .padding()
            .frame(width: 320)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            
            
            
            
            
            
            
        }
        
        
    }
}


