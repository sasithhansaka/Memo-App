//
//  TimelineViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class TimelineViewModel: ObservableObject {

    @Published private(set) var memories: [Memory] = []
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?

    private let memoryService: MemoryService
    private var listener: ListenerRegistration?

    init(memoryService: MemoryService = MemoryService()) {
        self.memoryService = memoryService
    }

    var groupedYears: [(year: Int, memories: [Memory])] {

        let grouped = Dictionary(grouping: memories) { memory in
            Calendar.current.component(
                .year,
                from: memory.memoryDate
            )
        }

        return grouped.keys.sorted(by: >).map { year in
            let yearMemories = (grouped[year] ?? []).sorted {
                if $0.memoryDate != $1.memoryDate {
                    return $0.memoryDate > $1.memoryDate
                }

                return $0.createdAt > $1.createdAt
            }

            return (year: year, memories: yearMemories)
        }
    }


    func startListening() {
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


    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
