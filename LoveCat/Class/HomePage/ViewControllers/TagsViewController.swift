//
//  TagsViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/13.
//

import UIKit
import ReactorKit
import RxDataSources
class TagsViewController: BaseViewController,View {
    
//    lazy var tableview : UITableView = {
//        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
//        tableview.estimatedRowHeight = 0
//        tableview.estimatedSectionFooterHeight = 0
//        tableview.estimatedSectionHeaderHeight = 0
//        tableview.showsVerticalScrollIndicator = false
//        tableview.showsHorizontalScrollIndicator = false
//        tableview.separatorStyle = .none
//        tableview.backgroundColor = UIColor.white
//        tableview.register(TagInfoCell.self, forCellReuseIdentifier: "TagInfoCell")
//        return tableview
//    }()
    
//    lazy var layoutView : QMUIFloatLayoutView = {
//        let layoutView = QMUIFloatLayoutView.init()
//        layoutView.padding = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
//        layoutView.itemMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        layoutView.minimumItemSize = CGSize(width: 60, height: 24);// 以2个字的按钮作为最小宽度
//        layoutView.maximumItemSize = CGSize(width: SCREEN_WIDTH - 40, height: 24)
//        return layoutView
//    }()
    
    lazy var activity: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .gray)
        return indicatorView
    }()
    
    lazy var layoutView: CollectionIconView = {
        let layoutView = CollectionIconView.init(spacing: 15, margin: 0, rowHeight: 24)
        return layoutView
    }()
    
    typealias Reactor = TagsViewReactor
    
    fileprivate var selectedBlock: (([TagInfoModel]) -> Void)?
    init(navi: NavigatorServiceType,normal: [TagInfoModel],selectedBlock: (([TagInfoModel]) -> Void)?) {
        super.init(navi: navi)
        self.selectedBlock = selectedBlock
        defer {
            self.reactor = TagsViewReactor.init(normal: normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择标签"
        
        layoutView.selectIndexBlock = { index in
            self.reactor?.action.onNext(.selectItem(index))
        }
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.layoutView)
        layoutView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        self.view.addSubview(self.activity)
        activity.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)

        }
        activity.startAnimating()
    }

}
extension TagsViewController: UITableViewDelegate {
    func bind(reactor: TagsViewReactor) {
        
        reactor.state.map {
            $0.allItems
        }.subscribe(onNext: { [weak self] models in
            guard let `self` = self else { return }
            self.layoutView.models = models
        }).disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.loadTagList
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.selectedItems
        }.subscribe(onNext: { [weak self] items in
            guard let `self` = self else { return }
            self.selectedBlock?(items)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.netCompletion
        }.bind(to: self.activity.rx.isHidden)
        .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
