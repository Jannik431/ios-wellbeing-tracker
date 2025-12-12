//
//  NotificationSettingsView.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 12.12.25.
//
import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // State, um den Status des Schalters zu speichern
    @State private var isScheduled = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tägliche Erinnerung") {
                    Text("Erhalte jeden Morgen um 08:00 Uhr eine Erinnerung, deinen täglichen Check-In durchzuführen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    // Schalter, um die Benachrichtigung zu aktivieren/deaktivieren
                    Toggle("Erinnerung aktivieren", isOn: $isScheduled)
                        // Löst die Aktion aus, wenn der Schalter umgelegt wird
                        .onChange(of: isScheduled) { newValue in
                            if newValue {
                                requestAuthorizationAndSchedule()
                            } else {
                                // Deaktivieren: Entfernt die geplante Benachrichtigung
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_wellbeing_reminder"])
                                print("Benachrichtigung deaktiviert.")
                            }
                        }
                    
                    Text("Geplante Zeit: 08:00 Uhr")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .onAppear {
                checkNotificationStatus()
            }
        }
    }
    
    // Prüft, ob die Benachrichtigung bereits geplant ist
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let isCurrentlyScheduled = requests.contains { $0.identifier == "daily_wellbeing_reminder" }
            DispatchQueue.main.async {
                self.isScheduled = isCurrentlyScheduled
            }
        }
    }

    // Fordert Erlaubnis an und plant die Benachrichtigung
    func requestAuthorizationAndSchedule() {
        // Fordert die Erlaubnis an (Alert, Badge, Sound)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                // Wenn erlaubt, planen wir die Benachrichtigung
                scheduleDailyNotification()
            } else if let error = error {
                print("Fehler bei der Benachrichtigungs-Erlaubnis: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isScheduled = false }
            } else {
                 DispatchQueue.main.async { self.isScheduled = false }
            }
        }
    }
    
    // Plant die tägliche Benachrichtigung für 8:00 Uhr
    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Dein täglicher Check-In"
        content.body = "Zeit, dein Wohlbefinden und deine Erholung zu loggen! 💪"
        content.sound = .default
        
        // Trigger für 8:00 Uhr, täglich wiederholt
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Feste ID, damit wir immer nur eine Benachrichtigung dieser Art planen
        let request = UNNotificationRequest(identifier: "daily_wellbeing_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Fehler beim Scheduling der Notification: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isScheduled = false }
            } else {
                print("Tägliche Benachrichtigung erfolgreich um 8:00 Uhr geplant.")
                DispatchQueue.main.async { self.isScheduled = true }
            }
        }
    }
}
