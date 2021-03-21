//
//  ProvinceView.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/24.
//

import UIKit

class ProvinceView: UIView {
    @IBOutlet weak var provinceBtn: UIButton!
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var areaBtn: UIButton!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var btmLineLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLineWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setColor()
    }
    
    func setColor() {
        self.provinceBtn.setTitle("请选择", for: .selected)
        self.provinceBtn.setTitleColor(UIColor.color(.system), for: .selected)
        self.provinceBtn.setTitle("", for: .normal)
        self.provinceBtn.setTitleColor(UIColor.color(.content), for: .normal)
        self.provinceBtn.titleLabel?.font = UIFont.et.fontSize(.medium,.title)
        
        self.cityBtn.setTitle("请选择", for: .selected)
        self.cityBtn.setTitleColor(UIColor.color(.system), for: .selected)
        self.cityBtn.setTitle("", for: .normal)
        self.cityBtn.setTitleColor(UIColor.color(.content), for: .normal)
        self.cityBtn.titleLabel?.font = UIFont.et.fontSize(.medium,.title)
        
        self.areaBtn.setTitle("请选择", for: .selected)
        self.areaBtn.setTitleColor(UIColor.color(.system), for: .selected)
        self.areaBtn.setTitle("", for: .normal)
        self.areaBtn.setTitleColor(UIColor.color(.content), for: .normal)
        self.areaBtn.titleLabel?.font = UIFont.et.fontSize(.medium,.title)
        
        self.bottomLine.backgroundColor = UIColor.color(.system)
        self.line.backgroundColor = UIColor.color(.tableBack)
        
        self.bottomLine.isHidden = true
    }

}
