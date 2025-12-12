//
//  EditLogView.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 12.12.25.
//
import SwiftData
import SwiftUI

struct EditLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var log: DailyCheckIn
    
    @State private var originalDate: Date = Date()
    
    @State private var showDuplicateAlert = false
    
    var body: some View {
        Form {
            Section("Datum") {
                DatePicker("Zeitpunkt", selection: $log.date, displayedComponents: .date)
                    .onChange(of: log.date) {oldValue, newValue in checkForDuplicateDate(newDate: newValue)}
            }
            
            Section("Körper & Erholung") {
                SliderRow(
                    value: Binding(
                        get: { Double(log.sleepQuality) },
                        set: { log.sleepQuality = Int($0) }
                    ),
                    label: "Schlaf",
                    icon: "bed.double.fill",
                    color: .green,
                    description: getSleepDescription
                )
                
                SliderRow(
                    value: Binding(
                        get: { Double(log.muscleSoreness) },
                        set: { log.muscleSoreness = Int($0) }
                    ),
                    label: "Muskelkater",
                    icon: "flame.fill",
                    color: .red,
                    description: getSorenessDescription
                )
            }
            
            Section("Mental & Training") {
                SliderRow(
                    value: Binding(
                        get: { Double(log.mood) },
                        set: { log.mood = Int($0) }
                    ),
                    label: "Stimmung",
                    icon: "face.smiling",
                    color: .blue,
                    description: getMoodDescription
                )
            
                SliderRow(
                    value: Binding(
                        get: { Double(log.trainingLoad) },
                        set: { log.trainingLoad = Int($0) }
                    ),
                    label: "Belastung",
                    icon: "dumbbell.fill",
                    color: .orange,
                    description: getLoadDescription
                )
            }
            
            Section("Notizen") {
                TextField("Notizen", text: $log.notes, axis: .vertical)
                    .lineLimit(3...10)
            }
        }
        .navigationTitle("Eintrag bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
        
        // Alert bei Duplikate
        .alert("Einntrag existiert bereits", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Du hast für dieses Datum bereits einen anderen Eintrag. Die Änderung wurde zurückgesetzt, um Datenverlust zu vermeiden.")
        }
        .onAppear {
            // Speichern des Orignaldatums beim ersten Laden
            originalDate = log.date
        }
    }
    // MARK: - Validierung
    private func checkForDuplicateDate(newDate: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: newDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
            
        let datePredicate = #Predicate<DailyCheckIn> { logEntry in
            logEntry.date >= startOfDay &&
            logEntry.date < endOfDay
        }
            
        let descriptor = FetchDescriptor<DailyCheckIn>(predicate: datePredicate)
            
        do {
            let potentialCollisions = try modelContext.fetch(descriptor)
                
            let collidingEntries = potentialCollisions.filter { fetchedLog in
                return fetchedLog.persistentModelID != log.persistentModelID
            }
            if collidingEntries.count > 0 {
                DispatchQueue.main.async {
                    self.showDuplicateAlert = true
                    self.log.date = self.originalDate
                }
            } else {
                self.originalDate = newDate
            }
        } catch {
            print("Fehler beim Prüfen auf Duplikate: \(error)")
        }
    }
    
    // MARK: - Helper Logik (Kopie aus AddLogSheet)
        
    func getSleepDescription(val: Int) -> String {
        switch val {
        case 1...2: return "Katastrophal"
        case 3...4: return "Schlecht"
        case 5...6: return "Geht so"
        case 7...8: return "Gut"
        case 9...10: return "Perfekt"
        default: return ""
        }
    }
    
    func getSorenessDescription(val: Int) -> String {
        switch val {
        case 1...2: return "Keiner"
        case 3...4: return "Leicht"
        case 5...6: return "Mittel"
        case 7...8: return "Stark"
        case 9...10: return "Extrem"
        default: return ""
        }
    }
    
    func getMoodDescription(val: Int) -> String {
        switch val {
        case 1...3: return "Gestresst"
        case 4...6: return "Neutral"
        case 7...10: return "Motiviert"
        default: return ""
        }
    }
    
    func getLoadDescription(val: Int) -> String {
        switch val {
        case 1...2: return "Ruhetag"
        case 3...5: return "Leicht"
        case 6...8: return "Hart"
        case 9...10: return "Limit"
        default: return ""
        }
    }
}
    // Lokale Slider Komponente für diese View
    fileprivate struct SliderRow: View {
        @Binding var value: Double
        let label: String
        let icon: String
        let color: Color
        var description: (Int) -> String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(label, systemImage: icon)
                        .foregroundStyle(color)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(value))/10").font(.headline).monospacedDigit()
                }
                Slider(value: $value, in: 1...10, step: 1)
                    .tint(color)
                Text(description(Int(value)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
