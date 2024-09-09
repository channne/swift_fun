//
//  ActivitySummary.swift
//  ActivityTracker
//

import Foundation

class ActivitySummary {
    class func getDaySummary(activities: [String: [ActivitySession]]) -> [String: TimeInterval] {
        let calendar = Calendar.current // update to accept multiple dates next time
        var summary: [String: TimeInterval] = [:]
        
        for (name, sessions) in activities { 
            var total_duration = TimeInterval(0)
            for sesh in sessions {
                guard let end = sesh.getEnd(),
                      let duration = sesh.getDuration() else {
                    continue // not ended yet
                    // TODO: figure out why it alr shows at 00:00:00, change that
                }
                if calendar.isDateInToday(sesh.getStart()) {
                    if calendar.isDateInToday(end) {
                        total_duration += duration
                    } else {
                        // started today but end tomorrow, calc endOfDay - start
                        var tomorrow = Date()
                        tomorrow.addTimeInterval(86400)
                        total_duration += (abs(sesh.getStart().distance(to:calendar.startOfDay(for:tomorrow))))
                    }
                } else if calendar.isDateInToday(end) {
                    // end = today, start not today -> calc end - startOfDay
                    total_duration += (abs(end.distance(to:calendar.startOfDay(for:Date()))))
                }
            }
            if total_duration > 0 {
                summary[name] = total_duration
            }
        }
        
        return summary
    }

    // TODO: getActivitySummary
}
