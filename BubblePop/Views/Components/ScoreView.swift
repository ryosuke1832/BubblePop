//
//  SwiftUIView.swift
//  BubblePop
//
//  Created by user on 2025/04/05.
//

import SwiftUI

struct ScoreView: View {
    let score: Int
    let time:Int
    
    var body: some View {
        VStack{
            Text("Bubble Pop!")
                .font(.custom("Bebas Neue", size: 30))
                .foregroundColor(.pink)
            
            HStack{
                Text("Score: ") + Text("\(score)").foregroundColor(.orange)
                    .font(.custom("Bebas Neue", size: 30))
                    .foregroundColor(.white)
                
                Text("Time: ") + Text("\(time)").foregroundColor(.blue)
                    .font(.custom("Bebas Neue", size: 30))
                    .foregroundColor(.white)
                

            }
            
            Spacer()
        }
        
    }
}


