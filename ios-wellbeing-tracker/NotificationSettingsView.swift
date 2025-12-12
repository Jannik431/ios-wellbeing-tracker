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
    
    // Gewählte Uhrzeit (default: 8 Uhr)
    @State private var notificationTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    
    private let notificationTimeKey = "dailyNotificationTime"
    private let notificationID = "daily_wellbeing_reminder"

    var body: some View {
        NavigationStack {
            Form {
                Section("Tägliche Erinnerung") {
                    Text("Erhalte jeden Tag eine Benachrichtigung, um deinen Check-In durchzuführen.")
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
                                removeNotification()
                            }
                        }
                    if isScheduled {
                        DatePicker("Uhrzeit auswählen", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) {
                                // Wenn die Zeit geändert wird, die Erinnerung neu planen
                                if isScheduled {
                                    scheduleDailyNotification()
                                    saveNotificationTime()
                                }
                            }
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .onAppear {
                loadNotificationTime()
                checkNotificationStatus()
            }
        }
    }
    
    // MARK: - Persistence (UserDefaults)
    private func loadNotificationTime() {
        if let savedDate = UserDefaults.standard.object(forKey: notificationTimeKey) as? Date {
            self.notificationTime = savedDate
        }
    }
    
    private func saveNotificationTime() {
        UserDefaults.standard.set(notificationTime, forKey: notificationTimeKey)
    }
    
    // MARK: - Notification Management
    
    // Prüft, ob die Benachrichtigung bereits geplant ist
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let isCurrentlyScheduled = requests.contains { $0.identifier == notificationID }
            DispatchQueue.main.async {
                self.isScheduled = isCurrentlyScheduled
            }
        }
    }
    
    // Entfernt die Benachrichtigung
    private func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
        print("Benachrichtigung deaktiviert.")
    }
    
    // Fordert Erlaubnis an und plant die Benachrichtigung
    private func requestAuthorizationAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                scheduleDailyNotification()
                saveNotificationTime()
            } else if let error = error{
                print("Fehler bei der Benachrichtigungs-Erlaubnis: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isScheduled = false }
            } else {
                DispatchQueue.main.async { self.isScheduled = false }
            }
        }
    }
    // Plant die tägliche Benachrichtigung mit der gewählten Uhrzeit
    func scheduleDailyNotification() {
        removeNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "Dein täglicher Check-In"
        content.body = "Zeit, dein Wohlbefinden und deine Erholung zu loggen! 💪"
        content.sound = .default
        
        // Trigger für gewählte Uhrzeit
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Fehler beim Scheduling der Notification: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isScheduled = false }
            } else {
                print("Tägliche Benachrichtigung erfolgreich für \(components.hour ?? 0):\(components.minute ?? 0) Uhr geplant.")
                DispatchQueue.main.async { self.isScheduled = true }
            }
        }
    }
}
