//
//  LocationNotificationManager.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-20.
//

import Foundation
import CoreLocation
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class LocationNotificationManager: NSObject,
                                         ObservableObject,
                                         CLLocationManagerDelegate {

    static let shared = LocationNotificationManager()

    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let db = Firestore.firestore()
    private let memoryService = MemoryService()

    private var memoryListener: ListenerRegistration?
    private var processingMemoryIDs = Set<String>()

    private let radius: CLLocationDistance = 1000
    private let maximumRegions = 20

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    func start() {
        
        func start() {
            print("📍 LocationNotificationManager started")

            print(
                "📍 Location authorization:",
                locationManager.authorizationStatus.rawValue
            )

            print(
                "📍 Region monitoring available:",
                CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
            )

            requestNotificationPermission()

            // Keep the rest of your existing start() implementation.
        }
        requestNotificationPermission()

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse:
            print("When In Use permission already granted.")

        case .authorizedAlways:
            startListeningForMemories()

        case .denied, .restricted:
            print("Location permission is denied or restricted.")

        @unknown default:
            break
        }
    }

    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error {
                print("Notification permission error:", error.localizedDescription)
            }

            if !granted {
                print("Local notifications are not permitted.")
            }
        }
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            startListeningForMemories()

        case .authorizedWhenInUse:
            // Do not request Always permission every time this callback runs.
            // Request it through a deliberate onboarding step.
            print("Location authorized while using the app.")

        case .denied, .restricted:
            print("Location permission denied or restricted.")
            stopListeningAndMonitoring()

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }
    private func startListeningForMemories() {
        guard memoryListener == nil else { return }

        memoryListener = memoryService.getTimlineMemories(
            onChange: { [weak self] memories in
                Task { @MainActor in
                    self?.updateMonitoredRegions(with: memories)
                }
            },
            onError: { error in
                print("Memory listener error:", error.localizedDescription)
            }
        )
    }

    private func updateMonitoredRegions(with memories: [Memory]) {
  
        let candidates = memories
            .filter { !$0.isDeleted }
            .filter {
                CLLocationCoordinate2DIsValid(
                    CLLocationCoordinate2D(
                        latitude: $0.latitude,
                        longitude: $0.longitude
                    )
                )
            }
            .filter {
                !($0.latitude == 0 && $0.longitude == 0)
            }
            .sorted {
                if $0.memoryDate != $1.memoryDate {
                    return $0.memoryDate > $1.memoryDate
                }
                return $0.createdAt > $1.createdAt
            }
            .prefix(maximumRegions)

        let selectedMemories = Array(candidates)
        let selectedIDs = Set(selectedMemories.map(\.id))

        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion else {
                locationManager.stopMonitoring(for: region)
                continue
            }

            if !selectedIDs.contains(circularRegion.identifier) {
                locationManager.stopMonitoring(for: region)
            }
        }

        let currentlyMonitoredIDs = Set(
            locationManager.monitoredRegions.map(\.identifier)
        )

        for memory in selectedMemories
        where !currentlyMonitoredIDs.contains(memory.id) {
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: memory.latitude,
                    longitude: memory.longitude
                ),
                radius: radius,
                identifier: memory.id
            )

            region.notifyOnEntry = true
            region.notifyOnExit = false

            locationManager.startMonitoring(for: region)
        }
    }

    private func isEligible(notifyDate: Date?) -> Bool {
        guard let notifyDate else { return true }

        guard let cutoff = Calendar.current.date(
            byAdding: .day,
            value: -30,
            to: Date()
        ) else {
            return false
        }

        return notifyDate <= cutoff
    }

    func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        let memoryID = region.identifier

        guard !processingMemoryIDs.contains(memoryID) else { return }
        processingMemoryIDs.insert(memoryID)

        Task {
            defer {
                processingMemoryIDs.remove(memoryID)
            }

            await handleRegionEntry(memoryID: memoryID)
        }
    }

    private func handleRegionEntry(memoryID: String) async {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }

        let document = db.collection("memories").document(memoryID)

        do {
            let snapshot = try await document.getDocument()

            guard
                let data = snapshot.data(),
                data["userID"] as? String == currentUserID,
                (data["isDeleted"] as? Bool ?? false) == false
            else {
                return
            }

            let lastNotified: Date?

            if let timestamp = data["notify_date"] as? Timestamp {
                lastNotified = timestamp.dateValue()
            } else {
                lastNotified = nil
            }

            guard isEligible(notifyDate: lastNotified) else {
                return
            }

            let memoryTitle = data["title"] as? String ?? "your memory"
            let content = UNMutableNotificationContent()
            content.title = "A memory is nearby"
            content.body = "You're near \"\(memoryTitle)\". Revisit the moment you saved here."
            content.sound = .default
            content.userInfo = ["memoryID": memoryID]

            // Unique request ID prevents multiple pending requests
            // for the same memory.
            let request = UNNotificationRequest(
                identifier: "memory-\(memoryID)",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(
                    timeInterval: 1,
                    repeats: false
                )
            )

            try await notificationCenter.add(request)

            // Store the date only after the notification request succeeds.
            try await memoryService.updateNotifyDate(
                memoryID: memoryID,
                date: Date()
            )

        } catch {
            print(
                "Could not send location notification:",
                error.localizedDescription
            )
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error:", error.localizedDescription)
    }

    private func stopListeningAndMonitoring() {
        memoryListener?.remove()
        memoryListener = nil

        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func refresh() {
        guard locationManager.authorizationStatus == .authorizedAlways else {
            return
        }

        if memoryListener == nil {
            startListeningForMemories()
        }
    }

    deinit {
        memoryListener?.remove()
    }
}
