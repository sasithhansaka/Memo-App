//
//  MemoAppWidgetBundle.swift
//  MemoAppWidget
//
//  Created by student3 on 2026-10-27.
//

import WidgetKit
import SwiftUI

@main
struct MemoAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        MemoAppWidget()
        MemoAppWidgetControl()
        MemoAppWidgetLiveActivity()
    }
}
