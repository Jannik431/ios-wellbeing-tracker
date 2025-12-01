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
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var logs: [DailyCheckIn]
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Chart (Nur wenn Daten da sind)
                if !logs.isEmpty {
                    WellbeingChartView(logs: logs)
                        .padding(.vertical, 10)
                }
                
                // 2. Liste
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
                // FIX: Wir nutzen 'id: \.self', damit SwiftData Objekte eindeutig erkennt
                ForEach(logs, id: \.self) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            // FIX: Statt '.friendlyFormat' nutzen wir Standard-SwiftUI.
                            // Das behebt den Fehler, falls die Extension-Datei fehlt.
                            Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.headline)
                            
                            if !log.notes.isEmpty {
                                Text(log.notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        StatusBadge(value: log.sleepQuality, color: .green)
                        StatusBadge(value: log.muscleSoreness, color: .red)
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

// Helper View direkt in dieser Datei
private struct StatusBadge: View {
    let value: Int
    let color: Color
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 14, weight: .bold))
            .frame(width: 30, height: 30)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Circle())
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyCheckIn.self, configurations: config)
    let dummy = DailyCheckIn(date: .now, sleepQuality: 8, muscleSoreness: 3, mood: 7, notes: "Test")
    container.mainContext.insert(dummy)
    return ContentView().modelContainer(container)
}

