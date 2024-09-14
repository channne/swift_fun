//
//  ActivitySummary.swift
//  ActivityTracker
//

import Foundation

class ActivitySummary {
    class func getDaySummary(activities: [String: [ActivitySession]]) -> [String: [Date: TimeInterval]] {
        let calendar = Calendar.current // update to accept multiple dates next time
        var summary: [String: [Date: TimeInterval]] = [:] // for each activity, returns start : duration
        
        for (name, sessions) in activities { 
            var sessions_today: [Date: TimeInterval] = [:]
            for sesh in sessions {
                guard let end = sesh.getEnd(),
                      let duration = sesh.getDuration() else {
                    continue // not ended yet
                }
                if calendar.isDateInToday(sesh.getStart()) {
                    if calendar.isDateInToday(end) {
                        sessions_today[sesh.getStart()] = duration
                    } else {
                        // started today but end tomorrow, calc endOfDay - start
                        var tomorrow = Date()
                        tomorrow.addTimeInterval(86400)
                        sessions_today[sesh.getStart()] = (abs(sesh.getStart().distance(to:calendar.startOfDay(for:tomorrow))))
                    }
                } else if calendar.isDateInToday(end) {
                    // end = today, start not today -> calc end - startOfDay
                    sessions_today[calendar.startOfDay(for:Date())] = (abs(end.distance(to:calendar.startOfDay(for:Date()))))
                }
            }
            if sessions_today.count > 0 {
                summary[name] = sessions_today
            }
        }
        
        return summary
    }

    // TODO: getActivitySummary
}
