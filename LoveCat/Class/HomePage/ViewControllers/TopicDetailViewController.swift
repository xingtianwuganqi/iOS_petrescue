//
//  TopicDetailViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/28.
//

import UIKit
import RxDataSources
import ReactorKit
import RxSwift
import RxCocoa
import MBProgressHUD
import ShowBigImg
class TopicDetailViewController: BaseViewController,View, UIScrollViewDelegate {
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.white
        tableview.register(TopicDetailInfoCell.self, forCellReuseIdentifier: "TopicDetailInfoCell")
        tableview.register(TopicDetailContentCell.self, forCellReuseIdentifier: "TopicDetailContentCell")
        tableview.register(TopicDetailImgCell.self, forCellReuseIdentifier: "TopicDetailImgCell")
        return tableview
    }()
    
    lazy var bottomBack : TopicDetailBottomView = {
        let backview = TopicDetailBottomView()
        backview.backgroundColor = .white
        return backview
    }()
    
    lazy var shareBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon_topic_share"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    typealias Reactor = TopicDetailReactor
    
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<TopicDetailSection>
    
    static func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<TopicDetailSection> {
        return RxTableViewSectionedReloadDataSource<TopicDetailSection>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .userInfoItem(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopicDetailInfoCell", for: indexPath) as! TopicDetailInfoCell
                cell.reactor = reactor
                return cell
            case .topicInfo(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopicDetailContentCell", for: indexPath) as! TopicDetailContentCell
                cell.reactor = reactor
                return cell
            case .topicImg(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopicDetailImgCell", for: indexPath) as! TopicDetailImgCell
                cell.reactor = reactor
                cell.reloadTable = { img in
                    tableView.et.reloadDataWith(imageUrl: img)
                }
                return cell
            }
        }
        
    }
    
    var changedBlock:((HomePageModel?) -> Void)?
    
    init(navi: NavigatorServiceType,topic_id: Int, model: HomePageModel? = nil,changeBlock: ((HomePageModel?) -> Void)?) {
        dataSource = Self.dataSourceFactory()
        super.init(navi: navi)
        self.changedBlock = changeBlock
        defer {
            self.reactor = TopicDetailReactor.init(topicId: topic_id, model: model)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "详情"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: shareBtn)
        self.buttonClick()

    }

    override func setupConstraints() {
        self.view.addSubview(self.tableview)
        self.view.addSubview(self.bottomBack)
        
        self.tableview.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-90)
        }
        self.bottomBack.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-90)
            make.bottom.equalToSuperview()
        }
        

    }
    
    override func scrollViewInstance() -> UIScrollView? {
        return self.tableview
    }
    
    func buttonClick() {
        bottomBack.bottomView.likeBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                if let model = self.reactor?.currentState.model {
                    self.reactor?.action.onNext(.clickLikeAction(model))
                }
            }
        }).disposed(by: disposeBag)
        
        bottomBack.bottomView.collectionBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                if let model = self.reactor?.currentState.model {
                    self.reactor?.action.onNext(.clickCollection(model))
                }
            }
        }).disposed(by: disposeBag)
        
        bottomBack.contactBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                guard let is_complete = self.reactor?.currentState.model?.is_complete,is_complete == 0 else {
                    MBProgressHUD.xy_show("已完成领养")
                    return
                }
                
                if let geted = self.reactor?.currentState.model?.getedcontact,geted == 1 {
                    if let contact = self.reactor?.currentState.model?.contact_info,contact.count > 0 {
                        let board = UIPasteboard.general
                        board.string = contact
                        MBProgressHUD.xy_show("已复制")
                    }
                    return
                }
                
                guard let topicId = self.reactor?.currentState.model?.topic_id else {
                    return
                }
                self.reactor?.action.onNext(.getContact(topicId))
            }
        }).disposed(by: disposeBag)
        
        shareBtn.rx.tap.subscribe(onNext: { [weak self]  _ in
            guard let `self` = self else { return }
            self.shareBtnClick()
        }).disposed(by: disposeBag)
    }
    
    func shareBtnClick() {
        guard let model = reactor?.currentState.model else {
            return
        }
        let shareUrl = URL(string: "\(baseUrlConfig.rawValue)"+"/shareAnimal/\(model.topic_id ?? 1)")!
        let shareText = model.content ?? ""
        guard let imageUrl = model.imgs?.first else {
            return
        }
        let image = try? Data.init(contentsOf: URL(string: IMGURL + imageUrl)!)
        if let img = image {
            let activity = UIActivityViewController.init(activityItems: [shareUrl, img, shareText], applicationActivities: nil)
            
            activity.completionWithItemsHandler = { (activityType, completion, items, error) in
                printLog(activityType)
                printLog(completion)
                printLog(items)
                printLog(error)
            }
            
            if activity.responds(to: #selector(getter: popoverPresentationController)) {
                activity.popoverPresentationController?.sourceView = self.view
            }
            DispatchQueue.main.async {
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activity.popoverPresentationController?.sourceRect = self.shareBtn.frame
                    activity.popoverPresentationController?.sourceView = self.shareBtn
                }
                    
                self.present(activity, animated: true, completion: nil)
            }

        }
    }
}

