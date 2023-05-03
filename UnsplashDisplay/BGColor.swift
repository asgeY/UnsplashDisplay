//
//  Support.swift
//  UnsplashDisplay
//
//  Created by AsgeY on 5/2/23.
//

import SwiftUI
import UIKit
import CoreImage

class ColorExtractor {
    var dominantColor: UIColor?

    func extractColors(from image: UIImage, completion: @escaping ([UIColor]) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion([])
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let accuracy = [kCIImageAccurateMetadata: true]
            let colorDetector = CIDetector(ofType: CIDetectorTypeColor, context: nil, options: accuracy)!
            let features = colorDetector.features(in: ciImage)
            let colors = features.compactMap { feature -> UIColor? in
                guard let color = feature.color else { return nil }
                return UIColor(ciColor: color)
            }
            self.dominantColor = colors.first
            DispatchQueue.main.async {
                completion(colors)
            }
        }
    }
}

extension UIImage {
    func dominantColor() -> UIColor {
        let resizedImage = resized(to: CGSize(width: 50, height: 50))
        let colorExtractor = UIColor.colorExtractor()
        colorExtractor.extractColors(from: resizedImage) { colors in
            return
        }
        guard let dominantColor = colorExtractor.dominantColor else {
            return .white
        }
        return dominantColor
    }

    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension UIColor {
    static func colorExtractor() -> ColorExtractor {
        return ColorExtractor()
    }
}

