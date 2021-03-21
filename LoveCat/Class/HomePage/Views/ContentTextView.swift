//
//  ContentTextView.swift
//  LoveCat
//
//  Created by jingjun on 2020/11/4.
//

import UIKit

class ContentTextView: UITextView {
    
    lazy var placeholder: UILabel = {
        let placeLab = UILabel.init()
        return placeLab
    }()

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
