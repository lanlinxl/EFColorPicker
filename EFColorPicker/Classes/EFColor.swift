//
//  EFColor.swift
//  EFColorPicker
//
//  Created by lzwk_lanlin on 2021/11/9.
//

import Foundation
public extension UIColor {

    /// SwifterSwift: Create Color from RGB values with optional transparency.
    ///
    /// - Parameters:
    ///   - red: red component.
    ///   - green: green component.
    ///   - blue: blue component.
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(reds: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard reds >= 0 && reds <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(reds) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }


    /// SwifterSwift: Create Color from hexadecimal string with optional transparency (if applicable).
    ///
    /// - Parameters:
    ///   - hexString: hexadecimal string (examples: EDE7F6, 0xEDE7F6, #EDE7F6, #0ff, 0xF0F, ..).
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(hexStrings: String, transparency: CGFloat = 1) {
        var string = ""
        if hexStrings.lowercased().hasPrefix("0x") {
            string =  hexStrings.replacingOccurrences(of: "0x", with: "")
        } else if hexStrings.hasPrefix("#") {
            string = hexStrings.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexStrings
        }

        if string.count == 3 { // convert hex to 6 digit format if in short format
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }

        guard let hexValue = Int(string, radix: 16) else { return nil }
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let reds = (hexValue >> 16) & 0xff
        let green = (hexValue >> 8) & 0xff
        let blue = hexValue & 0xff
        self.init(reds: reds, green: green, blue: blue, transparency: trans)
    }
}
