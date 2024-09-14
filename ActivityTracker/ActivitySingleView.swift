//
//  ActivitySingleView.swift
//  ActivityTracker
//

import SwiftUI

struct ActivitySingleView: View {
    let activityName: String
    let duration: TimeInterval
    let sessions: [Date: TimeInterval]?
    let sessionCount: Int
    let isExpanded: Bool
    let hoveredActivity: String?
    let hoveredSession: (String, Date)?
    var onToggleExpand: () -> Void
    var onDeleteActivity: () -> Void
    var onDeleteSession: (Date) -> Void
    var onHoverSession: ((String, Date)?) -> Void
    var timeString: (TimeInterval) -> String
    var formatTime: (Date) -> String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(activityName)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Text(timeString(duration))
                    .font(.system(.body, design: .monospaced))
                
                if hoveredActivity == activityName {
                    if sessionCount > 1 {
                        Button(action: onToggleExpand) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        }
                    } else {
                        Button(action: onDeleteActivity) {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded, let sessions = sessions {
                ForEach(sessions.sorted(by: { $0.key < $1.key }), id: \.key) { date, sessionDuration in
                    HStack {
                        Text(formatTime(date))
                        Spacer()
                        Text(timeString(sessionDuration))
                        if hoveredSession?.0 == activityName && hoveredSession?.1 == date {
                            Button(action: { onDeleteSession(date) }) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.leading)
                    .onHover { isHovered in
                        onHoverSession(isHovered ? (activityName, date) : nil)
                    }
                }
            }
        }
    }
}
