//
//  AddLogSheet.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
// --> Eingabeformular
import SwiftUI
import SwiftData

struct AddLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Lokaler State für das Formular
    @State private var date = Date()
    @State private var sleepQuality = 7.0
    @State private var muscleSoreness = 2.0
    @State private var mood = 7.0
    @State private var trainingLoad = 5.0
    @State private var note = ""
    @State private var showDuplicateAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                dateSection
                recoverySection
                mentalSection
                notesSection
            }
            .navigationTitle("Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern", action: checkAndSave)
                }
            }
            // Alarm-Fenster
            .alert("Eintrag existiert bereits", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Du hast für diesen Tag bereits einen Eintrag erstellt. Bitte wähle ein anderes Datum oder bearbeite den existierenden Eintrag in der Liste.")
            }
        }
    }
    
    // MARK: - Subviews (zur Strukturierung)
    
    private var dateSection: some View {
        Section("Datum") {
            DatePicker("Zeitpunkt", selection: $date, displayedComponents: .date)
        }
    }
    
    private var recoverySection: some View {
        Section("Körper & Erholung") {
            SliderView(
                        value: $sleepQuality,
                        label: "Schlaf",
                        icon: "bed.double.fill",
                        color: .green,
                        description: getSleepDescirption
                        )
            
            SliderView(value: $muscleSoreness,
                       label: "Muskelkater",
                       icon: "flame.fill",
                       color: .red,
                       description: getSorenessDescription)
        }
    }
    
    private var mentalSection: some View {
        Section("Mental & Training") {
            SliderView(value: $mood,
                       label: "Stimmung",
                       icon: "face.smiling",
                       color: .blue,
                       description: getMoodDescription)
            
            SliderView(value: $trainingLoad,
                       label: "Belastung",
                       icon: "dumbbell.fill",
                       color: .orange,
                       description: getLoadDescription)
        }
    }
    
    private var notesSection: some View {
        Section("Notizen") {
            TextField("Wie fühlst du dich?", text: $note, axis: .vertical)
                .lineLimit(3...5)
        }
    }
    
    // MARK: - Beschreibungs-Logik
    func getSleepDescirption(val: Int) -> String {
        switch val {
        case 1...2: return "Katastrophal (Kaum geschlafen)"
        case 3...4: return "Schlecht (Oft wach)"
        case 5...6: return "Geht so (Durchschnitt)"
        case 7...8: return "Gut (Erholt)"
        case 9...10: return "Perfekt (Tief & Fest)"
        default: return ""
        }
    }
    
    func getSorenessDescription(val: Int) -> String{
        switch val {
        case 1...2: return "Keiner"
        case 3...4: return "Leicht"
        case 5...6: return "Mittel"
        case 7...8: return "Stark (Schmerzhaft)"
        case 9...10: return "Extrem (kaum Bewegung möglich)"
        default: return ""
        }
    }
    
    func getMoodDescription(val: Int) -> String {
        switch val {
        case 1...3: return "Gestresst / Demotiviert"
        case 4...6: return "Neutral"
        case 7...10: return "Motiviert / Energisch"
        default: return ""
        }
    }
        
    func getLoadDescription(val: Int) -> String {
        switch val {
        case 1...2: return "Ruhetag"
        case 3...5: return "Leichtes Training"
        case 6...8: return "Hartes Training"
        case 9...10: return "Maximal (Wettkampf/Limit)"
        default: return ""
        }
    }
        
        
    // MARK: - Actions & Validierung
    private func checkAndSave() {
        // Zeitraum ausgewählter Tag definieren
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        // Suchanfrage an Datenbank
        let predicate = #Predicate<DailyCheckIn> { log in log.date >= startOfDay && log.date < endOfDay
        }
        let descriptor = FetchDescriptor<DailyCheckIn>(predicate: predicate)
        
        // Auf Ergebnisse prüfen
        do {
            let count = try modelContext.fetchCount(descriptor)
                    
            if count > 0 {
                // FEHLER: Es gibt schon einen Eintrag -> Alarm zeigen
                showDuplicateAlert = true
            } else {
                // ALLES OK: Speichern
                saveLog()
            }
        } catch {
                    print("Fehler beim Prüfen auf Duplikate: \(error)")
                }
    }
        
    private func saveLog() {
        let newLog = DailyCheckIn(
            date: date,
            sleepQuality: Int(sleepQuality),
            muscleSoreness: Int(muscleSoreness),
            mood: Int(mood),
            trainingLoad: Int(trainingLoad),
            notes: note
        )
        modelContext.insert(newLog)
        dismiss()
    }
        
    // Kleine wiederverwendbare Komponente nur für diese Datei
    fileprivate struct SliderView: View {
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
                    Text("\(Int(value))/10")
                        .font(.headline)
                        .monospacedDigit()
                }
                Slider(value: $value, in: 1...10, step: 1)
                    .tint(color)
                Text(description(Int(value)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.snappy, value: value)
            }
            .padding(.vertical, 4)
        }
    }
}
