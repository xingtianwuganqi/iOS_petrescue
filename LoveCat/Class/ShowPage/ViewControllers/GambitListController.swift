//
//  GambitListController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import UIKit
import ReactorKit
import RxDataSources
class GambitListController: BaseViewController,View {

    typealias Reactor = GambitListReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(GambitListCell.self, forCellReuseIdentifier: "GambitListCell")
        return tableview
    }()
    
    fileprivate var dataSource : RxTableViewSectionedReloadDataSource<GambitListSection>!
    
    func dataSourceFactory() ->  RxTableViewSectionedReloadDataSource<GambitListSection> {
        return RxTableViewSectionedReloadDataSource<GambitListSection>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .gambitItem(let reac):
                let cell = tableView.dequeueReusableCell(withIdentifier: "GambitListCell", for: indexPath) as! GambitListCell
                cell.model = reac
                if self.selectedGambit != nil {
                    cell.selectIcon.isHidden = false
                    cell.rightIcon.isHidden = true
                }else{
                    cell.selectIcon.isHidden = true
                    cell.rightIcon.isHidden = false
                }
                return cell
            }
        }
    }
    fileprivate var selectedGambit: ((GambitListModel?) -> Void)?
    init(navi: NavigatorServiceType,normal: GambitListModel?,selected:((GambitListModel?) -> Void)?) {
        super.init(navi: navi)
        dataSource = self.dataSourceFactory()
        self.selectedGambit = selected
        defer {
            self.reactor = GambitListReactor.init(normal: normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedGambit != nil {
            self.title = "添加话题"
        }
    }
    override func scrollViewInstance() -> UIScrollView? {
        return self.tableview
    }
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    override func retryNewData() {
        super.retryNewData()
        self.reactor?.action.onNext(.loadData(.refresh))
    }
}
extension GambitListController : UITableViewDelegate{
    func bind(reactor: GambitListReactor) {
        
        rx.viewDidLoad.map {
            Reactor.Action.loadData(.refresh)
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            guard let `self` = self else { return }
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
    
        tableview.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let `self` = self else { return }
            if self.selectedGambit != nil {
                guard let item = self.reactor?.currentState.section.first?.items[index.row] else {
                    return
                }
                switch item {
                case .gambitItem(let model):
                    if model.selected == false {
                        
                        reactor.action.onNext(.selected(model))
                    }else{
                        reactor.action.onNext(.selected(nil))
                    }
                }
            }else{
                guard let item = self.reactor?.currentState.section.first?.items[index.row] else {
                    return
                }
                switch item {
                case .gambitItem(let model):
                    self.naviService.navigatorSubject.onNext(.showInfoPage(type: .showInfoList, gambitId: model.id))
                }
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.selectedModel
        }.subscribe(onNext: { [weak self] model in
            self?.selectedGambit?(model)
        }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
