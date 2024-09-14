//
//  StatusMenu.swift
//  ActivityTracker
//

import SwiftUI

struct StatusMenu: View {
    @StateObject private var dataHandler = DataHandler()
    @State private var currSession: ActivitySession?
    @State private var currActivityName: String = ""
    @State private var activityState: ActivityState = .inactive
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    @State private var showEmptyWarning = false
    @State private var expandedActivities: Set<String> = []
    
    @State private var hoveredActivity: String?
    @State private var hoveredSession: (String, Date)?
    @State private var sessionCounts: [String: Int] = [:]
    
    var body: some View {
        VStack {
            currentActivityView
            activityControlsView
            Divider()
            Text("Today's Activities")
            activityListView
        }
        .textFieldStyle(.roundedBorder)
        .padding(.all, 10.0)
        .onAppear(perform: updateSessionCounts)
    }
    
    var currentActivityView: some View {
        Group {
            if activityState == .inactive {
                TextField("whatcha doin?", text: $currActivityName)
                    .disableAutocorrection(true)
                    .onSubmit(attemptStartActivity)
                    .onChange(of: currActivityName) { _, newValue in
                        if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showEmptyWarning = false
                        }
                    }
                if showEmptyWarning {
                    Text("Please enter an activity name")
                        .font(.caption)
                }
            } else {
                HStack {
                    Text(currActivityName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Text(timeString(from: elapsedTime))
                }
            }
        }
    }
    
    var activityControlsView: some View {
        HStack {
            switch activityState {
                case .inactive:
                    Button(action: attemptStartActivity) { Label("Start", systemImage: "play") }
                case .active:
                    Button(action: stopActivity) { Label("Stop", systemImage: "stop") }
            }
        }
    }
    
    var activityListView: some View {
        let todayActivities = dataHandler.getTodayActivities()
        
        return Group {
            if todayActivities.isEmpty {
                EmptyView()
            } else {
                let totalDurations = todayActivities.mapValues(DataHandler.sumDurations)
                List {
                    ForEach(Array(totalDurations).sorted(by: { $0.value > $1.value }), id: \.key) { activityName, duration in
                        ActivitySingleView(
                            activityName: activityName,
                            duration: duration,
                            sessions: todayActivities[activityName],
                            sessionCount: sessionCounts[activityName] ?? 0,
                            isExpanded: expandedActivities.contains(activityName),
                            hoveredActivity: hoveredActivity,
                            hoveredSession: hoveredSession,
                            onToggleExpand: { toggleExpanded(activityName) },
                            onDeleteActivity: { deleteActivity(activityName) },
                            onDeleteSession: { deleteSession(activityName, $0) },
                            onHoverSession: { self.hoveredSession = $0 },
                            timeString: timeString,
                            formatTime: formatTime
                        )
                        .onHover { isHovered in
                            hoveredActivity = isHovered ? activityName : nil
                        }
                    }
                }
            }
        }
    }
    
    private func updateSessionCounts() {
        sessionCounts = dataHandler.activities.mapValues { $0.count }
    }
    
    // toggle field
    
    private func toggleExpanded(_ activityName: String) {
        if expandedActivities.contains(activityName) {
            expandedActivities.remove(activityName)
        } else {
            expandedActivities.insert(activityName)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // deleting
    
    private func deleteActivity(_ activityName: String) {
        dataHandler.deleteActivity(activityName: activityName)
        sessionCounts.removeValue(forKey: activityName)
        expandedActivities.remove(activityName)
    }
    
    private func deleteSession(_ activityName: String, _ sessionDate: Date) {
        dataHandler.deleteSession(activityName:activityName, start:sessionDate)
        updateSessionCounts()
        if let count = sessionCounts[activityName], count <= 1 {
            expandedActivities.remove(activityName)
        }
    }
    
    // start, pause, resume, stop
    
    func attemptStartActivity() {
        if currActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showEmptyWarning = true
        } else {
            startActivity()
        }
    }
    
    func startActivity() {
        currSession = dataHandler.startActivity(activityName: currActivityName, start: Date())
        activityState = .active
        startTimer()
    }
//    
//    func pauseActivity() {
//        activityState = .paused
//        stopTimer()
//    }
//    
//    func resumeActivity() {
//        activityState = .active
//        startTimer()
//    }
    
    func stopActivity() {
        if let session = currSession {
            dataHandler.stopActivity(session: session)
            updateSessionCounts()
        }
        resetState()
    }
    
    // timer functions
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetState() {
        activityState = .inactive
        currSession = nil
        currActivityName = ""
        stopTimer()
        elapsedTime = 0
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
