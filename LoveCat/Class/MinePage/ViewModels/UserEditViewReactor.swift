//
//  UserEditViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/11.
//

import Foundation
import ReactorKit
final class UserEditViewReactor: Reactor {

    enum Action {
        case loadData
        case changeNickName(String)
        case addPhoto(UIImage)
        case getUploadToken
        case updatePhotos(ReleasePhotoModel)
        case uploadUserInfo(avator: String?,username: String)
    }

    enum Mutation {
        case setData
        case setLoading(Bool)
        case setPhotoModel(UIImage)
        case setNickName(String)
        case setErrorMsg(String?)
        case setToken(String)
        case setUpdatePhotos(ReleasePhotoModel)
        case setNewInfo(UserInfoModel?)
    }

    struct State {
        var isLoading: Bool = false
        var photoModel: ReleasePhotoModel?
        var dataSource: [UserEditModel] = []
        var avator: String?
        var nickName: String?
        var token: String?
        var errorMsg: String?
        var updatePhotoComplet: Bool = false
        var newInfo: UserInfoModel?
        
    }

    var initialState: State = State()
    var netWorking = NetWorking<HomePageApi>()
    var uploadNetworking = NetWorking<MinePageApi>()
    var section: PublishSubject<[UserEditSection]> = PublishSubject.init()

    init() {
        let user = UserManager.shared.userInfo
        initialState.dataSource = [
            UserEditModel.init(title: "头像", placeholder: nil, textValue: user?.avator ?? ""),
            UserEditModel.init(title: "昵称", placeholder: "请输入昵称", textValue: user?.username ?? nil),
        ]
        
        initialState.nickName = user?.username
        initialState.avator = user?.avator
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return Observable.just(Mutation.setData)
        case .changeNickName(let nickname):
            return Observable.just(Mutation.setNickName(nickname))
        case .addPhoto(let photo):
            return Observable.just(Mutation.setPhotoModel(photo))
        case .getUploadToken:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let request = self.getUploadToken().asObservable().map { (model) -> Mutation in
                guard let token = model?.data?.token,token.count > 0 else {
                    return Mutation.setErrorMsg("获取token失败")
                }
                return Mutation.setToken(token)
            }.catchError { (error) -> Observable<Mutation> in
                
                return Observable.just(Mutation.setErrorMsg("网络错误"))
            }
            let end = Observable.just(Mutation.setLoading(false))
            return .concat(start,request,end)
        case .updatePhotos(let model):
            return Observable.just(Mutation.setUpdatePhotos(model))
        case .uploadUserInfo(avator: let avator, username: let username):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.uploadInfoNetWorking(avator: avator, username: username).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setNewInfo(baseModel?.data)
                }else{
                    return Mutation.setNewInfo(nil)
                }
            }.catchErrorJustReturn(Mutation.setNewInfo(nil))
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMsg = nil
        switch mutation {
        case .setData:
            
            let items = initialState.dataSource.map { (models) -> UserEditItem in
                if models.title == "头像" {
                    return UserEditItem.editHeadImg(models)
                }else {
                    return  UserEditItem.editItem(models)
                }
            }
            let section = UserEditSection.userEditItem(items)
            self.section.onNext([section])
            
        case .setLoading(let loading):
            state.isLoading = loading
            
        case .setPhotoModel(let img):
            let model = ReleasePhotoModel.init(image: img, isAdd: false)
            state.photoModel = model
            
            let newData = UserEditModel.init(title: "头像", placeholder: nil, textValue: nil, avator: model.image)
            state.dataSource[0] = newData
            
            let nickData : UserEditModel
            if let nickName = state.nickName,nickName.count > 0 {
                nickData = UserEditModel.init(title: "昵称", placeholder: "请输入昵称", textValue: nickName)
            }else{
                nickData = UserEditModel.init(title: "昵称", placeholder: "请输入昵称", textValue: state.dataSource[1].textValue ?? nil)
            }
            state.dataSource[1] = nickData
            
            let items = state.dataSource.map { (models) -> UserEditItem in
                if models.title == "头像" {
                    return UserEditItem.editHeadImg(models)
                }else {
                    return  UserEditItem.editItem(models)
                }
            }
            let section = UserEditSection.userEditItem(items)
            self.section.onNext([section])
            
        case .setNickName(let nickName):
            state.nickName = nickName
            
        case .setErrorMsg(let msg):
            state.errorMsg = msg
            
        case .setToken(let token):
            state.token = token
        case .setUpdatePhotos(let model):
            state.photoModel = model
            state.avator = model.photoUrl
            state.updatePhotoComplet = true
        case .setNewInfo(let model):
            if let model = model {
                state.newInfo = model
            }else {
                state.errorMsg = "更新失败"
            }
        }
        return state
    }
    
    func getUploadToken() -> Observable<BaseModel<TokenModel>?> {
        return self.netWorking.request(.getUploadToken).mapData(TokenModel.self)
    }
    
    func uploadInfoNetWorking(avator: String?,username: String) -> Observable<BaseModel<UserInfoModel>?> {
        return self.uploadNetworking.request(.uploadUserInfo(avator: avator, username: username)).mapData(UserInfoModel.self)
    }
}

