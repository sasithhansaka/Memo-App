//
//  HomeView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-01.
//

import Combine
import Foundation
import SwiftUI
import UIKit

struct HomeView: View {
    var body: some View {
        
        Text("Home")
        NavigationStack{
            NavigationLink{
                SearchView()
            }label: {
                Text("Search Memories")
                    .foregroundStyle(MemoMapTheme.green)
            }
        }
    }
}

#Preview {
    HomeView()
}
