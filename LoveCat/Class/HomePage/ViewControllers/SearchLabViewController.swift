//
//  SearchLabViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import UIKit
import ReactorKit

class SearchLabViewController: BaseViewController,View {

    typealias Reactor = SearchLabReactor
    
    lazy var layoutView : QMUIFloatLayoutView = {
        let layoutView = QMUIFloatLayoutView.init()
        layoutView.padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layoutView.itemMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layoutView.minimumItemSize = CGSize(width: 69, height: 29);// 以2个字的按钮作为最小宽度
        layoutView.maximumItemSize = CGSize(width: SCREEN_WIDTH - 40, height: 39)
        return layoutView
    }()
    
    var buttonClickBlock: ((String?) -> Void)?
    
    override init(navi: NavigatorServiceType) {
        super.init(navi: navi)
        defer {
            self.reactor = SearchLabReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(layoutView)
        layoutView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }

}
extension SearchLabViewController {
    func bind(reactor: Reactor) {
        
        rx.viewDidLoad.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.reactor?.action.onNext(.loadLabels)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.labsData
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self] labels in
            guard let `self` = self else { return }
            self.layoutView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            for i in labels {
                let btn = UIButton.init(type: .custom)
                btn.setTitle(i.keyword, for: .normal)
                btn.setTitleColor(UIColor.color(.content), for: .normal)
                btn.titleLabel?.font = UIFont.et.fontSize()
                btn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
                btn.layer.borderWidth = 1
                btn.layer.borderColor = UIColor.color(.tableBack)?.cgColor
                btn.addTarget(self, action: #selector(self.buttonClick(btn: )), for: .touchUpInside)
                self.layoutView.addSubview(btn)
                btn.layer.cornerRadius = 15
                btn.layer.masksToBounds = true
            }
            
        }).disposed(by: disposeBag)
    }
    
    @objc func buttonClick(btn: UIButton) {
        self.buttonClickBlock?(btn.titleLabel?.text)
    }
}
