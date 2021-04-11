//
//  CommentListController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/28.
//

import UIKit
import ReactorKit
import RxDataSources
import SnapKit
import MBProgressHUD

enum CommentType: Int {
    case topic_comment = 1
    case show_comment = 2
}

class CommentListController: BaseViewController,View {
    
    typealias Reactor = CommentListReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.white
        tableview.keyboardDismissMode = .onDrag
        tableview.register(ShowListCommentView.self, forCellReuseIdentifier: "ShowListCommentView")
        tableview.register(ShowListReplyCell.self, forCellReuseIdentifier: "ShowListReplyCell")
        tableview.register(ShowListReplyOpenCell.self, forCellReuseIdentifier: "ShowListReplyOpenCell")
        return tableview
    }()
    
    lazy var backBtn: UIButton = {
        let backNavBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40.0))
        backNavBtn.contentHorizontalAlignment = .left
        backNavBtn.setImage(UIImage(named: "icon_a_back"), for: .normal)
        backNavBtn.setImage(UIImage(named: "icon_a_back"), for: .highlighted)
        let backItem = UIBarButtonItem(customView: backNavBtn)
        self.navigationItem.leftBarButtonItem = backItem
        return backNavBtn
    }()
    
    lazy var textInputView : CommentInputView = {
        let backview = CommentInputView()
        backview.textField.delegate = self
        return backview
    }()
    fileprivate var heightConstraint: Constraint?
    var dataSource: RxTableViewSectionedReloadDataSource<CommentListSection>!
    fileprivate var commentResult:(() -> Void)?
    init(navi: NavigatorServiceType,comment_type: CommentType,topicId: Int,topicUInfo: UserInfoModel?,commentResult:(() -> Void)?) {
        super.init(navi: navi)
        self.dataSource = self.dataSourceFactory()
        self.commentResult = commentResult
        defer {
            self.reactor = CommentListReactor.init(commentType: comment_type, topicId: topicId, topicUserInfo: topicUInfo)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.navigationController?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notify:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notify:)), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<CommentListSection> {
        return RxTableViewSectionedReloadDataSource<CommentListSection>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .commentItem(let commReac):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowListCommentView", for: indexPath) as! ShowListCommentView
                cell.reactor = commReac
                cell.moreBtnClickBlock = { [weak self] model in
                    guard let `self` = self else { return }
                    UserManager.shared.lazyAuthToDoThings {
                        let rect = cell.contentView.convert(cell.moreBtn.frame, to: self.view)
                        self.moreBtnCommentClick(model: model, rect: rect)
                    }
                }
                return cell
            case .replyItem(let replyReac):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowListReplyCell", for: indexPath) as! ShowListReplyCell
                cell.reactor = replyReac
                cell.moreBtnClickBlock = { [weak self] model in
                    guard let `self` = self else { return }
                    UserManager.shared.lazyAuthToDoThings {
                        let rect = cell.contentView.convert(cell.moreBtn.frame, to: self.view)
                        self.moreBtnReplytClick(model: model, rect: rect)
                    }
                }
                return cell
            case .moreItem:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowListReplyOpenCell", for: indexPath)
                return cell
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(tableview)
        self.view.addSubview(textInputView)
        self.tableview.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.textInputView.snp.top)
        }
        self.textInputView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            self.heightConstraint = make.height.equalTo(SystemTabBarHeight).constraint
        }
        self.titleEmpty = "暂无评论"
        self.descEmpty = "快去添加第一条评论吧!"
    }
    
    override func scrollViewInstance() -> UIScrollView? {
        return self.tableview
    }
    
    override func hasHeadRefresh() -> Bool {
        return false
    }
    
    override func hasFooterRefresh() -> Bool {
        return true
    }
    
    override func retryNewData() {
        super.retryNewData()
        self.reactor?.action.onNext(.commentList(page: .refresh))
    }
    
    override func refreshNetWorking(page: Paging) {
        self.reactor?.action.onNext(.commentList(page: page))
    }
    
    @objc private func keyboardWillShow(notify: Notification) {
        
        guard self.textInputView.textField.isFirstResponder else{
            return
        }
        
        guard let info = notify.userInfo else { return }
        let rect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let keyboardHeight = rect.size.height
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
 
        let keyHeight :CGFloat = keyboardHeight
        UIView.animate(withDuration: duration) {
            self.heightConstraint?.update(offset: (keyHeight + SystemTabBarContentHeight))
            self.view.layoutIfNeeded()
        } completion: { (completion) in
            
        }

    }
    
    @objc private func keyBoardWillHide(notify: Notification) {
        guard self.view.origin.y != 0 else{
            return
        }
        guard let info = notify.userInfo else { return }
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.0
    
        UIView.animate(withDuration: duration) {
            self.heightConstraint?.update(offset: SystemTabBarHeight)
            self.view.layoutIfNeeded()
        }
    }

}
extension CommentListController: UITableViewDelegate,UITextFieldDelegate {
    func bind(reactor: CommentListReactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { loading in
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.commentList(page: .refresh)
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        tableview.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                guard let item = self.reactor?.currentState.section[indexPath.section].items[indexPath.row] else {
                    return
                }
                switch item {
                case .commentItem(let comReac):
                    reactor.action.onNext(.changeComment(comment_id: comReac.currentState.model?.comment_id, reply_id: comReac.currentState.model?.comment_id, to_uid: comReac.currentState.model?.userInfo?.id))
                    self.textInputView.textField.becomeFirstResponder()
                    let nickName = comReac.currentState.model?.userInfo?.username ?? ""
                    self.textInputView.textField.placeholder = "回复\(nickName)"
                case .replyItem(let replyReac):
                    reactor.action.onNext(.changeComment(comment_id: replyReac.currentState.model?.comment_id, reply_id: replyReac.currentState.model?.id, to_uid: replyReac.currentState.model?.fromInfo?.id))
                    self.textInputView.textField.becomeFirstResponder()
                    let nickName = replyReac.currentState.model?.fromInfo?.username ?? ""
                    self.textInputView.textField.placeholder = "回复\(nickName)"
                case .moreItem:
                    // 请求回复分页
                    guard let item = self.reactor?.currentState.section[indexPath.section].items[0] else {
                        return
                    }
                    if case let .commentItem(comrect) = item,let model = comrect.currentState.model {
                        reactor.action.onNext(.loadMoreReply(model))
                    }
                    
                }
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.endRefreshing
        }.subscribe(onNext: { [weak self] state in
            guard let `self` = self else { return }
            guard let state = state else {
                return
            }
            self.tableview.mj_header?.endRefreshing()
            self.tableview.mj_footer?.et.setRefState(state: state)
        }).disposed(by: disposeBag)
        
        textInputView.sendBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.publishComment()
            self.textInputView.textField.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.errMsg
        }.subscribe(onNext: { msg in
            guard let message = msg else {
                return
            }
            MBProgressHUD.xy_hide()
            MBProgressHUD.xy_show(message)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.refreshing
        }.subscribe(onNext: { refresh in
            if refresh {
                MBProgressHUD.xy_show(activity: nil)
            }else{
                MBProgressHUD.xy_hide()
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.commentResult
        }.filter {
            $0 != nil
        }.subscribe(onNext: { result in
            if let comResult = result,comResult == true {
                self.commentResult?()
            }
        }).disposed(by: disposeBag)
    
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView.init()
        footer.backgroundColor = UIColor.color(.tableBack)
        return footer
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = self.textInputView.textField.text?.et.removeHeadAndTailSpace,text.count > 0 {
            self.publishComment()
        }
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.reactor?.action.onNext(.changeComment(comment_id: nil, reply_id: nil, to_uid: nil))
        self.textInputView.textField.placeholder = "请输入评论"
    }
    
    func publishComment() {
        UserManager.shared.lazyAuthToDoThings {
            guard let text = self.textInputView.textField.text?.et.removeHeadAndTailSpace,text.count > 0 else {
                return
            }
            if let reply_id = self.reactor?.currentState.reply_id, let comment_id = self.reactor?.currentState.comment_id,let to_uid = self.reactor?.currentState.to_uid {
                self.reactor?.action.onNext(.replyAction(content: text, comment_id: comment_id, reply_id: reply_id, reply_type: reply_id == comment_id ? 1 : 2, to_uid: to_uid))
            }else{
                self.reactor?.action.onNext(.commentAction(content: text))
            }
            self.textInputView.textField.text = nil
        }
    }
    
    func moreBtnCommentClick(model: CommentListModel?,rect: CGRect) {
        guard let id = model?.comment_id else {
            return
        }
        
        self.moreBtnClickNext(id: id, report_type: .show_comment, rect: rect)
    }
    
    func moreBtnReplytClick(model: ReplyListModel?,rect: CGRect) {
        guard let id = model?.reply_id else {
            return
        }
        
        self.moreBtnClickNext(id: id, report_type: .show_reply, rect: rect)
    }
    
    func moreBtnClickNext(id: Int,report_type: Report_type,rect: CGRect) {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction.init(title: "屏蔽/拉黑", style: .default, handler: { [weak self](_) in
            guard let `self` = self else { return }
            if report_type == .rescue_comment {
                UserManager.shared.setUserShieldContent(shieldId: id, shieldType: .show_sh_comment)
                self.reactor?.action.onNext(.shieldAction(id, .rescue_sh_comment))

            }else if report_type == .show_comment {
                UserManager.shared.setUserShieldContent(shieldId: id, shieldType: .show_sh_comment)
                self.reactor?.action.onNext(.shieldAction(id, .show_sh_comment))

            }else if report_type == .rescue_reply {
                UserManager.shared.setUserShieldContent(shieldId: id, shieldType: .show_sh_comment)
                self.reactor?.action.onNext(.shieldAction(id, .rescue_sh_reply))

            }else{
                UserManager.shared.setUserShieldContent(shieldId: id, shieldType: .show_sh_reply)
                self.reactor?.action.onNext(.shieldAction(id, .show_sh_reply))

            }
        }))
        
        alert.addAction(UIAlertAction.init(title: "投诉举报", style: .default, handler: { [weak self](_) in
            guard let `self` = self else { return }
            self.naviService.navigatorSubject.onNext(.violationsPage(report_type: report_type, report_id: id))
        }))
        
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (_) in
            
        }))
        DispatchQueue.main.async {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                alert.popoverPresentationController?.sourceRect = rect
                alert.popoverPresentationController?.sourceView = self.view
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
