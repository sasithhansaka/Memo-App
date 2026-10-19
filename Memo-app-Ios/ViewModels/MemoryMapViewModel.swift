//
//  MemoryMapViewModel.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-19.
//

import Foundation
import MapKit
import FirebaseFirestore
import Combine
import SwiftUI

@MainActor
final class MemoryMapViewModel: ObservableObject {

    @Published private(set) var memories: [Memory] = []
    @Published var selectedMemoryID: String?
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?

    @Published var cameraPosition: MapCameraPosition = .region(

        MKCoordinateRegion(

            center: CLLocationCoordinate2D(
                latitude: 6.9271,
                longitude: 79.8612
            ),
            
            span: MKCoordinateSpan(
                latitudeDelta: 0.12,
                longitudeDelta: 0.12
            )
            
        )

    )

    private let memoryService: MemoryService
    private var listener: ListenerRegistration?

    init(memoryService: MemoryService = MemoryService()) {
        self.memoryService = memoryService
    }

    var memoriesWithLocations: [Memory] {
        memories.filter {
            CLLocationCoordinate2DIsValid(
                CLLocationCoordinate2D(
                    latitude: $0.latitude,
                    longitude: $0.longitude
                )
            )
            && ($0.latitude != 0 || $0.longitude != 0)
        }
    }

    var selectedMemory: Memory? {
        if let selectedMemoryID {
            return memoriesWithLocations.first {
                $0.id == selectedMemoryID
            }
        }

        return memoriesWithLocations.first
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

                    if let selectedID = self.selectedMemoryID,
                       !memories.contains(where: { $0.id == selectedID }) {
                        self.selectedMemoryID = nil
                    }

                    if self.selectedMemoryID == nil {
                        self.selectedMemoryID =
                            self.memoriesWithLocations.first?.id
                    }

                    self.fitMapToLocations()
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

    func selectMemory(_ memory: Memory) {
        selectedMemoryID = memory.id

        let coordinate = CLLocationCoordinate2D(
            latitude: memory.latitude,
            longitude: memory.longitude
        )

        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.035,
                    longitudeDelta: 0.035
                )
            )
        )
    }

    private func fitMapToLocations() {
        let locations = memoriesWithLocations

        guard !locations.isEmpty else { return }

        guard locations.count > 1 else {
            let memory = locations[0]

            cameraPosition = .region(
                MKCoordinateRegion(

                    center: CLLocationCoordinate2D(

                        latitude: memory.latitude,
                        longitude: memory.longitude

                    ),

                    span: MKCoordinateSpan(

                        latitudeDelta: 0.08,
                        longitudeDelta: 0.08

                    )
                )
            )
            return
        }

        let latitudes = locations.map(\.latitude)
        let longitudes = locations.map(\.longitude)

        let minLatitude = latitudes.min()!
        let maxLatitude = latitudes.max()!
        let minLongitude = longitudes.min()!
        let maxLongitude = longitudes.max()!

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )

        cameraPosition = .region(

            MKCoordinateRegion(

                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: max(
                        (maxLatitude - minLatitude) * 1.5,
                        0.025
                    ),

                    longitudeDelta: max(
                        (maxLongitude - minLongitude) * 1.5,
                        0.025
                    )

                )

            )
        )
    }
}
