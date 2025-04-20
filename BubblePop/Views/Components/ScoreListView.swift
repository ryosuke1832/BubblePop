//
//  ScoreListView.swift
//  BubblePop
//
//  Created by user on 2025/04/20.
//

import SwiftUI

struct ScoreListView: View {
    let scores:[PlayerScore]
    
    var body: some View {
        
        List {
            ForEach(Array(scores.prefix(10).enumerated()), id: \.element.id) { index, score in
                HStack {
                    Text("#\(index + 1)")
                        .font(.custom("Bebas Neue", size: 30))
                        .frame(width: 50, alignment: .leading)
                    
                    Text(score.name)
                        .font(.custom("Bebas Neue", size: 30))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(score.score)")
                        .font(.custom("Bebas Neue", size: 30))
                        .frame(alignment: .trailing)
                }
                .foregroundColor(.black)
            }
        }
        .listStyle(PlainListStyle())
    }
}


