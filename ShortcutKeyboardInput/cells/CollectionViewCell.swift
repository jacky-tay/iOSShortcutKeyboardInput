//
//  CollectionViewCell.swift
//  ShortcutKeyboardInput
//
//  Created by Jacky Tay on 15/03/19.
//  Copyright © 2019 Jacky Tay. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    static let identifier = "CollectionViewCell"
    @IBOutlet weak var label: UILabel?
    
    func set(value: String, highlight: String) {
        backgroundColor = UIColor.clear
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 4
        
        let indices = value.indicesOf(highlight)
        let attributed = NSMutableAttributedString(string: value)
        indices.forEach {
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: tintColor, range: NSMakeRange($0, highlight.count))
        }
        label?.attributedText = attributed
    }
}