extension TopicDetailViewController: UITableViewDelegate {
    func bind(reactor: Reactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            guard let `self` = self else { return }
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isGetContactLoading
        }.subscribe(onNext: { isLoading in
            if isLoading {
                MBProgressHUD.xy_show(activity: "正在获取...")
            }else{
                MBProgressHUD.xy_hide()
            }
        }).disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.getTopicDetail(reactor.currentState.topic_id ?? 0)
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        reactor.state.map{
            $0.model?.views_num
        }.map({ (num) -> String in
            return (num?.wFormatted ?? "0")
        }).bind(to: self.bottomBack.bottomView.viewBtn.rx.title())
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.likes_num
        }.subscribe(onNext: { [weak self] number in
            guard let `self` = self else { return }
            if let num = number,num > 0 {
                self.bottomBack.bottomView.likeBtn.setTitle("\(num.wFormatted)", for: .normal)
            }else{
                self.bottomBack.bottomView.likeBtn.setTitle("点赞", for: .normal)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.collection_num
        }.subscribe(onNext: { [weak self] number in
            guard let `self` = self else { return }
            if let num = number,num > 0 {
                self.bottomBack.bottomView.collectionBtn.setTitle("\(num.wFormatted)", for: .normal)
            }else{
                self.bottomBack.bottomView.collectionBtn.setTitle("收藏", for: .normal)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.errorMsg
        }.filter {
            $0 != nil
        }.subscribe(onNext: { message in
            guard let msg = message else {
                return
            }
            MBProgressHUD.xy_show(msg)
        }).disposed(by: disposeBag)
        
        reactor.state.map { (state) -> Bool in
            state.model?.liked == 1
        }.bind(to: self.bottomBack.bottomView.likeBtn.rx.isSelected)
        .disposed(by: disposeBag)
        
        reactor.state.map { (state) -> Bool in
            state.model?.collectioned == 1
        }.bind(to: self.bottomBack.bottomView.collectionBtn.rx.isSelected)
        .disposed(by: disposeBag)
        
        rx.viewWillDisappear.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.changedBlock?(self.reactor?.currentState.model)
        }).disposed(by: disposeBag)
        
        tableview.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let `self` = self else { return }
            guard let item = self.reactor?.currentState.section.first?.items[index.row] else {
                return
            }
            switch item {
            case .topicImg(let reactor):
                guard let images = self.reactor?.currentState.model?.imgs?.compactMap({ (url) -> String? in
                    return IMGURL + url
                }) else {
                    return
                }
                let newImg = IMGURL + reactor.currentState.img
                let viewController = ShowBigImgController.init(urls: images, url: newImg)
                viewController.modalPresentationStyle = .overFullScreen
                self.present(viewController, animated: false, completion: nil)
            default:
                break
            }
            
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model
        }.subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            if model?.is_complete == 1 {
                self.bottomBack.contactBtn.setTitle("已完成领养", for: .normal)
            }else if model?.getedcontact == 1,model?.is_complete == 0, let contact = model?.contact_info {
                self.bottomBack.contactBtn.setTitle(contact, for: .normal)
            }else {
                self.bottomBack.contactBtn.setTitle("点击获取联系方式", for: .normal)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.loadEnd
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self] loadEnd in
            guard let `self` = self else { return }
            guard loadEnd else {
                return
            }
            guard UserManager.shared.isLogin else {
                return
            }
            self.reactor?.action.onNext(.addViewHistory)
        }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.reactor?.currentState.section.first?.items[indexPath.row]
        switch item {
        case .topicImg(let imgReactor):
            let img = imgReactor.currentState.img
            return WebImageSizeCache.shard.imageHeightBy(url: img, layoutWidth: SCREEN_WIDTH - 30,estimateHeight: 120) + 10
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
