//
//  SearchViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    
    @Published private(set) var memories: [Memory] = []
    @Published var searchText = ""
    @Published var selectedCategory = "All"
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage : String?
    
    private let memoryService: MemoryService
    private var listener: ListenerRegistration?
    
    let categories = [
            "All",
            "Travels",
            "Family",
            "University & Education",
            "Friends",
            "Other"
        ]

    
    init(memoryService: MemoryService = MemoryService()) {
        self.memoryService = memoryService
    }
    
    var allmemories : [Memory] {
        let query = searchText.trimmingCharacters(
                   in: .whitespacesAndNewlines
        )
        
        return memories.filter { memory in
            let matchesCategory = selectedCategory == "All" || memory.category.localizedCaseInsensitiveCompare(selectedCategory) == .orderedSame
            
            let searchableText = [
                   memory.title,
//                           memory.description ?? "",
                   memory.category,
                   memory.placeName ?? "",
                   memory.ocrtext ?? ""
               ]
               .joined(separator: " ")
            
            let matchesSearch = query.isEmpty || searchableText.localizedCaseInsensitiveContains(query)
            
            return matchesCategory && matchesSearch
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
            }, onError: {
                [weak self] error in
                Task { @MainActor in
                    guard let self else { return }

                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        )
        
        if listener == nil && isLoading {
            isLoading = false
        }
    }
    
    func selectedCategory (_ category: String) {
         selectedCategory = category
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
