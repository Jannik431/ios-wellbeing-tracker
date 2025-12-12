# Wellbeing & Recovery Tracker (iOS)

Eine iOS-Anwendung zum Monitoring von physischer und mentaler Erholung im Sport. Entwickelt mit **SwiftUI** und **SwiftData**.

## 🎯 Features
| Feature | Beschreibung |
| :--- | :---- |
| **Daily Readiness Score** | Berechnung eines zentralen Scores (0-100%) basierend auf Schlaf, Muskelkater und Stimmung. Zeigt sofort, ob der Tag für hartes Training (Grün) oder Erholung (Rot) geeignet ist. |
| **Smart-Tracking** | Erfassung von Schlafqualität, Muskelkater, Stimmung und Belastung über intuitive Slider mit erklärenden Texten (z. B. "Katastrophal" vs. "Perfekt" |
| **Historische Visualisierung** | Interaktive Liniendiagramme (Swift Charts), die den Verlauf über Tage hinweg zeigen. Trennt die Metriken klar in seperate Datenreihen. |
| **Robuste Dateneingabe** | Validierung, um Duplikate am selben Kalendertag zu verhindern, sowie Bearbeitung existierender Einträge |

## 📐 Clean Code & Architektur
* **ContentView:** Dient nur als Zentrale, um die spezialisierten Komponenten (WellbeingChart, AddLogSheet) zusammenzufügen.
* **Extensions:** Die Berechnungen (z. B. readinessScore) sind in seperaten Extensions gekapselt.
* **@Bindable:** Effektive Nutzung in der EditLogView für die automatische Speicherung der Änderungen in SwiftData.

## 🛠 Tech Stack
* **Language:** Swift 5.9
* **UI:** SwiftUI
* **Storage:** SwiftData
* **Charts:** Swift Charts Framework

## 📸 Screenshots
| Dashboard | Dateneingabe |
| :--- | :----|
| <img src="screenshots/dashboard1.png" width="250"> | <img src="screenshots/dateneingabe1.png" width="250"> |
| <img src="screenshots/dashboard2.png" width="250"> | <img src="screenshots/dateneingabe2.png" width="250"> |

## 🚀 Installation
1.  Repo klonen.
2.  In Xcode 15+ öffnen.
3.  Target auf iOS 17+ setzen und starten.
---
*© 2025 Jannik*
