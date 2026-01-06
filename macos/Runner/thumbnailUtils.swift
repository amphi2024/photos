import Foundation
import AVFoundation
import Cocoa

func generateThumbnail(filePath: String, thumbnailPath: String) {
    DispatchQueue.global(qos: .userInitiated).async {
            if filePath.hasSuffix(".mp4") {
                let asset = AVAsset(url: URL(fileURLWithPath: filePath))
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
                    let nsImage = NSImage(cgImage: cgImage, size: NSZeroSize)
                    if let tiffData = nsImage.tiffRepresentation,
                       let bitmap = NSBitmapImageRep(data: tiffData),
                       let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) {
                        try data.write(to: URL(fileURLWithPath: thumbnailPath))
                    }
                } catch {
                    print("Error generating video thumbnail: \(error)")
                }
            } else {
                if let image = NSImage(contentsOf: URL(fileURLWithPath: filePath)) {
                            let maxDimension: CGFloat = 200
                            let aspectWidth = maxDimension / image.size.width
                            let aspectHeight = maxDimension / image.size.height
                            let aspectRatio = min(aspectWidth, aspectHeight)
                            
                            let newSize = NSSize(width: image.size.width * aspectRatio,
                                                 height: image.size.height * aspectRatio)
                            
                            let newImage = NSImage(size: newSize)
                            newImage.lockFocus()
                            image.draw(in: NSRect(origin: .zero, size: newSize),
                                       from: NSRect(origin: .zero, size: image.size),
                                       operation: .copy,
                                       fraction: 1.0)
                            newImage.unlockFocus()
                            
                            if let tiffData = newImage.tiffRepresentation,
                               let bitmap = NSBitmapImageRep(data: tiffData),
                               let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) {
                                do {
                                    try data.write(to: URL(fileURLWithPath: thumbnailPath))
                                } catch {
                                    print("Error saving thumbnail image: \(error)")
                                }
                            }
                        }
            }
        }
}
