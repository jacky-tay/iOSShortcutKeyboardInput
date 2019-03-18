//
//  ViewController.swift
//  ShortcutKeyboardInput
//
//  Created by Jacky Tay on 15/03/19.
//  Copyright © 2019 Jacky Tay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var word = ""
    private var wordRange: Range<String.Index>?
    private var result = [String]()
    private var sizeDict = [Int : CGFloat]()
    private var dict = [String]()
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChanged), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let toolbar = UIToolbar(frame: CGRect.zero)
        toolbar.items = [UIBarButtonItem(customView: collectionView),
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         done]
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        textView.delegate = self
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:  UICollectionViewLayout())
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc func keyboardFrameDidChanged() {
        guard let toolbar =  textView.inputAccessoryView as? UIToolbar,
            let item = toolbar.items?.last,
            let uiview = item.value(forKey: "view") as? UIView else {
                return
        }
        let doneWidth = uiview.frame.width
        // magic margin 12px, https://stackoverflow.com/a/5708167, button margin = 8px
        let margin = CGFloat((12 + 8) * 2)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width - doneWidth - margin, height: toolbar.frame.height)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath)
        (cell as? CollectionViewCell)?.set(value: result[indexPath.row], highlight: word)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let range = wordRange else { return }
        let replaceTo = ("\(result[indexPath.row]) ")
        textView.text = textView.text.replacingCharacters(in: range, with: replaceTo)
        textView.selectedRange = NSMakeRange(textView.text.distance(from: textView.text.startIndex, to: range.lowerBound) + replaceTo.count, 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = result[indexPath.row].DJBHash()
        let width = sizeDict[text] ?? (result[indexPath.row].calculateTextSize(font: UIFont.systemFont(ofSize: 17)).width + 16)
        sizeDict[text] = width
        return CGSize(width: width, height: 30)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        let loc = textView.selectedRange.location
        guard let text = textView.text else { return }
        let set = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let range = text.findCompleteWord(from: loc, offset: -1)
        word = text.getSubstring(from: range) ?? ""
        wordRange = range
        result = dict.filter { $0.range(of: word, options: .caseInsensitive)?.lowerBound == $0.startIndex }
        collectionView.reloadData()
        
        if !result.isEmpty {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        }
        if loc > 0,
            let c = text[loc - 1].unicodeScalars.first, set.contains(c),
            let cache = text.getSubstring(from: text.findCompleteWord(from: loc, offset: -2)), !dict.contains(cache) {
            dict.append(cache)
        }
    }
}
