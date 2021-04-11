//
//  ReleaseShowInfoReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/19.
//

import Foundation
import RxSwift
import ReactorKit
import Moya
import HandyJSON

final class ReleaseShowInfoReactor: Reactor {
    
    enum Action {
        case addPhoto(img: UIImage)
        case deletePhoto(img: ReleasePhotoModel)
        case getUploadToken
        case releaseShowInfo(content: String,imgs: String,gambit_id: Int?)
        case updatePhotos(ReleasePhotoModel)
        case gambitInfo(GambitListModel?)
        case reloadCacheData(CacheReleaseInfo)
    }
    
    enum Mutation {
        case setCreate
        case setPhotoModels(img: UIImage)
        case setLoading(Bool)
        case setReleaseResult(Bool)
        case setUpdatePhotos(ReleasePhotoModel)
        case setToken(String)
        case empty
//        case setLocation(String?)
        case setDeletePhoto(ReleasePhotoModel)
        case setErrorMsg(String?)
//        case setContact(String?)
        case setGambitInfo(GambitListModel?)
        case setCacheData(CacheReleaseInfo)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var isCreated: Bool = false
        var message: String?
        var releaseResult: Bool = false
        var updatePhotoComplet: Bool = false
        var photoModels: [ReleasePhotoModel] = [ReleasePhotoModel.init(image: nil, isAdd: true)]
//        var contactInfo: String?
        var token: String?
//        var location: String?
        var gambitInfo: GambitListModel?
    }
    
    var initialState: State = State()
    lazy var netWorking = NetWorking<ShowPageApi>()
    lazy var homeNet = NetWorking<HomePageApi>()
    init() {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .addPhoto(img: let img):
            return Observable.just(Mutation.setPhotoModels(img: img))
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
        case .releaseShowInfo(content: let content, imgs: let imgs,gambit_id: let gambit_id):
            guard !self.currentState.isLoading else {
                return .empty()
            }

            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.releaseShowInfoNetworking(instruction: content, imgs: imgs, gambit_id: gambit_id).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess == true {
                    return Mutation.setReleaseResult(true)
                }else{
                    return Mutation.setReleaseResult(false)
                }
            }
            return .concat(start,request,end)
        case .updatePhotos(let photo):
            return Observable.just(Mutation.setUpdatePhotos(photo))

        case .deletePhoto(img: let deleteModel):
            return Observable.just(Mutation.setDeletePhoto(deleteModel))
        case .gambitInfo(let infos):
            return .just(.setGambitInfo(infos))
        case .reloadCacheData(let data):
            return .just(.setCacheData(data))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.message = nil
        switch mutation {
        case .setLoading(let isloading):
            state.isLoading = isloading
        case .setPhotoModels(img: let img):
            if state.photoModels.count > 6 {
                state.message = "最多可上传6张图片"
            }else {
                let model = ReleasePhotoModel.init(image: img, isAdd: false)
                state.photoModels.insert(model, at: state.photoModels.count - 1)
                state.message = nil
            }
        case .setUpdatePhotos(let photo):
            let photos = state.photoModels.map { (model) -> ReleasePhotoModel in
                if model.photoKey == photo.photoKey {
                    return photo
                }else{
                    return model
                }
            }
            state.photoModels = photos
            
            let compleCount = state.photoModels.filter { (model) -> Bool in
                return model.complete == true
            }.count
            
            let totalCount = state.photoModels.filter { (model) -> Bool in
                return model.isAdd == false
            }.count
            
            if totalCount == compleCount {
                state.updatePhotoComplet = true
            }
        case .setToken(let token):
            state.token = token

        case .setDeletePhoto(let deleteModel):
            let photos = state.photoModels.filter { (model) -> Bool in
                return model.photoKey != deleteModel.photoKey
            }
            state.photoModels = photos

        case .setReleaseResult(let releaseResult):
            state.releaseResult = releaseResult
        case .setGambitInfo(let infos):
            state.gambitInfo = infos
        case .setCacheData(let cacheData):
            let cacheModels = cacheData.photos?.map({ (cacheModel) -> ReleasePhotoModel in
                var photoModel = ReleasePhotoModel.init()
                if let imgStr = cacheModel.image ,let image = Tool.shared.loadCacheImage(filePath: imgStr ) {
                    photoModel.image = image
                }
                photoModel.photoKey = cacheModel.photoKey ?? ""
                photoModel.isAdd = cacheModel.isAdd
                return photoModel
            }) ?? []
            state.photoModels = cacheModels + state.photoModels
            state.gambitInfo = cacheData.gambit
        default:
            break
        }
        return state
    }
}

extension ReleaseShowInfoReactor {
    func releaseShowInfoNetworking(instruction: String,imgs: String,gambit_id: Int?) -> Observable<BaseModel<EmptyModel>?>{
        return self.netWorking.request(.releaseShowInfo(instruction: instruction, imgs: imgs, gambitId: gambit_id)).mapData(EmptyModel.self)
    }
    
    func getUploadToken() -> Observable<BaseModel<TokenModel>?> {
        return self.homeNet.request(.getUploadToken).mapData(TokenModel.self)
    }
}
