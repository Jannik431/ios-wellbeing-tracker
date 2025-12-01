//
//  App.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
//
import SwiftUI
import SwiftData

@main
struct WellbeingTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DailyCheckIn.self)
    }
}
