//
//  HomeViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

@MainActor
final class HomeViewModel : ObservableObject {
    
    
    @Published private(set) var memories: [Memory] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let memoryService: MemoryService
    private var listener: ListenerRegistration?
    
    init(memoryService: MemoryService = MemoryService()) {
        self.memoryService = memoryService
    }
    
    public func startListening(){
        guard listener == nil else { return }

        isLoading = true
        errorMessage = nil

        listener = memoryService.getTimlineMemories(
            onChange: { [weak self] memories in
                Task { @MainActor in
                    guard let self else { return }

                    self.memories = memories
                    self.isLoading = false
                    self.errorMessage = nil
                }
            },
            onError: { [weak self] error in
                Task { @MainActor in
                    guard let self else { return }

                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        )
        
    }
    
    public var totalMemories: Int {
        memories.count
    }
    
    public var recentMemoryCount: Int {
        let threeMonthsAgo = Calendar.current.date(
               byAdding: .month,
               value: -3,
               to: Date()
           ) ?? Date()
        
        return memories.filter {
              $0.createdAt >= threeMonthsAgo
          }.count
    }
    
    public var thisYearTotal: Int {
        let thisYear = Calendar.current.component(.year,from: Date())
           
        return memories.filter {
                Calendar.current.component(.year, from: $0.createdAt) == thisYear
            }.count
    }
    
    var recentMemories: [Memory] {
            Array(
                memories.sorted {
                    $0.createdAt > $1.createdAt
                }.prefix(5)
            )
        }
    
    
    
    public func stopListening(){
        listener?.remove()
        listener = nil
    }
}
