//
//  Activity.swift
//  ActivityTracker
//

import Foundation

class ActivitySession: Identifiable, Codable {
    let id: UUID
    let name: String
    let start: Date
    
    var activityState: ActivityState = .inactive
    var end: Date?
    var duration: TimeInterval? // supposed to be "active duration"
    
    // boilerplate
    
    init(name: String, start: Date) {
        self.id = UUID()
        self.name = name
        self.start = start
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getStart() -> Date {
        return self.start
    }
    
    func getActivityState() -> ActivityState {
        return self.activityState
    }
    
    func getEnd() -> Date? {
        return self.end
    }
    
    func getDuration() -> TimeInterval? {
        return self.duration
    }
    
    // updating shiz
    
    func stop(end: Date) {
        self.end = end
    }
    
    func updateDuration(duration: TimeInterval) {
        self.duration = duration
    }
}
