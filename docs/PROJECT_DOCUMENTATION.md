# Momento iOS — Project Documentation

This guide describes the iOS application in this repository as implemented in source. The Xcode project calls the app target `Memo-app-Ios`; the user-facing display name is `Momento`. Some screens and models still use the MemoMap naming.

## 1. Product overview

Momento is a personal memory journal. Signed-in users can create photo memories with a date, category, story, OCR text, and optional place; browse memories in a home feed, search results, timeline, and map; edit or soft-delete a memory; and create/share photo collages. The app also includes a home-screen widget and optional location-triggered reminders for older memories.

## 2. Technology and targets

- **Platform/UI:** iOS, Swift 5, SwiftUI, UIKit for image handling, PhotosUI for photo selection.
- **Backend:** Firebase Authentication and Cloud Firestore via Swift Package Manager (`firebase-ios-sdk`).
- **Apple frameworks:** MapKit/Core Location, Vision, Speech, UserNotifications, WidgetKit, App Intents, LocalAuthentication, PhotosUI, and UIKit.
- **Targets:** `Memo-app-Ios` (application), `MemoAppWidget` (widget extension), and `Memo-app-IosTests` (Swift Testing target).
- **Deployment target:** iOS 26.2, as declared in the Xcode project at the time this guide was written.
- **Shared widget storage:** App Group `group.sasith.memomap`.

## 3. Repository map

```text
Memo-app-Ios/
  App/RootView.swift                 onboarding/auth/lock routing
  Views/Authentication/              login and registration
  Views/Onboard/                     onboarding
  Views/Home/                        dashboard and recent memories
  Views/Memory/                      create, detail, edit, location picker
  Views/Search/                      live search and category filters
  Views/Timeline/                    memories grouped by year
  Views/Map/                         map and location pins
  Views/Profile/                     profile and account actions
  Views/Collage/                     collage creation, templates, editor, preview
  ViewModels/                        feature state and presentation logic
  Models/                            Memory and collage template models
  Services/Memory/                   Firestore, image encoding, OCR, speech
  Services/Location/                 geofences and local notifications
  Services/WidgetSync/               app-to-widget data synchronization
  Services/Collage/                  collage rendering/sharing support
  Theme/                             colors and font helpers
MemoAppWidget/                       WidgetKit extension and shared data model
Memo-app-IosTests/                   Swift Testing tests
Memo-app-Ios.xcodeproj/              targets, package references, schemes
```

`ContentView.swift` is the default SwiftUI sample view and is not the active app entry screen. `Memo_app_IosApp` presents `RootView`.

## 4. App startup and navigation

`Memo_app_IosApp` installs `AppDelegate`, creates shared `AuthViewModel` and `AppLockManager` instances, and observes scene phase to notify the app lock when the app backgrounds or becomes active. `AppDelegate` configures Firebase at launch.

`RootView` applies this routing order:

1. Show onboarding until the `hasCompletedOnboarding` `AppStorage` flag is true.
2. Show login when Firebase has no authenticated user.
3. Show the app lock when `AppLockManager` says the session is locked.
4. Otherwise show `MainTabView`.

The main tab bar switches among Home, Map, Add, Timeline, and Profile. Search and memory detail/edit screens are pushed from other screens using navigation links. Home, search, timeline, and map view models attach Firestore snapshot listeners when their screens appear and remove those listeners when they disappear.

When an authenticated, unlocked session is active, `RootView` starts widget synchronization and location reminder monitoring. If the user is logged out or locked, widget sync is stopped.

## 5. Feature guide

### Authentication and profile

`AuthViewModel` observes Firebase auth state, registers email/password accounts, signs in, signs out, and reads the user's `fullName` from Firestore. Registration validates a non-empty name and email, a basic email pattern, a password of at least eight characters, and matching confirmation. A successful registration creates `users/{uid}` with `uid`, `fullName`, `email`, and server `createdAt`.

### Home

Home offers a greeting, a route to search, a create-memory call to action, collection counts, and the five most recently created memories. Counts are derived from the active in-memory collection: all memories, total photos, memories created in the current year, and memories created in the last three months (the latter is labeled “Places” in the current UI).

### Create and edit memory

The add and edit forms support a title (maximum 80 characters), description, category, memory date, up to 10 selected photos, optional place, and OCR text. Categories are `Travels`, `Family`, `University & Education`, `Friends`, and `Other`. OCR is run for selected images with Vision and collected into the memory's searchable OCR field. The description flow can append speech-to-text input using the Speech framework. Location selection uses the app's location picker and stores a place label and coordinates.

