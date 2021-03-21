//
//  CityViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/24.
//

import UIKit
import RxSwift
import RxDataSources
import ReactorKit

class CityViewController: BaseViewController ,View{
    let viewHeight = SCREEN_HEIGHT
    let backHeight = SCREEN_HEIGHT * 0.7
    let scrollHeight = SCREEN_HEIGHT * 0.7 - 70
    
    typealias Reactor = CityViewReactor
    
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
    
    lazy var proView: ProvinceView = {
        let proView = UINib(nibName: "ProvinceView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ProvinceView
        proView.provinceBtn.isSelected = true
        proView.cityBtn.isHidden = true
        proView.areaBtn.isHidden = true
        return proView
    }()
    
    lazy var backScroll : UIScrollView = {
        let backview = UIScrollView()
        backview.isScrollEnabled = false
        backview.showsVerticalScrollIndicator = false
        backview.showsHorizontalScrollIndicator = false
        return backview
    }()
    
    lazy var provinceTab : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.white
        tableview.register(CitySelectCell.self, forCellReuseIdentifier: "CitySelectCell")
        return tableview
    }()
    
    
    lazy var cityTab : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.white
        tableview.register(CitySelectCell.self, forCellReuseIdentifier: "CitySelectCell")
        return tableview
    }()

    lazy var areaTab : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.white
        tableview.register(CitySelectCell.self, forCellReuseIdentifier: "CitySelectCell")

        return tableview
    }()
    
    fileprivate var dataSources : RxTableViewSectionedReloadDataSource<CitySection>
    fileprivate var citySources : RxTableViewSectionedReloadDataSource<CitySection>
    fileprivate var areaSources : RxTableViewSectionedReloadDataSource<CitySection>

    private static func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<CitySection> {
        return RxTableViewSectionedReloadDataSource<CitySection>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .provinceItem(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CitySelectCell", for: indexPath) as! CitySelectCell
                cell.proReactor = reactor
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    private static func cityDataSourceFactory() -> RxTableViewSectionedReloadDataSource<CitySection> {
        return RxTableViewSectionedReloadDataSource<CitySection>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .cityItem(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CitySelectCell", for: indexPath) as! CitySelectCell
                cell.cityReactor = reactor
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    private static func areaDataSourceFactory() -> RxTableViewSectionedReloadDataSource<CitySection> {
        return RxTableViewSectionedReloadDataSource<CitySection>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .areaItem(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "CitySelectCell", for: indexPath) as! CitySelectCell
                cell.areaReactor = reactor
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    private var locationSelectedBlock: ((String) -> Void)?
    
    init(navi: NavigatorServiceType,selectedBlock: ((String) -> Void)?) {
        dataSources = Self.dataSourceFactory()
        citySources = Self.cityDataSourceFactory()
        areaSources = Self.areaDataSourceFactory()
        super.init(navi: navi)
        self.locationSelectedBlock = selectedBlock
        defer {
            self.reactor = CityViewReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(self.backView)
        backView.frame = CGRect(x: 0, y: viewHeight, width: SCREEN_WIDTH, height: backHeight)
        self.backView.addSubview(self.backScroll)
        self.backView.addSubview(self.proView)
        self.backScroll.addSubview(self.provinceTab)
        self.backScroll.addSubview(self.cityTab)
        self.backScroll.addSubview(self.areaTab)
        
        self.proView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 50)
        self.backScroll.frame = CGRect(x: 0, y: 50, width: SCREEN_WIDTH, height: scrollHeight)
        self.backScroll.contentSize = CGSize(width: SCREEN_WIDTH * 3, height: scrollHeight)
        [self.provinceTab,self.cityTab,self.areaTab].enumerated().forEach { (index,table) in
            table.frame = CGRect(x: SCREEN_WIDTH * CGFloat(index), y: 0, width: SCREEN_WIDTH, height: scrollHeight)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.backView.frame = CGRect(x: 0, y: self.viewHeight - self.backHeight, width: SCREEN_WIDTH, height: self.backHeight)
        }
        
    
        self.proView.provinceBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if self.reactor?.currentState.provinceItem != nil {
                self.backScroll.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
        }).disposed(by: disposeBag)
        
        self.proView.cityBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if self.reactor?.currentState.cityItem != nil {
                self.backScroll.setContentOffset(CGPoint(x: SCREEN_WIDTH, y: 0), animated: true)
            }
        }).disposed(by: disposeBag)
        
        self.proView.cityBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if self.reactor?.currentState.areaItem != nil {
                self.backScroll.setContentOffset(CGPoint(x: SCREEN_WIDTH * 2, y: 0), animated: true)
            }
        }).disposed(by: disposeBag)
        
        self.proView.closeBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.dismissAnimation()
        }).disposed(by: disposeBag)
    }
    deinit {
        print("CITYDEINIT")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first(where: { (touch) -> Bool in
            touch.view == self.view
        }) != nil {
            self.dismissAnimation()
        }
    }
    func dismissAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.backView.frame = CGRect(x: 0, y: self.viewHeight, width: SCREEN_WIDTH, height: self.backHeight)
        } completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
}
extension CityViewController {
    func bind(reactor: Reactor) {
        
        provinceTab.rx.setDelegate(self)
            .disposed(by: disposeBag)
        cityTab.rx.setDelegate(self).disposed(by: disposeBag)
        areaTab.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.section
        }.bind(to: provinceTab.rx.items(dataSource:dataSources))
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.citySection
        }.bind(to: cityTab.rx.items(dataSource: citySources))
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.areaSection
        }.bind(to: areaTab.rx.items(dataSource: areaSources))
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.citySection
        }.subscribe(onNext: { (citys) in
            
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.cityItem
        }.subscribe(onNext: { [weak self] (item) in
            guard let `self` = self else { return }
            if item == nil {
                self.proView.cityBtn.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.areaItem
        }.subscribe(onNext: { [weak self] (item) in
            guard let `self` = self else { return }
            if let area = item {
                // 选择完之后就退出
                guard let province = reactor.currentState.provinceItem?.value,let city = reactor.currentState.cityItem?.value else {
                    return
                }
                let location = province + "." + city + "." + (area.value ?? "")
                self.locationSelectedBlock?(location)
                self.dismiss(animated: false, completion: nil)
            }else{
                self.proView.areaBtn.isHidden = true
            }
        }).disposed(by: disposeBag)
        
    }
}

extension CityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.provinceTab {
            guard let item = self.reactor?.currentState.addressModel[indexPath.row] else {
                return
            }
            self.reactor?.action.onNext(.changeProvinceInfo(item))
            self.backScroll.setContentOffset(CGPoint(x: SCREEN_WIDTH, y: 0), animated: true)
            
            self.proView.provinceBtn.setTitle(item.value, for: .normal)
            self.proView.provinceBtn.isSelected = false
            
            self.proView.cityBtn.isSelected = true
            self.proView.cityBtn.isHidden = false
            self.proView.cityBtn.setTitle("", for: .normal)
            
        }else if tableView == self.cityTab {
            guard let item = self.reactor?.currentState.currentCity[indexPath.row] else {
                return
            }
            self.reactor?.action.onNext(.changeCityInfo(item))
            self.backScroll.setContentOffset(CGPoint(x: SCREEN_WIDTH * 2, y: 0), animated: true)
            
            self.proView.cityBtn.setTitle(item.value, for: .normal)
            self.proView.cityBtn.isSelected = false
            
            self.proView.areaBtn.isSelected = true
            self.proView.areaBtn.isHidden = false
            self.proView.areaBtn.setTitle("", for: .normal)
        }else{
            guard let item = self.reactor?.currentState.currentArea[indexPath.row] else {
                return
            }
            self.reactor?.action.onNext(.changeAreaInfo(item))
            
            self.proView.areaBtn.setTitle(item.value, for: .normal)
            self.proView.areaBtn.isSelected = false
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
