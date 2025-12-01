//
//  ContentView.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Sortiert die neuesten Einträge nach oben
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var logs: [DailyCheckIn]
    
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Chart (Nur anzeigen wenn Daten da sind)
                if !logs.isEmpty {
                    WellbeingChartView(logs: logs)
                        .padding(.vertical, 10)
                }
                
                // 2. Die Liste mit dem Readiness Score
                logList
            }
            .navigationTitle("Athlete Monitor")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddLogSheet()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var logList: some View {
        List {
            if logs.isEmpty {
                ContentUnavailableView(
                    "Keine Einträge",
                    systemImage: "chart.bar.xaxis",
                    description: Text("Starte dein Tracking mit +")
                )
            } else {
                ForEach(logs, id: \.self) { log in
                    NavigationLink(destination: EditLogView(log: log)) {
                        HStack(spacing: 16) {
                            // Readiness Score
                            ZStack {
                                Circle()
                                    .stroke(log.readinessColor.opacity(0.3), lineWidth: 4)
                                    .frame(width: 50, height: 50)
                                
                                Text("\(log.readinessScore)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(log.readinessColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Status-Titel
                                Text(log.readinessTitle)
                                    .font(.headline)
                                    .foregroundStyle(log.readinessColor)
                                
                                // Datum
                                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                // Notizen anzeigen
                                if !log.notes.isEmpty {
                                    Text(log.notes)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .padding(.top, 2)
                                }
                            }
                            
                            Spacer()
                            
                            // Kleiner Pfeil nach rechts
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(logs[index])
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyCheckIn.self, configurations: config)
    
    // Testdaten für die Preview
    let log1 = DailyCheckIn(date: .now, sleepQuality: 9, muscleSoreness: 1, mood: 9, notes: "Topfit")
    let log2 = DailyCheckIn(date: .now.addingTimeInterval(-86400), sleepQuality: 4, muscleSoreness: 8, mood: 3, notes: "Müde")
    
    container.mainContext.insert(log1)
    container.mainContext.insert(log2)
    
    return ContentView().modelContainer(container)
}
