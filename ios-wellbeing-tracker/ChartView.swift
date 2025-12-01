//
//  ChartView.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
// --> Diagramm
import Charts
import SwiftUI

struct WellbeingChartView: View{
    // Abhängigkeit wird explizit gemacht
    let logs: [DailyCheckIn]
    
    // Sortiert die Daten chronologisch für den Graphen
    private var chartData: [DailyCheckIn] {
        logs.sorted { $0.date < $1.date }
    }
    
    var body : some View {
        VStack(alignment: .leading) {
            Text("Verlauf (Letzte 30 Tage)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            chartContent
                                .padding()
                        }
                        .defaultScrollAnchor(.trailing) // Startet beim neuesten Datum
                    }
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // UI-Code ausgelagert in private Variable für bessere Lesbarkeit
                private var chartContent: some View {
                    Chart {
                        ForEach(chartData) { item in
                            plotLine(for: item, value: item.sleepQuality, type: "Schlaf", color: .green)
                            plotLine(for: item, value: item.muscleSoreness, type: "Muskelkater", color: .red)
                        }
                    }
                    .chartYScale(domain: 0...10)
                    // Dynamische Breite basierend auf Anzahl der Datenpunkte
                    .frame(width: max(300, CGFloat(chartData.count * 40)), height: 200)
                }
                
                // Helper Funktion um Code-Duplizierung im Chart zu vermeiden
                @ChartContentBuilder
                private func plotLine(for item: DailyCheckIn, value: Int, type: String, color: Color) -> some ChartContent {
                    LineMark(
                        x: .value("Datum", item.date, unit: .day),
                        y: .value("Wert", value)
                    )
                    .foregroundStyle(color)
                    .symbol {
                        Circle().fill(color).frame(width: 6)
                    }
                    .interpolationMethod(.catmullRom)
                }
            }
