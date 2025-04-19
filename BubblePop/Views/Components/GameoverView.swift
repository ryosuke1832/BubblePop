//
//  settingView.swift
//  BubblePop
//
//  Created by user on 2025/04/07.
//

import SwiftUI

struct GameoverView: View {
    @ObservedObject var gameManager:GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var returnToHome: Bool = false
    
    var body: some View {
        
        ZStack{
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30){
                Text("Game Over!")
                    .font(.title)
                    .padding(.top)
                Text("Score: \(gameManager.score)")
                    .font(.title)
                    .padding(.top)
                
                Button(action: {returnToHome=true}) {
                    Text("Result")
                }
                .padding(.top)
                
            }
            .padding()
            .frame(width: 320)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            
            NavigationLink(destination: ResultView()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true),
                           isActive: $returnToHome){
                EmptyView()
            }
            
        }

    }
}


