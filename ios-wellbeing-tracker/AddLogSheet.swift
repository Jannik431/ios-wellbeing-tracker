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
                    Button("Speichern", action: saveLog)
                }
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
            SliderView(value: $sleepQuality, label: "Schlaf", icon: "bed.double.fill", color: .green)
            SliderView(value: $muscleSoreness, label: "Muskelkater", icon: "flame.fill", color: .red)
        }
    }
    
    private var mentalSection: some View {
        Section("Mental & Training") {
            SliderView(value: $mood, label: "Stimmung", icon: "face.smiling", color: .blue)
            SliderView(value: $trainingLoad, label: "Belastung", icon: "dumbbell.fill", color: .orange)
        }
    }
    
    private var notesSection: some View {
        Section("Notizen") {
            TextField("Wie fühlst du dich?", text: $note, axis: .vertical)
                .lineLimit(3...5)
        }
    }
    
    // MARK: - Actions
    
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
}

// Kleine wiederverwendbare Komponente nur für diese Datei
fileprivate struct SliderView: View {
    @Binding var value: Double
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label(label, systemImage: icon).foregroundStyle(color)
                Spacer()
                Text("\(Int(value))/10").bold().foregroundStyle(.secondary)
            }
            Slider(value: $value, in: 1...10, step: 1)
        }
    }
}
