//
//  SettingViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/7.
//

import Foundation
import ReactorKit
final class SettingViewReactor: Reactor {

    enum Action {
        case loadData
        case reloadUserInfo(UserInfoModel?)
    }
    
    enum Mutation {
        case setListData([MinePageSection])
        case setUserInfo(UserInfoModel?)
    }
    
    struct State {
        var isLoading: Bool = false
        var listData: [MinePageSection] = []
        var userInfo: UserInfoModel?
    }
    
    var initialState: State = State()
    
    init() {
        /*
         我的 我的发布,我的收藏,检测更新,应用评分,关于我们，用户协议与隐私
         设置 修改昵称，头像，密码，意见反馈，退出登录
         */
        let datas = [
            [
                MinePageCellModel.init(iconImg: "icon_setting_pswd", title: "修改密码"),
                MinePageCellModel.init(iconImg: "icon_setting_fk", title: "意见反馈"),
            ],
            [
                MinePageCellModel.init(iconImg: "", title: "退出登录")
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
        initialState.listData = items
        
        // 用户信息
        initialState.userInfo = UserManager.shared.userInfo
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return Observable.empty()
        case .reloadUserInfo(let userInfo):
            return Observable.just(Mutation.setUserInfo(userInfo))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setListData(_):
            break
        case .setUserInfo(let userInfo):
            state.userInfo = userInfo
        }
        return state
    }
}

