////
////  CommentListCellModel.swift
////  LoveCat
////
////  Created by jingjun on 2021/1/28.
////
//
//import Foundation
//
//struct RTMoodReplyHeader: HeaderRepresentable {
//    var height: CGFloat = 50
////    var height: CGFloat {
////        if let audio = self.headModel.audioList?.first,audio.count > 0 {
////            return 105
////        }else if let img = self.headModel.imgList?.first,img.count > 0 {
////            return 175
////        }else if let content = self.headModel.content {
////            let h = (content as NSString).boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH - 70, height: .infinity), options: [.usesFontLeading,.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.rt.font(size: scaleXSize(12))], context: nil)
////            return h.height + 80
////        }else{
////            return 0
////        }
////    }
//    
//    var identifier: String = "ShowListCommentView"
//    var headModel: CommentListModel?
//    var items: [CellRepresentable] = []
//    var didSelect: ((CommentListModel,Int) -> Void)?
//    init(model: CommentListModel,didSelect: ((CommentListModel,Int) -> Void)?) {
//        self.headModel = model
//        self.didSelect = didSelect
//        if model.isOpend ?? false {
//            items = model.replyList?.compactMap({ (model) -> CellRepresentable? in
//                return RTMoodReplyCellModel.init(model: model)
//            }) ?? []
//        }else{
//            if let count = model.replyList?.count,count > 1,let replyModel = model.replyList?.first {
//                items.removeAll()
//                items.append(RTMoodReplyCellModel.init(model: replyModel))
//                items.append(RTMoodReplyOpenCellModel.init(num: count))
//            }else if let count = model.replyList?.count, count > 0,let replyModel = model.replyList?.first {
//                items.removeAll()
//                items.append(RTMoodReplyCellModel.init(model: replyModel))
//            }
//        }
//        
//    }
//    
//    func headerView(_ tableView: UITableView, section: Int) -> UITableViewHeaderFooterView? {
//        let header = ShowListCommentView.init(style: <#UITableViewCell.CellStyle#>, reuseIdentifier: identifier)
////        header.headModel = self
//        return header
//    }
//    
//}
//
//struct RTMoodReplyCellModel: CellRepresentable {
//    var rowHeight: CGFloat = 40
////    var rowHeight: CGFloat {
////        if let audio = self.model?.audioList?.first,audio.count > 0 {
////            return 85
////        }else if let img = self.model?.imgList?.first,img.count > 0 {
////            return 155
////        }else if let content = self.model?.content {
////            let h = (content as NSString).boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH - 70, height: .infinity), options: [.usesFontLeading,.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.rt.font(size: scaleXSize(12))], context: nil)
////            return h.height + 55
////        }else{
////            return 0
////        }
////
////    }
//    
//    var cellIdentifier: String = "RTMoodReplyCell"
//    
//    var model: ReplyListModel?
//    
//    init(model: ReplyListModel?) {
//        self.model = model
//    }
//    
//    func cellInstance(_ tableView: UITableView, indexPath: IndexPath, currentController: UIViewController?) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ShowListReplyCell
//        if cell == nil {
//            cell = ShowListReplyCell.init(style: .default, reuseIdentifier: cellIdentifier)
//        }
////        cell?.cellModel = self
//        return cell!
//    }
//}
//
//struct RTMoodReplyOpenCellModel: CellRepresentable {
//    var rowHeight: CGFloat = 40
//    
//    var cellIdentifier: String = "ShowListReplyOpenCell"
//    var num: Int
//    init(num: Int) {
//        self.num = num
//    }
//    
//    func cellInstance(_ tableView: UITableView, indexPath: IndexPath, currentController: UIViewController?) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ShowListReplyOpenCell
//        if cell == nil {
//            cell = ShowListReplyOpenCell.init(style: .default, reuseIdentifier: cellIdentifier)
//        }
////        cell?.cellModel = self
//        return cell!
//    }
//    
//    
//}
