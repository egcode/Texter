//
//  SendingStatusCollectionViewCell.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class SendingStatusCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var statusLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusBGWidthConstraint: NSLayoutConstraint!
    
    var text: NSAttributedString? {
        didSet {
            self.label.attributedText = self.text
        }
    }
    var alignment: NSTextAlignment? {
        didSet {
            if self.alignment != nil {
                self.label.textAlignment = self.alignment!
            }
        }
    }

}
