//
//  MonthSelector.swift
//  TreeDiary
//
//  Created by Stephen Williams on 22/08/16.
//  Copyright © 2016 Onato. All rights reserved.
//

import UIKit

class MonthSelector: DesignableXIBView {
    @IBInspectable var title: String = ""
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    var selectedMonths: [Int] {
        get {
            let buttons = stackView.subviews.filter{($0 as? UIButton) != nil}
            return buttons.map {
                if let button = $0 as? UIButton {
                    return button.selected ? 1 : 0
                }
                return 0
            }

        }
    }
    var monthsString: String {
        get {
            let months = selectedMonths
            return (0...11).reduce("") { (existing, new) -> String in
                existing + String(months[new])
            }
        }
        set {
            for view in stackView.subviews {
                if let button = view as? UIButton {
                    button.selected = false
                }
            }
            for month in (0...11) {
                for view in stackView.subviews {
                    if let button = view as? UIButton where button.tag == Int(String(month)) && !newValue.isEmpty {
                        button.selected = newValue.characters[newValue.startIndex.advancedBy(month)] == "1"
                    }
                }
            }
        }
    }
    
    @IBAction func didTapMonth(sender: AnyObject) {
        guard let button = sender as? SelectableButton else { return }
        button.selected = !button.selected
        sendActionsForControlEvents(.ValueChanged)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = title
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        stackViewTrailingConstraint.constant = 20
    }
}
