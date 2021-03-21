//
//  UserInfoView.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/14.
//

import UIKit

class UserInfoView: UIView {

    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    var cellModel: UserInfoModel? {
        didSet {
            self.headImg.et.sd_setImage(cellModel?.avator)
            if UserManager.shared.isLogin {
                if let nickname = cellModel?.username,nickname.count > 0 {
                    self.nickName.text = nickname
                }else{
                    self.nickName.text = "请设置昵称"

                }
            }else{
                self.nickName.text = "注册/登录"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setColor()
    }
    
    func setColor() {
        self.backgroundColor = .clear
        
        self.nickName.textColor = .white
        self.nickName.font = UIFont.et.fontSize(.medium,.title)
        
        self.headImg.layer.masksToBounds = true
        self.headImg.layer.cornerRadius = 25
        self.headImg.contentMode = .scaleAspectFill
    }

}
