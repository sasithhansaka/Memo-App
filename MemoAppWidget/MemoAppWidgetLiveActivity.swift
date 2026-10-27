//
//  MemoAppWidgetLiveActivity.swift
//  MemoAppWidget
//
//  Created by student3 on 2026-10-27.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MemoAppWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MemoAppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MemoAppWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MemoAppWidgetAttributes {
    fileprivate static var preview: MemoAppWidgetAttributes {
        MemoAppWidgetAttributes(name: "World")
    }
}

extension MemoAppWidgetAttributes.ContentState {
    fileprivate static var smiley: MemoAppWidgetAttributes.ContentState {
        MemoAppWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MemoAppWidgetAttributes.ContentState {
         MemoAppWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MemoAppWidgetAttributes.preview) {
   MemoAppWidgetLiveActivity()
} contentStates: {
    MemoAppWidgetAttributes.ContentState.smiley
    MemoAppWidgetAttributes.ContentState.starEyes
}
