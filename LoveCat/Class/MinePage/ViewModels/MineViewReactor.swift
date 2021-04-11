//
//  MineViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import ReactorKit
final class MineViewReactor: Reactor {
    
    enum Action {
        case loadData
        case reloadUserInfo(UserInfoModel?)
        case uploadUnread
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setListData([MinePageSection])
        case setUserInfo(UserInfoModel?)
        case setUnreadNum(UnreadModel?)
    }
    
    struct State {
        var isLoading: Bool = false
        var datas: [[MinePageCellModel]] = []
        var listData: [MinePageSection] = []
        var userInfo: UserInfoModel?
        var unreadNum: Int?
    }
    
    var initialState: State = State()
    var networking = NetWorking<MinePageApi>()
    init() {
        /*
         我的 我的发布,我的收藏,检测更新,应用评分,关于我们，用户协议与隐私
         设置 修改昵称，头像，密码，意见反馈，退出登录
         */
        
        initialState.listData = self.updateMyPageData(num: currentState.unreadNum ?? 0)
        // 用户信息
        initialState.userInfo = UserManager.shared.userInfo
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return Observable.empty()
        case .reloadUserInfo(let userInfo):
            return Observable.just(Mutation.setUserInfo(userInfo))
        case .uploadUnread:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.messageNumNetworking().map { (baseModel) -> Mutation in
                return Mutation.setUnreadNum(baseModel?.data)
            }
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setListData(_):
            break
        case .setUserInfo(let userInfo):
            state.userInfo = userInfo
        case .setUnreadNum(let data):
            guard let model = data else {
                return state
            }
            if let num = model.number {
                state.unreadNum = num
                state.listData = self.updateMyPageData(num: state.unreadNum ?? 0)
            }
        case .setLoading(let loading):
            state.isLoading = loading
        }
        return state
    }
    
    func updateMyPageData(num: Int) -> [MinePageSection]{
        let datas = [
            [
                MinePageCellModel.init(iconImg: "icon_view_hist", title: "浏览记录"),
                MinePageCellModel.init(iconImg: "icon_mi_publish", title: "我的发布"),
                MinePageCellModel.init(iconImg: "icon_mi_collection", title: "我的收藏")
            ],
            [
                MinePageCellModel.init(iconImg: "icon_mi_upload", title: "检测更新"),
                MinePageCellModel.init(iconImg: "icon_mi_pf", title: "应用评分"),
                MinePageCellModel.init(iconImg: "icon_mi_xy", title: "用户协议"),
                MinePageCellModel.init(iconImg: "icon_pravicy", title: "隐私政策"),
                MinePageCellModel.init(iconImg: "icon_mi_about", title: "关于我们"),
            ]
        ]
        
        let items = datas.map { (models) -> MinePageSection in
            let section = models.map { (model) -> MinePageItem in
                if model.title == "退出登录" {
                    return MinePageItem.logoutItem
                }else{
                    return MinePageItem.defaultItem(MinePageCellReactor.init(model: model))
                }
            }
            return MinePageSection.minePageItems(section)
        }
        return items
    }
    
    func messageNumNetworking() -> Observable<BaseModel<UnreadModel>?> {
        return networking.request(.authUnReadNum).mapData(UnreadModel.self)
    }

}

