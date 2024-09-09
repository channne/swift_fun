//
//  InitError.swift
//  ActivityTracker
//

enum InitError: Error {
    case noEnd
    case noDuration
    
    var description : String {
        return "InitError: \(self)"
    }
}
