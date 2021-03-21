//
//  TopicDetailCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/28.
//

import Foundation
import RxSwift
import ReactorKit
final class TopicInfoCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var detail: HomePageModel
    }
    
    var initialState: State
    
    init(detail: HomePageModel) {
        self.initialState = .init(detail: detail)
    }
    
}

final class TopicContentCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var topicDetial: HomePageModel
    }
    
    var initialState: State
    
    init(topicDetail: HomePageModel) {
        self.initialState = .init(topicDetial: topicDetail)
    }
    
}

final class TopicImgCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var img: String
    }
    
    var initialState: State
    
    init(img: String) {
        self.initialState = .init(img: img)
    }
    
}
