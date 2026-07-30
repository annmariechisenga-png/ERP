import Foundation
import PDFKit
import Vision
import AppKit

let inputFiles = [
    "/Users/Work/Downloads/FireSUZ 2024.pdf",
    "/Users/Work/Downloads/2025 Management.pdf",
    "/Users/Work/Downloads/2025 Collective Agreement Unionized.pdf"
]

let outDir = URL(fileURLWithPath: "/Users/Work/Desktop/ERP/extracted_data/payroll_pdf_text")
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

func ocrImage(_ image: NSImage) -> [String] {
    var lines: [String] = []
    var rect = NSRect(origin: .zero, size: image.size)
    guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
        return lines
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
            if let top = obs.topCandidates(1).first {
                lines.append(top.string)
            }
        }
    } catch {
        lines.append("[OCR ERROR: \(error.localizedDescription)]")
    }
    return lines
}

for file in inputFiles {
    let url = URL(fileURLWithPath: file)
    guard let pdf = PDFDocument(url: url) else {
        print("FAILED", file)
        continue
    }

    var output = ""
    for idx in 0..<pdf.pageCount {
        guard let page = pdf.page(at: idx) else { continue }
        let bounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 2.0
        let width = Int(bounds.width * scale)
        let height = Int(bounds.height * scale)

        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            output += "\n\n=== PAGE \(idx + 1) ===\n[RENDER ERROR]\n"
            continue
        }

        NSGraphicsContext.saveGraphicsState()
        if let ctx = NSGraphicsContext(bitmapImageRep: rep) {
            NSGraphicsContext.current = ctx
            ctx.cgContext.setFillColor(NSColor.white.cgColor)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
            ctx.cgContext.scaleBy(x: scale, y: scale)
            page.draw(with: .mediaBox, to: ctx.cgContext)
            NSGraphicsContext.restoreGraphicsState()

            let img = NSImage(size: NSSize(width: width, height: height))
            img.addRepresentation(rep)
            let lines = ocrImage(img)
            output += "\n\n=== PAGE \(idx + 1) ===\n" + lines.joined(separator: "\n") + "\n"
        } else {
            NSGraphicsContext.restoreGraphicsState()
            output += "\n\n=== PAGE \(idx + 1) ===\n[CONTEXT ERROR]\n"
        }
    }

    let outFile = outDir.appendingPathComponent(url.deletingPathExtension().lastPathComponent + "_ocr.txt")
    try output.write(to: outFile, atomically: true, encoding: .utf8)
    print("WROTE", outFile.path, "pages", pdf.pageCount)
}
