//
//  ActivityTrackerApp.swift
//  ActivityTracker
//

import SwiftUI

@main // entry point
struct ActivityTrackerApp: App { // conforms to App protocol
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    
    var body: some Scene {
        MenuBarExtra("ActivityTrackerApp", systemImage: "hourglass", isInserted: $showMenuBarExtra) {
            StatusMenu()
        }.menuBarExtraStyle(.window)
        
//        WindowGroup{
//            ContentView()
//        }
    }
}
