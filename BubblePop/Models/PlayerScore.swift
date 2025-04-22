//
//  PlayerScore.swift
//  BubblePop
//
//  Created by user on 2025/04/05.
//



import SwiftUI


struct PlayerScore:Codable,Identifiable{
    var id = UUID()
    let name:String
    let score:Int

}
