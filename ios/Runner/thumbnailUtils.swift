import Foundation
import AVFoundation

func generateThumbnail(filePath: String, thumbnailPath: String) {
    DispatchQueue.global(qos: .userInitiated).async {
            if filePath.hasSuffix(".mp4") {
                let asset = AVAsset(url: URL(fileURLWithPath: filePath))
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
                    let uiImage = UIImage(cgImage: cgImage)
                    if let data = uiImage.jpegData(compressionQuality: 0.8) {
                        try data.write(to: URL(fileURLWithPath: thumbnailPath))
                    }
                } catch {
                    print("Error generating video thumbnail: \(error)")
                }
            } else {
                if let image = UIImage(contentsOfFile: filePath) {
                    let maxDimension: CGFloat = 100
                    let aspectWidth = maxDimension / image.size.width
                    let aspectHeight = maxDimension / image.size.height
                    let aspectRatio = min(aspectWidth, aspectHeight)
                    
                    let newSize = CGSize(width: image.size.width * aspectRatio,
                                         height: image.size.height * aspectRatio)
                    
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                    let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let data = thumbnail?.jpegData(compressionQuality: 0.8) {
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
