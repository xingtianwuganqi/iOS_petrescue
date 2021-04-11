//
//  NavigatorService.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import RxSwift
import URLNavigator
import ReactorKit

protocol NavigatorServiceType {
    var navigatorSubject: PublishSubject<NavigatorItem> { get }
}

enum NavigatorItem {
    case login
    case register
    case findPswdConfrim
    case changePswd(account: String)
    case releaseTopic(result: ((Bool) -> Void)?)
    case selectCity(selectedBlock:((String) -> Void)?)
    case logout
    case topicDetail(topicId: Int,model: HomePageModel? = nil,changeBlock:((HomePageModel?) -> Void)?)
    case searchPage
    case myCollectionList
    case myPushList
    case webProtocalPage(url: String)
    case userEdit(fromType: Int)
    case settingPage
    case suggestion
    case tagListPage(normalTag: [TagInfoModel],selectedTags:(([TagInfoModel]) -> Void)?)
    case releaseShowInfo(result: ((Bool) -> Void)?)
    case selectGambit(normal: GambitListModel?,selected: ((GambitListModel?) -> Void)?)
    case publishMain(type: PageType)
    case showInfoPage(type: ShowPageType,gambitId: Int?,showId: Int?)
    case settingChangePswd
    case ShowCommentList(commentType: CommentType, topicId: Int,topicUInfo: UserInfoModel?,commentResult:(() -> Void)?)
    case messagePage(popBack: (() -> Void)?)
    case violationsPage(report_type: Report_type,report_id: Int)
    case messageList(msg_type: MsgType,readedBlock: (() -> Void)?)
    case sysMsgPage(readedBlock: (() -> Void)?)
    case createNewGambit
}

final class NavigatorService: NavigatorServiceType {
    let navigatorSubject = PublishSubject<NavigatorItem>()
    fileprivate var disposeBag = DisposeBag()
    fileprivate let navigator: Navigator

    init(navigator: Navigator) {
        self.navigator = navigator
        bind()
    }
    
    fileprivate func bind() {
        self.navigatorSubject.subscribe(onNext: { [weak self](item) in
            guard let `self` = self else { return }
            switch item {
            case .login:
                let login = LoginViewController.init(reactor: LoginViewReactor.init(), navigatorService: self)
                let navi = BaseNavigationController.init(rootViewController: login)
                navi.modalPresentationStyle = .overFullScreen
                self.navigator.present(navi)
            case .register:
                let registerVC = RegisterViewController.init(navi: self)
                self.navigator.push(registerVC)
            case .logout:
                break
            case .findPswdConfrim:
                let confrim = FindPswdFirstController.init(navi: self)
                self.navigator.push(confrim)
            case .changePswd(account: let account):
                let changePage = FindPageSecondController.init(account: account, naviService: self)
                self.navigator.push(changePage)
            case .releaseTopic(result: let result):
                let release = ReleaseTopicViewController.init(navi: self, result: result)
                let naviBar = BaseNavigationController.init(rootViewController: release)
                naviBar.modalPresentationStyle = .overFullScreen
                self.navigator.present(naviBar)
            case .selectCity(selectedBlock: let block):
                let city = CityViewController.init(navi: self, selectedBlock: block)
                city.modalPresentationStyle = .overFullScreen
                self.navigator.present(city,animated: false)
            case .topicDetail(topicId: let topicId, model: let model,changeBlock: let block):
                let vc = TopicDetailViewController.init(navi: self,
                                                        topic_id: topicId,
                                                        model: model,
                                                        changeBlock: block)
                self.navigator.push(vc)
            case .searchPage:
                let vc = SearchMainViewController.init(navi: self)
                self.navigator.push(vc)
            case .myCollectionList:
                let vc = MyCollectionViewController.init(navi: self)
                self.navigator.push(vc)
            case .myPushList:
                let vc = MyPublishViewController.init(navi: self)
                self.navigator.push(vc)
            case .webProtocalPage(url: let url):
                let vc = WebPageViewController.init(url: url)
                self.navigator.push(vc)
            case .userEdit(fromType: let fromType):
                let vc = UserEditViewController.init(navi: self,type: fromType)
                self.navigator.push(vc)
            case .settingPage:
                let vc = SettingViewController.init(navi: self)
                self.navigator.push(vc)
            case .suggestion:
                let vc = SuggestionViewController.init(navi: self)
                self.navigator.push(vc)
            case .tagListPage(normalTag: let normal, selectedTags: let block):
                let vc = TagsViewController.init(navi: self, normal: normal, selectedBlock: block)
                self.navigator.push(vc)
            case .releaseShowInfo(result: let block):
                
                let release = ReleaseShowInfoController.init(navi: self, result: block)
                let naviBar = BaseNavigationController.init(rootViewController: release)
                naviBar.modalPresentationStyle = .overFullScreen
                self.navigator.present(naviBar)
                
            case .selectGambit(let normal,let block):
                let vc = GambitListController.init(navi: self, normal: normal, selected: block)
                self.navigator.push(vc)
            case .publishMain(let type):
                let vc = PublishMainViewController.init(navi: self,type: type)
                self.navigator.push(vc)
            case .showInfoPage(type: let type, gambitId: let gambitId,showId: let showId):
                let controller = ShowPageListController.init(navi: self, type: type,gambitId: gambitId,showId: showId)
                self.navigator.push(controller)
            case .settingChangePswd:
                let vc = ChangePswdViewController.init()
                self.navigator.push(vc)
            case .ShowCommentList(commentType: let type, topicId: let topicId,topicUInfo: let userInfo,commentResult: let result):
                let vc = CommentListController.init(navi: self,
                                                    comment_type: type,
                                                    topicId: topicId,
                                                    topicUInfo: userInfo,
                                                    commentResult: result
                )
                
                let navi = BaseNavigationController.init(rootViewController: vc)
                self.navigator.present(navi)
            case .messagePage(popBack:let black):
                let vc = AuthMessageController.init(navi: self, popBack: black)
                self.navigator.push(vc)
            case .violationsPage(report_type: let type, report_id: let report_id):
                let vc = ReportViewController.init(navi: self,
                                                   reactor: ReportReactor.init(report_Type: type,
                                                                               report_Id: report_id))
                self.navigator.push(vc)
            case .messageList(msg_type: let type,readedBlock: let block):
                let vc = MessageListController.init(navi: self, msgType: type, readedBlock: block)
                self.navigator.push(vc)
            case .sysMsgPage(readedBlock: let block):
                let vc = SystemMessageController.init(navi: self,readedBlock: block)
                self.navigator.push(vc)
                
            case .createNewGambit:
                let vc = CreateGambitController.init()
                self.navigator.push(vc)
            }
        }).disposed(by: disposeBag)

    }
    
}
