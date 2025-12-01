//
//  Date+Extensions.swift
//  ios-wellbeing-tracker
//
//  Created by Jannik Pasch on 01.12.25.
// --> Hilfsfunktion für das Datum
import Foundation
extension Date{
    // Gibt ein benutzerfreundliches Format zurück (z. B. "Heute", "Gestern", oder "23. Nov")
    var friendlyFormat: String{
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Heute"
        } else if calendar.isDateInYesterday(self) {
            return "Gestern"
        } else {
            return self.formatted(.dateTime.day().month(.abbreviated))
        }
    }
}
