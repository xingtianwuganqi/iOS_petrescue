//
//  AddressSelectController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/24.
//

import UIKit
import HandyJSON

class AddressSelectController: UIViewController {
    
    lazy var backView : UIView = {
        let backview = UIView()
        backview.backgroundColor = .white
        return backview
    }()
    
    lazy var titleLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.title)
        label.font = UIFont.et.fontSize(.medium, .title)
        label.text = "请选择位置"
        return label
    }()
    
    lazy var backScroll : UIScrollView = {
        let backview = UIScrollView()
        backview.isPagingEnabled = true
        backview.showsVerticalScrollIndicator = false
        backview.showsHorizontalScrollIndicator = false
        return backview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func readLocationData(completion: @escaping ((CountryModel?) -> Void)) {
        let path = Bundle.main.path(forResource: "location", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let jsonDic = jsonData as! Dictionary<String,Any>
            let model = JSONDeserializer<CountryModel>.deserializeFrom(dict: jsonDic)
            completion(model)
        } catch let error as Error? {
            print("读取本地数据出现错误!",error.debugDescription)
        }
    }
}