On save, the service requires a signed-in user and at least one photo, encodes images as JPEG/Base64, and rejects an aggregate encoded photo payload over 600,000 UTF-8 bytes. The first encoded photo is the cover. Image compression/resizing is handled by `MemoryImageEncoder`.

### Memory detail, update, and delete

Detail displays a memory's photos and stored metadata; the view model decodes the Base64 images and builds OCR/category tags. Update fetches the document, verifies ownership and that it is not deleted, restores its form state, and persists edited fields. Delete is a **soft delete**: it sets `isDeleted` to `true`, so the document remains in Firestore but is excluded from normal memory listeners.

### Search

Search listens to the signed-in user's memories and filters locally by category and case-insensitive text. Searchable fields in the current implementation are title, category, place name, and OCR text. Description is currently not included. Search does not issue a Firestore full-text query.

### Timeline

Timeline groups memories by the year of `memoryDate`, with years descending and memories within each year ordered newest event date first (then newest creation date).

### Map

The map displays valid non-zero coordinates from the user's memories. Selecting a memory centers and zooms the map. When there are multiple locations, the view model calculates a region that fits their coordinate bounds. The initial map region is centered on Colombo, Sri Lanka.

### Location reminders

`LocationNotificationManager` uses Core Location circular geofences and local notifications. It requires **Always** location authorization for background monitoring and requests notification authorization when needed. It considers up to 20 most recent eligible memory locations and monitors a 1,000-meter radius. On region entry, it fetches the memory again, checks owner, deletion state, and age, then schedules a local notification. Memories must be at least 30 days old; `notify_date` prevents another notification until 30 days after the last notification. Actual delivery depends on iOS permissions, geofence availability, and OS scheduling.

### Collages

Collage templates are `Memory Story`, `Scrapbook`, `Film Strip`, `Classic Grid`, and `Travel Journal`. Each template declares a photo minimum (one for Scrapbook, two for the others) and maximum (four or five). Creation, selection, preview, editing, rendering, and share-sheet code lives in `Views/Collage`, `CollageViewModel`, and `Services/Collage`. Collages are generated for sharing; the memory Firestore schema does not include a collage collection.

### Widget

The WidgetKit extension supports small and medium families. The app writes a Codable snapshot of memories (identifier, title, memory date, place, and cover image Base64) to shared `UserDefaults` under App Group `group.sasith.memomap`, key `savedWidgetMemories`. The widget cycles through cached memories using timeline entries and refreshes on an hourly policy. It does not query Firebase directly. Empty cache shows a prompt to save a memory.

### App lock

`AppLockManager` and `AppLockView` provide the local app-lock flow and lifecycle response. The lock is a device-side privacy gate; Firebase Authentication remains the account boundary. See the implementation for the precise biometric/passcode behavior configured on the device.

## 6. Data model and Firestore contract

### `users/{uid}`

| Field | Type | Meaning |
|---|---|---|
| `uid` | string | Firebase Auth user ID |
| `fullName` | string | Profile display name |
| `email` | string | Account email |
| `createdAt` | server timestamp | Registration time |

### `memories/{memoryId}`

| Field | Type | Meaning |
|---|---|---|
| `userID` | string | Owner UID; queried by each user's listener |
| `title` | string | Memory title |
| `description` | string or null | User story |
| `category` | string | One of the five supported categories |
| `memoryDate` | Firestore timestamp | Date the remembered event occurred |
| `photosBase64` | array of strings or null | JPEG image payloads, Base64 encoded |
| `coverPhotoBase64` | string | First/cover JPEG image payload |
| `ocrText` | string or null | Extracted text, used in local search |
| `latitude`, `longitude` | number | Place coordinates; zero defaults represent no saved coordinate |
| `placeName` | string or null | Human-readable place |
| `createdAt`, `updatedAt` | Firestore timestamps | Record creation and last edit |
| `isDeleted` | boolean | Soft-delete flag |
| `notify_date` | timestamp or null | Last location reminder date |

`Memory.firestoreData` is the serialization contract and `Memory(document:)` parses listener snapshots. `MemoryService.getMemory` additionally checks that the document exists, belongs to the current user, and is not deleted. The listener queries `memories` by `userID`, filters deleted items client-side, then sorts by `memoryDate` and `createdAt` descending.

**Backend configuration required:** Firebase Authentication email/password sign-in and Cloud Firestore must be enabled in the Firebase project. Firestore security rules are not included in this repository; configure rules that restrict `users/{uid}` and `memories/{id}` reads/writes to the authenticated owner. Client-side ownership checks do not replace server-side rules.

