//
//  DataHandler.swift
//  ActivityTracker
//

import Foundation

class DataHandler: ObservableObject {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("activity_data.json")
    @Published var activities: [String: [ActivitySession]] = [:]
    
    init() {
        loadData()
    }
    
    // load and save data
    
    func loadData() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            activities = try decoder.decode([String: [ActivitySession]].self, from: data)
        } catch {
            print("Error loading data: \(error)")
            activities = [:]
        }
    }
    
    func saveData() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(activities)
            try jsonData.write(to: fileURL)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    // start and stop activity
    
    func startActivity(activityName: String, start: Date) -> ActivitySession {
        let session = ActivitySession(name: activityName, start: start)
        if activities[activityName] == nil {
            activities[activityName] = []
        }
        activities[activityName]?.append(session)
        saveData()
        return session
    }
    
    func stopActivity(session: ActivitySession, duration: TimeInterval) {
        let activityName = session.getName()
        guard var activitySessions = activities[activityName],
              let index = activitySessions.firstIndex(where: { $0.id == session.id }) else {
            return
        }
        
        session.end = Date()
        session.duration = abs(session.end!.timeIntervalSince(session.start))
        
        activitySessions[index] = session
        activities[activityName] = activitySessions
        
        saveData()
    }
    
    // today activities
    
    func getTodayActivities() -> [String: TimeInterval] {
        return ActivitySummary.getDaySummary(activities: activities)
    }
    
    // summary by activity
}
