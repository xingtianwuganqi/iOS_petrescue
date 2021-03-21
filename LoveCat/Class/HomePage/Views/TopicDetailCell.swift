//
//  TopicDetailCell.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/28.
//

import UIKit
import ReactorKit

class TopicDetailInfoCell: UITableViewCell,View {
    var disposeBag: DisposeBag = DisposeBag()

    typealias Reactor = TopicInfoCellReactor
    
    lazy var userInfo : TopicUserInfoView = {
        let backview = TopicUserInfoView()
        backview.backgroundColor = .white
        return backview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(userInfo)
        userInfo.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: TopicInfoCellReactor) {
        userInfo.reactor = reactor
    }

}


class TopicDetailContentCell: UITableViewCell,View {

    var disposeBag: DisposeBag = DisposeBag()

    typealias Reactor = TopicContentCellReactor
    
    lazy var content : TopicContentView = {
        let backview = TopicContentView()
        backview.backgroundColor = .white
        return backview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(content)
        content.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: TopicContentCellReactor) {
        content.reactor = reactor
    }
}

class TopicDetailImgCell: UITableViewCell, View {
    
    var disposeBag: DisposeBag = DisposeBag()

    typealias Reactor = TopicImgCellReactor
    
    lazy var imgView : UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    var reloadTable: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(reactor: TopicImgCellReactor) {
        reactor.state.map {
            $0.img
        }.subscribe(onNext: { [weak self](img) in
            guard let `self` = self else { return }

            self.imgView.et.sd_setImage(img) { (image, error, type, url) in
                if let imageV = image {
                    WebImageSizeCache.shard.cacheImageSizeBy(image: imageV, for: img, completion: { finish in
                        self.reloadTable?(img)
                    })
                }
            }
        }).disposed(by: disposeBag)
    }
}
