//
//  AutoHeight.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/7/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

public class AutoHeight {
    
    public static func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x:0, y:0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
}



