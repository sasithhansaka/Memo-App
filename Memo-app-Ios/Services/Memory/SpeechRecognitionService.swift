//
//  SpeechRecognitionService.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-16.
//

import Foundation
import Speech
import AVFoundation

import Combine

@MainActor
final class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(
        locale: Locale(identifier: "en-US")
    )

    private let audioEngine = AVAudioEngine()

    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var isStoppingNormally = false

    func startRecording() {
        guard !isRecording else { return }

        errorMessage = nil
        isStoppingNormally = false

        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition is currently unavailable."
            return
        }

        Task {
            let authorization = await withCheckedContinuation {
                (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in

                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }

            guard authorization == .authorized else {
                errorMessage = "Please allow Speech Recognition in Settings."
                return
            }

            let microphoneAllowed =
                await AVAudioApplication.requestRecordPermission()

            guard microphoneAllowed else {
                errorMessage = "Please allow microphone access in Settings."
                return
            }

            do {
                try beginRecognition(using: recognizer)
            } catch {
                stopAudioInput()
                errorMessage = error.localizedDescription
            }
        }
    }

    private func beginRecognition(
        using recognizer: SFSpeechRecognizer
    ) throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let session = AVAudioSession.sharedInstance()

        try session.setCategory(
            .record,
            mode: .measurement,
            options: .duckOthers
        )
        try session.setActive(true)

        let newRequest = SFSpeechAudioBufferRecognitionRequest()
        newRequest.shouldReportPartialResults = true
        request = newRequest

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { buffer, _ in
            newRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true

        recognitionTask = recognizer.recognitionTask(
            with: newRequest
        ) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }

                if let result {
                    self.recognizedText =
                        result.bestTranscription.formattedString
                }

                if let error {
                    // Don't show an error for an intentional stop.
                    if !self.isStoppingNormally {
                        self.errorMessage =
                            "Speech recognition stopped unexpectedly. Please try again."
                    }

                    self.finishRecognition()
                    return
                }

                if result?.isFinal == true {
                    self.finishRecognition()
                }
            }
        }
    }

    // Called when the user taps Stop.
    func stopRecording() {
        guard isRecording else { return }

        isStoppingNormally = true
        isRecording = false

        stopAudioInput()
        request?.endAudio()
    }

    private func stopAudioInput() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    private func finishRecognition() {
        stopAudioInput()

        request = nil
        recognitionTask = nil
        isRecording = false
        isStoppingNormally = false
    }
}
