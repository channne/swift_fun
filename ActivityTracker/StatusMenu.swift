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
    
    var body: some View {
        VStack {
            if activityState == .inactive {
                TextField("whatcha doin?", text: $currActivityName)
                    .disableAutocorrection(true)
                    .onSubmit {
                        startActivity()
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
            
            HStack {
                switch activityState {
                    case .inactive:
                        Button(action: startActivity) { Label("Start", systemImage: "play") }
                    case .active:
//                        Button(action: pauseActivity) { Label("Pause", systemImage: "pause") }
                        Button(action: stopActivity) { Label("Stop", systemImage: "stop") }
//                    case .paused:
//                        Button(action: resumeActivity) { Label("Resume", systemImage: "play") }
//                        Button(action: stopActivity) {
//                            Label("Stop", systemImage: "stop")
//                        }
                }
            }
            Divider()
            Text("Today's Activities")
            let todayActivities = dataHandler.getTodayActivities()
            if !todayActivities.isEmpty {
                List {
                    ForEach(Array(todayActivities).sorted(by: { $0.value > $1.value }), id: \.key) { activityName, duration in
                        HStack {
                            Text(activityName)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                            Text(timeString(from: duration))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .padding(.all, 10.0)
    }
    
    // start, pause, resume, stop
    
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
            dataHandler.stopActivity(session: session, duration: elapsedTime)
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
