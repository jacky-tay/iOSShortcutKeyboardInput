//
//  StringExtensions.swift
//  ShortcutKeyboardInput
//
//  Created by Jacky Tay on 15/03/19.
//  Copyright © 2019 Jacky Tay. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func DJBHash() -> Int {
        return unicodeScalars.reduce(5381) { (($0 << 5) &+ $0) &+ Int($1.value) }
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    func calculateTextSize(font: UIFont, width inputWidth: CGFloat? = nil, height inputHeight: CGFloat? = nil) -> CGSize {
        var sizeFound = false
        var width: CGFloat = inputWidth ?? 0.0
        var height: CGFloat = inputHeight ?? 0.0
        
        while !sizeFound {
            let size = CGSize(width: width, height: height)
            let rect = self.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
            sizeFound = abs((rect.size.height - height) / rect.size.height) < 0.05 // allow a 5% tolerance
            width = rect.size.width
            height = rect.size.height
        }
        
        return CGSize(width: ceil(width * 1.05), height: ceil(height))
    }
    
    /// Find the index of substring
    ///
    /// - Parameter subString: The query string
    /// - Returns: All indices of substring within the string
    func indicesOf(_ subString: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = startIndex
        
        while searchStartIndex < endIndex,
            let range = range(of: subString, options: .caseInsensitive, range: searchStartIndex ..< endIndex),
            !range.isEmpty
        {
            let index = distance(from: startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
    
    func findCompleteWord(from: Int, offset: Int) -> Range<String.Index>? {
        var pointer = from + offset
        let set = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        while pointer >= 0 && pointer < count, let c = self[pointer].unicodeScalars.first, !set.contains(c) {
            pointer -= 1
        }
        let offsetBy = from + offset + 1
        guard pointer + 1 < offsetBy else {
            return nil
        }
        return index(startIndex, offsetBy: pointer + 1) ..< index(startIndex, offsetBy: offsetBy)
    }
    
    func getSubstring(from: Range<String.Index>?) -> String? {
        guard let range = from else {
            return nil
        }
        return String(self[range])
    }
}
