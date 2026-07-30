import Foundation
import Vision
import AppKit

let fm = FileManager.default
let desktop = URL(fileURLWithPath: "/Users/Work/Desktop")
let outURL = URL(fileURLWithPath: "/Users/Work/Desktop/ERP/province_ocr_all.txt")
let files = try fm.contentsOfDirectory(at: desktop, includingPropertiesForKeys: nil)
    .filter { $0.pathExtension.lowercased() == "png" && $0.deletingPathExtension().lastPathComponent.lowercased().contains("province") }
    .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }

var output = ""
for file in files {
    output += "=== \(file.lastPathComponent) ===\n"
    guard let image = NSImage(contentsOf: file) else {
        output += "[ERROR: Failed to load image]\n\n"
        continue
    }

    var rect = NSRect(origin: .zero, size: image.size)
    guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
        output += "[ERROR: Failed to create CGImage]\n\n"
        continue
    }

    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = ["en-US"]

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
        let observations = request.results ?? []
        for obs in observations {
            if let candidate = obs.topCandidates(1).first {
                output += candidate.string + "\n"
            }
        }
    } catch {
        output += "[ERROR: \(error.localizedDescription)]\n"
    }
    output += "\n"
}

try output.write(to: outURL, atomically: true, encoding: .utf8)
print("WROTE \(outURL.path)")
