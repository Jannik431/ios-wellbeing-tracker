//
//  ChartView.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
// --> Diagramm
import SwiftUI
import Charts
import SwiftData

struct WellbeingChartView: View {
    let logs: [DailyCheckIn]
    
    private var chartData: [DailyCheckIn] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        return logs
            .filter { $0.date >= thirtyDaysAgo }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Erholungsverlauf (Schlaf vs. Belastung)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    // --- SERIE 1: SCHLAF (Grün) ---
                    // Wir zeichnen erst alle grünen Punkte und verbinden sie
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("Datum", item.date, unit: .day),
                            y: .value("Schlaf", item.sleepQuality)
                        )
                        .foregroundStyle(.green)
                        .interpolationMethod(.catmullRom)
                        .symbol {
                            Circle().fill(.green).frame(width: 8)
                        }
                    }
                    // WICHTIG: Das hier definiert den Namen für die Legende
                    .foregroundStyle(by: .value("Metrik", "Schlaf"))
                    
                    // --- SERIE 2: MUSKELKATER (Rot) ---
                    // Dann zeichnen wir alle roten Punkte als separate Ebene
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("Datum", item.date, unit: .day),
                            y: .value("Muskelkater", item.muscleSoreness)
                        )
                        .foregroundStyle(.red)
                        .interpolationMethod(.catmullRom)
                        .symbol {
                            Rectangle().fill(.red).frame(width: 7, height: 7)
                        }
                    }
                    .foregroundStyle(by: .value("Metrik", "Muskelkater"))
                }
                .chartYScale(domain: 0...10)
                // Erzwingt, dass die X-Achse Tage anzeigt (keine Stunden)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day(.defaultDigits))
                    }
                }
                // Definiert die Farben fest für die Legende (damit Grün auch wirklich Grün bleibt)
                .chartForegroundStyleScale([
                    "Schlaf": .green,
                    "Muskelkater": .red
                ])
                .frame(width: max(300, CGFloat(chartData.count * 60)), height: 200)
                .padding(.horizontal)
            }
            .defaultScrollAnchor(.trailing)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
