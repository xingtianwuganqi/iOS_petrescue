//
//  ReleaseTopicReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/22.
//

import Foundation
import RxSwift
import ReactorKit
import Moya
import HandyJSON

final class ReleaseTopicReactor: Reactor {
    
    enum Action {
        case createNewTopic
        case addPhoto(img: UIImage)
        case deletePhoto(img: ReleasePhotoModel)
        case getUploadToken
        case releaseTopic(content: String,imgs: String,address: String,contact: String)
        case updatePhotos(ReleasePhotoModel)
        case updateContact(String?)
        case changeLocation(String?)
        case tagInfos([TagInfoModel])
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
        case setLocation(String?)
        case setDeletePhoto(ReleasePhotoModel)
        case setErrorMsg(String?)
        case setContact(String?)
        case setTagInfos([TagInfoModel])
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
        var contactInfo: String?
        var token: String?
        var location: String?
        var tags: [TagInfoModel] = []
    }
    
    var initialState: State = State()
    lazy var netWorking = NetWorking<HomePageApi>()    
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
        case .releaseTopic(content: let content, imgs: let imgs, address: let address, contact: let contact):
            guard !self.currentState.isLoading else {
                return .empty()
            }

            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.releaseNetworking(content: content, imgs: imgs, address: address, contact: contact).asObservable().map { (model) -> Mutation in
                
                if model?.isSuccess == true {
                    return Mutation.setReleaseResult(true)
                }else{
                    return Mutation.setReleaseResult(false)
                }
            }.catchError { (error) -> Observable<Mutation> in
                return Observable.just(Mutation.setErrorMsg("网络错误"))
            }
            return .concat(start,request,end)
        case .updatePhotos(let photo):
            return Observable.just(Mutation.setUpdatePhotos(photo))
        case .changeLocation(let location):
            return Observable.just(Mutation.setLocation(location))
        case .deletePhoto(img: let deleteModel):
            return Observable.just(Mutation.setDeletePhoto(deleteModel))
        case .updateContact(let contact):
            return .just(.setContact(contact))
        case .tagInfos(let tags):
            return .just(.setTagInfos(tags))
        case .reloadCacheData(let data):
            return .just(.setCacheData(data))
        default:
            return Observable.empty()
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
        case .setLocation(let location):
            state.location = location
        case .setDeletePhoto(let deleteModel):
            let photos = state.photoModels.filter { (model) -> Bool in
                return model.photoKey != deleteModel.photoKey
            }
            state.photoModels = photos
        case .setContact(let contact):
            state.contactInfo = contact
        case .setReleaseResult(let releaseResult):
            state.releaseResult = releaseResult
        case .setTagInfos(let infos):
            state.tags = infos
        case .setCacheData(let cacheData):
            state.tags = cacheData.tagInfos ?? []
            state.contactInfo = cacheData.contact
            state.location = cacheData.address
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
            
        default:
            break
        }
        return state
    }
}

extension ReleaseTopicReactor {
    func releaseNetworking(content: String,imgs: String,address: String,contact: String) -> Observable<BaseModel<EmptyModel>?>{
        var tagsInfo: String?
        if currentState.tags.count > 0 {
            let arr = currentState.tags.map { (model) -> String in
                return "\(model.id ?? 0)"
            }.filter { (str) -> Bool in
                str != "0"
            }
            tagsInfo = arr.joined(separator: ",")
        }
        return self.netWorking.request(.releaseTopic(content: content, imgs: imgs, address: address, contact: contact, tags: tagsInfo))
            .mapData(EmptyModel.self)
    }
    
    func getUploadToken() -> Observable<BaseModel<TokenModel>?> {
        return self.netWorking.request(.getUploadToken).mapData(TokenModel.self)
    }
}
