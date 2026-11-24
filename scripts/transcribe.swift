import Foundation
import Speech
import AVFoundation

guard CommandLine.arguments.count > 1 else {
    print("Usage: swift transcribe.swift <audio_or_video_file> [output_json]")
    exit(1)
}

let inputPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : nil
let fileURL = URL(fileURLWithPath: inputPath)

guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID")) else {
    print("Error: Locale id-ID not supported")
    exit(1)
}

if !recognizer.isAvailable {
    print("Error: Recognizer not available")
    exit(1)
}

let request = SFSpeechURLRecognitionRequest(url: fileURL)
request.shouldReportPartialResults = false
if #available(macOS 10.15, *) {
    request.requiresOnDeviceRecognition = false
}

let semaphore = DispatchSemaphore(value: 0)
var resultWords: [[String: Any]] = []
var fullText = ""

recognizer.recognitionTask(with: request) { result, error in
    if let error = error {
        print("Transcription error: \(error.localizedDescription)")
        semaphore.signal()
        return
    }
    
    if let result = result {
        fullText = result.bestTranscription.formattedString
        for segment in result.bestTranscription.segments {
            resultWords.append([
                "word": segment.substring,
                "start": segment.timestamp,
                "duration": segment.duration,
                "end": segment.timestamp + segment.duration,
                "confidence": segment.confidence
            ])
        }
        if result.isFinal {
            semaphore.signal()
        }
    }
}

// Timeout after 60 seconds
let waitResult = semaphore.wait(timeout: .now() + 60)
if waitResult == .timedOut {
    print("Transcription timed out")
}

let outputData: [String: Any] = [
    "text": fullText,
    "words": resultWords
]

if let jsonData = try? JSONSerialization.data(withJSONObject: outputData, options: .prettyPrinted),
   let jsonString = String(data: jsonData, encoding: .utf8) {
    if let outPath = outputPath {
        try? jsonString.write(toFile: outPath, atomically: true, encoding: .utf8)
        print("Transcript saved to \(outPath)")
    } else {
        print(jsonString)
    }
}
