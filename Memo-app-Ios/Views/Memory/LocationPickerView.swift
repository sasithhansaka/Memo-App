//
//  LocationPickerView.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//

import SwiftUI
import MapKit
import CoreLocation

struct MemoryLocationPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let onSelect: (String, Double, Double) -> Void

    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedPlaceName = ""
    @State private var isSearching = false
    @State private var isResolvingPlace = false
    @State private var errorMessage: String?

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 6.9271,
                longitude: 79.8612
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.08,
                longitudeDelta: 0.08
            )
        )
    )

    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search for a place", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                        errorMessage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if !searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty {
                VStack(spacing: 0) {
                    if isSearching {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Finding places...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(12)
                    }

                    ForEach(
                        Array(searchResults.enumerated()),
                        id: \.offset
                    ) { _, item in
                        Button {
                            selectPlace(item)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.green)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "Unnamed place")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)

                                    Text(
                                        item.placemark.title
                                        ?? "Location"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "arrow.up.left")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider()
                    }

                    if !isSearching &&
                        searchResults.isEmpty &&
                        errorMessage == nil {
                        Text("No matching places found.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.separator).opacity(0.3))
                }
                .padding(.horizontal)
                .zIndex(1)
            }

            MapReader { proxy in
                Map(position: $cameraPosition) {
                    if let coordinate = selectedCoordinate {
                        Marker(
                            selectedPlaceName.isEmpty
                                ? "Selected location"
                                : selectedPlaceName,
                            coordinate: coordinate
                        )
                        .tint(.green)
                    }
                }
                .onTapGesture { position in
                    guard let coordinate = proxy.convert(
                        position,
                        from: .local
                    ) else {
                        return
                    }

                    selectMapCoordinate(coordinate)
                }
                .overlay(alignment: .top) {
                    if isResolvingPlace {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Finding place name...")
                                .font(.caption)
                        }
                        .padding(10)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 12)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let coordinate = selectedCoordinate {
                    VStack(alignment: .leading, spacing: 5) {
                        Label(
                            "Selected location",
                            systemImage: "mappin.and.ellipse"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Text(
                            selectedPlaceName.isEmpty
                                ? "Getting place details..."
                                : selectedPlaceName
                        )
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)

                        Text(
                            String(
                                format: "%.5f, %.5f",
                                coordinate.latitude,
                                coordinate.longitude
                            )
                        )
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(12)
                }
            }

            Button {
                guard let coordinate = selectedCoordinate else {
                    errorMessage = "Search for a place or tap on the map."
                    return
                }

                guard !isResolvingPlace else {
                    return
                }

                let name = selectedPlaceName.isEmpty
                    ? "Selected location"
                    : selectedPlaceName

                onSelect(
                    name,
                    coordinate.latitude,
                    coordinate.longitude
                )

                dismiss()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Use This Location")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(
                    selectedCoordinate == nil || isResolvingPlace
                        ? Color.gray
                        : Color.green
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(
                selectedCoordinate == nil || isResolvingPlace
            )
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle("Memory Location")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: searchText) {
            await searchPlacesDebounced()
        }
    }

    @MainActor
    private func searchPlacesDebounced() async {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        searchResults = []
        errorMessage = nil

        guard !query.isEmpty else {
            isSearching = false
            return
        }

        do {
            // Wait until the user pauses typing.
            try await Task.sleep(for: .milliseconds(350))
        } catch {
            return
        }

        guard !Task.isCancelled else {
            return
        }

        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        do {
            let response = try await MKLocalSearch(
                request: request
            ).start()

            guard !Task.isCancelled else {
                return
            }

            guard query == searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) else {
                return
            }

            searchResults = Array(response.mapItems.prefix(6))

            if searchResults.isEmpty {
                errorMessage = "No matching places found."
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }

            errorMessage = "Could not search places. Please try again."
        }
    }

    // MARK: - Select Search Result

    private func selectPlace(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate

        selectedCoordinate = coordinate
        selectedPlaceName = item.name
            ?? item.placemark.title
            ?? "Selected location"

        searchText = ""
        searchResults = []
        errorMessage = nil

        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.015,
                    longitudeDelta: 0.015
                )
            )
        )
    }

    @MainActor
    private func selectMapCoordinate(
        _ coordinate: CLLocationCoordinate2D
    ) {
        selectedCoordinate = coordinate
        selectedPlaceName = ""
        errorMessage = nil
        searchText = ""
        searchResults = []
        isResolvingPlace = true

        Task { @MainActor in
            defer { isResolvingPlace = false }

            let location = CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )

            let geocoder = CLGeocoder()

            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(
                    location,
                    preferredLocale: Locale(identifier: "en_US")
                )

                guard selectedCoordinate?.latitude == coordinate.latitude,
                      selectedCoordinate?.longitude == coordinate.longitude
                else {
                    return
                }

                if let place = placemarks.first {
                    selectedPlaceName =
                        place.name
                        ?? place.thoroughfare
                        ?? place.subLocality
                        ?? place.locality
                        ?? place.administrativeArea
                        ?? "Selected location"
                } else {
                    selectedPlaceName = "Selected location"
                }
            } catch {
                selectedPlaceName = "Selected location"
            }
        }
    }
}
