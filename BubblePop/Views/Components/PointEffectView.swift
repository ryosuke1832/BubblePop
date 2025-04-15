//
//  PointEffectView.swift
//  BubblePop
//
//  Created by user on 2025/04/14.
//

import SwiftUI

struct PointEffectView: View {
    let point:PointEffect

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1.0

    
    var body: some View {
        Text("+\(point.points)")
            .font(.system(size: 24,weight:.bold))
            .foregroundColor(.black)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            .position(x:point.position.x,y:point.position.y + offsetY)
            .opacity(opacity)
            .onAppear{
                withAnimation(.easeOut(duration:1)){
                    offsetY = -50
                    opacity = 0
                }
            }
    }
}

