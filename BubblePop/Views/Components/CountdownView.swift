//
//  CountdownView.swift
//  BubblePop
//
//  Created by user on 2025/04/12.
//

import SwiftUI

struct CountdownView: View {
    @Binding var showCountdown:Bool
    var onComplete:() -> Void
    @State private var countdownNumber:Int = 3
    var body: some View {
        ZStack{
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            Text("\(countdownNumber)")
                .font(.system(size: 200,weight: .bold))
                .foregroundStyle(.white)
                .scaleEffect(1.5)
                .onAppear(perform:startCountDown)
        }
    }
    
    private func startCountDown(){
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {timer in
            withAnimation(.easeOut(duration:0.2)){
                countdownNumber -= 1
                
                if countdownNumber == 0{
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        onComplete()
                        showCountdown = false
                    }
                    
                }
                
            }
        }
        
    }
}

