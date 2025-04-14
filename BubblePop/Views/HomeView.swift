//
//  HomeView.swift
//  BubblePop
//
//  Created by user on 2025/04/02.
//

import SwiftUI

struct HomeView: View {
    @StateObject var gameManager = GameManager()
    @State private var isGameStarted: Bool = false
    @State private var showSettings:Bool = false
    @State private var showAlert:Bool = false
    
    var body: some View {
        NavigationView{
            ZStack(){
                Color.white.ignoresSafeArea()
                
                VStack(spacing:40){
                    HStack{
                        Spacer()
                        Button(action: {
                            withAnimation{
                                showSettings.toggle()
                            }
                        }){
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    
                    Text("Bubble Pop!")
                        .font(.custom("Bebas Neue", size: 90))
                        .foregroundColor(.pink)
                    
                    TextField("Input your name",text:$gameManager.playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal,40)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: GameView(gameManager:gameManager),isActive:$isGameStarted){
                        EmptyView()
                    }
                    Button(action: {
                        if gameManager.playerName.trimmingCharacters(in: .whitespaces).isEmpty{
                            showAlert = true
                    } else{
                        isGameStarted = true
                    }
                }) {
                        Text("Start!")
                            .font(.custom("Bebas Neue", size: 60))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .alert(isPresented: $showAlert){
                        Alert(
                            title: Text("Error!"),
                            message: Text("Please input your name"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                    Spacer(minLength: 50)
                    
                }
                
                if showSettings {
                    SettingView(showSetting: $showSettings, gameManager: gameManager)
                        .transition(.scale)
                        .zIndex(1)
                }
                

            }
        }
   
    }
}

#Preview {
    HomeView()
}




