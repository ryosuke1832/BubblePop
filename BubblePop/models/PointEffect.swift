//
//  PointEffect.swift
//  BubblePop
//
//  Created by user on 2025/04/13.
//


import SwiftUI

struct PointEffect: Identifiable {
    let id = UUID()
    let points: Int
    let position: CGPoint
    var opacity: Double = 1.0
    var offset: Double = 0
}
