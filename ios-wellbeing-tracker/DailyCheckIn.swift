//
//  DailyCheckIn.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
// --> Datenmodell
import Foundation
import SwiftData

@Model
final class DailyCheckIn{
    var date: Date
    var sleepQuality: Int       // 1-10
    var muscleSoreness: Int     // 1-10
    var mood: Int               // 1-10
    var trainingLoad: Int      // 1-10
    var notes: String
    
    // Init mit Default-Werten
    init(
        date: Date = .now,
        sleepQuality: Int = 5,
        muscleSoreness: Int = 1,
                mood: Int = 5,
                trainingLoad: Int = 0,
                notes: String = ""
            ) {
                self.date = date
                self.sleepQuality = sleepQuality
                self.muscleSoreness = muscleSoreness
                self.mood = mood
                self.trainingLoad = trainingLoad
                self.notes = notes
            }
        }
