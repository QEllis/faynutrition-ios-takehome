//
//  AttributedStringHelpers.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import Foundation
import UIKit

class AttributedStringUtils {

    // Helper for adding icon to left of text in UILabel
    static func createAttributedString(with image: UIImage, and text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image

        let imageSize = CGSize(width: 14, height: 14)
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2.5), size: imageSize)

        let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))

        let textAfterImage = NSAttributedString(string: " \(text)")
        attributedString.append(textAfterImage)

        return NSAttributedString(attributedString: attributedString)
    }
}
