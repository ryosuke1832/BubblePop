//
//  Bubble.swift
//  BubblePop
//
//  Created by user on 2025/04/05.
//



import SwiftUI


struct Bubble:Identifiable{
    let id = UUID()
    var position:CGPoint
    var color:Color
    var isPopped:Bool = false
    var speed:Double
    var point:Int
    var creationTime: Date = Date()
    
    var lastTappedPosition:CGPoint?
}
