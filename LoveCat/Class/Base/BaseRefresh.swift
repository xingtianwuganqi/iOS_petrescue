//
//  BaseRefresh.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/2.
//

import Foundation
import MJRefresh
class BaseRefresh: MJRefreshStateHeader {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        /*
         /** 刷新控件的状态 */
         typedef NS_ENUM(NSInteger, MJRefreshState) {
             /** 普通闲置状态 */
             MJRefreshStateIdle = 1,
             /** 松开就可以进行刷新的状态 */
             MJRefreshStatePulling,
             /** 正在刷新中的状态 */
             MJRefreshStateRefreshing,
             /** 即将刷新的状态 */
             MJRefreshStateWillRefresh,
             /** 所有数据加载完毕，没有更多的数据了 */
             MJRefreshStateNoMoreData
         };
         */


        self.setTitle("下拉刷新...", for: .idle)
        self.setTitle("放开以刷新...", for: .pulling)
        self.setTitle("正在载入...", for: .refreshing)
        self.lastUpdatedTimeLabel?.isHidden = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
/*
 func addFooter(refreshingBlock: @escaping MJRefreshComponentRefreshingBlock) {
     let footer = MJRefreshAutoStateFooter(refreshingBlock: refreshingBlock)
     footer.setTitle("", for: .idle)
     footer.setTitle("上拉加载更多", for: .pulling)
     footer.setTitle("正在载入…", for: .refreshing)
     footer.setTitle("暂无更多数据", for: .noMoreData)
     base.mj_footer = footer
 }
 */
class BaseFooterRefresh: MJRefreshAutoStateFooter {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitle("上拉加载更多...", for: .idle)
        self.setTitle("上拉加载更多...", for: .pulling)
        self.setTitle("正在载入...", for: .refreshing)
        self.setTitle("已经到底啦", for: .noMoreData)
        self.stateLabel?.textColor = UIColor(hexString: "#9b9b9b")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MJRefreshFooter: ETExtensionCompatible {
    
}

extension ET where Base: MJRefreshFooter {
    func setRefState(state: RefreshState) {
        let refresh = base as? MJRefreshAutoStateFooter
        switch state {
        case .empty:
            refresh?.setTitle("", for: .idle)
            refresh?.state = .idle
        case .idle:
            refresh?.setTitle("上拉加载更多...", for: .idle)
            refresh?.state = .idle
        default:
            refresh?.state = MJRefreshState.init(rawValue: state.rawValue)!
        }
    }
}

enum RefreshState: Int {
    case empty = 0, idle, pulling, refreshing,willRefresh, noMoreData
}
