//
//  ios_wellbeing_trackerApp.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
//

import SwiftUI
import CoreData

@main
struct ios_wellbeing_trackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
