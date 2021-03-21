//
//  GambitView.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/26.
//

import UIKit

class GambitView: UIView {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var descLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColor()
    }
    
    func setColor() {
        descLab.textColor = UIColor.color(.system)
        descLab.font = UIFont.et.font(size: 12)
    }
    
}