## 7. Build and run

### Requirements

- A Mac with an Xcode version that supports the project's iOS 26.2 deployment target and Swift 5 project settings.
- An Apple development team for device signing and widget/App Group capabilities.
- A Firebase project configured for iOS, with Authentication (Email/Password) and Firestore enabled.

### Steps

1. Open `Memo-app-Ios.xcodeproj` in Xcode.
2. Confirm the app's bundle identifier (`Sasith.Memo-app-Ios`) is registered in your Firebase project and Apple developer account, or update the bundle identifiers consistently in the project and Firebase configuration.
3. Add/download the matching `GoogleService-Info.plist` for the Firebase iOS app and ensure it is included in the app target. A plist is present in this repository; treat it as environment-specific configuration and verify its Firebase project before use.
4. In Xcode, resolve Swift Package Manager dependencies. The project references Firebase Auth, Core, and Firestore from `firebase-ios-sdk`; the resolved versions are recorded in `project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
5. Verify signing and App Group capability `group.sasith.memomap` for both app and widget targets. The entitlements files declare the group.
6. Select the `Memo-app-Ios` scheme and run on a simulator/device. Location reminders and widgets require device/system authorization and are best validated on a real device.

The project uses Xcode project settings rather than a `Package.swift`, Podfile, or separate backend server. No command-line build instructions are provided because the repository targets Apple tooling and no build was run while preparing this document.

## 8. Permissions and privacy-sensitive APIs

The app declares usage descriptions for Face ID, foreground/background location, microphone, and speech recognition. Runtime authorization is still required. Photo selection uses the system Photos picker. Location coordinates, image payloads, and memory text are stored in the user's Firestore documents; the widget also caches selected memory details and Base64 cover images in the shared App Group container. Review Firebase rules, privacy disclosures, retention, and notification permission behavior before distribution.

## 9. Tests

Tests are in `Memo-app-IosTests` and use Apple's Swift Testing framework. Current coverage includes authentication input validation and initial/profile state, plus initial HomeViewModel statistics/listener loading state. Several profile/logout checks depend on Firebase's current runtime auth state. These are not a substitute for Firestore integration, image/OCR, location/geofence, widget, UI, or end-to-end tests. Tests were not run as part of preparing this documentation.

## 10. Known implementation notes

- The repository contains no Firestore rules, backend functions, or schema migration tooling.
- Images are stored inline as Base64 strings in Firestore documents. The service enforces its own aggregate payload threshold, but this choice affects document size, bandwidth, and image loading. Firebase Storage is not used by the current service.
- Search is client-side over the listener's loaded memory set and excludes description text.
- Widget content is a cached snapshot; it can lag behind Firestore until the app runs its sync flow and WidgetKit refreshes it.
- Geofences and local notification delivery are subject to iOS limits and permission state. The manager caps monitored regions at 20 and skips memories younger than 30 days.
- `AppIntent.swift` contains a sample configuration intent, while the widget itself uses `StaticConfiguration`; the intent is not currently used for widget configuration.
- The default `ContentView` and generic example test are template scaffolding; the app starts at `RootView`.
- UI strings, Firebase error mapping, date handling, and image payload logic are currently implemented directly in Swift source rather than localized or documented through a separate API schema.

## 11. Key files

- App entry/routing: `Memo-app-Ios/Memo_app_IosApp.swift`, `Memo-app-Ios/App/RootView.swift`
- Authentication: `Memo-app-Ios/ViewModels/AuthViewModel.swift`, `Memo-app-Ios/Views/Authentication/`
- Memory model/backend operations: `Memo-app-Ios/Models/MemoryModel.swift`, `Memo-app-Ios/Services/Memory/MemoryService.swift`
- Create/edit flows: `Memo-app-Ios/Views/Memory/`, `Memo-app-Ios/ViewModels/AddMemoryViewModel.swift`, `Memo-app-Ios/ViewModels/UpdateMemoryViewModel.swift`
- Location reminders: `Memo-app-Ios/Services/Location/LocationNotificationManager.swift`
- Widget sync/extension: `Memo-app-Ios/Services/WidgetSync/MemoryWidgetSync.swift`, `MemoAppWidget/`
- Collage flow: `Memo-app-Ios/Views/Collage/`, `Memo-app-Ios/Services/Collage/`
- Project and schemes: `Memo-app-Ios.xcodeproj/`
