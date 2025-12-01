//
//  DailyCheckIn+Logic.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 02.12.25.
//
import SwiftUI

// Erweiterung des Models um Berechnungs-Logik
extension DailyCheckIn {
    
    // Berechnet einen Score von 0 bis 100
    var readinessScore: Int {
        // Formel:
        // Schlaf (1-10) -> Je höher desto besser
        // Stimmung (1-10) -> Je höher desto besser
        // Muskelkater (1-10) -> Je höher desto SCHLECHTER. Also drehen wir den Wert um (11 - Wert).
        
        let sleepPoints = Double(sleepQuality)
        let moodPoints = Double(mood)
        let sorenessPoints = Double(11 - muscleSoreness) // 1 wird zu 10 Punkten, 10 wird zu 1 Punkt
        
        // Maximal mögliche Punkte: 10 + 10 + 10 = 30
        let totalPoints = sleepPoints + moodPoints + sorenessPoints
        
        // Umrechnung in Prozent (0-100)
        return Int((totalPoints / 30.0) * 100)
    }
    
    // Gibt die passende Farbe für den Score zurück (Ampel-System)
    var readinessColor: Color {
        switch readinessScore {
        case 80...100: return .green  // Topfit
        case 50..<80:  return .yellow // Okay / Vorsichtig
        default:       return .red    // Erholung nötig
        }
    }
    
    // Ein kurzer Text, der den Zustand beschreibt
    var readinessTitle: String {
        switch readinessScore {
        case 80...100: return "Einsatzbereit"
        case 50..<80:  return "Moderat"
        default:       return "Erholung nötig"
        }
    }
}
