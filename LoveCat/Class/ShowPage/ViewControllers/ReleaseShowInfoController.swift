//
//  ReleaseShowInfoController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/19.
//

import UIKit

import YYKit
import RxSwift
import ReactorKit
import RxViewController
import MBProgressHUD
import SnapKit

class ReleaseShowInfoController: BaseViewController,View {
    static let cellW = floor((SCREEN_WIDTH - 30 - 2 * 10) / 3)
    typealias Reactor = ReleaseShowInfoReactor
    
    lazy var layoutView: GambitView = {
        let layoutView = UINib(nibName: "GambitView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! GambitView
        layoutView.backgroundColor = UIColor.color(.defIcon)
        layoutView.layer.cornerRadius = 12
        layoutView.layer.masksToBounds = true
        layoutView.isHidden = true
        return layoutView
    }()
    
    lazy var gambitButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.et.fontSize()
        button.setTitle("添加话题", for: .normal)
        button.setTitleColor(UIColor.color(.system), for: .normal)
        button.setImage(UIImage(named: "icon_btn_right"), for: .normal)
        button.setImage(UIImage(named: "icon_btn_right"), for: .highlighted)
        button.sizeToFit()
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(button.imageView?.frame.size.width)!, bottom: 0, right: (button.imageView?.frame.size.width)!)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: (button.titleLabel?.frame.size.width)!, bottom: 0, right: 0)
        return button
    }()
    
    lazy var textView : YYTextView = {
        let backview = YYTextView.init()
        backview.backgroundColor = .white
        backview.textColor = UIColor.color(.content)
        backview.font = UIFont.et.fontSize()
        backview.placeholderText = "请输入简单说明"
        backview.returnKeyType = .next
        backview.delegate = self
        return backview
    }()
    
    lazy var textCountLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.fontSize()
        return label
    }()
    
//    lazy var textView : UITextView = {
//        let backview = UITextView.init()
//        backview.backgroundColor = .white
//        backview.textColor = UIColor.color(.content)
//        backview.font = UIFont.et.fontSize()
////        backview.placeholderText = "请输入简单说明"
//        backview.returnKeyType = .next
//        return backview
//    }()
//
    lazy var photoView : ReleaseImgView = {
        let phtView = ReleaseImgView(cellW: ReleaseShowInfoController.cellW)
        return phtView
    }()
    
//    lazy var contactView : ContactTextView = {
//        let textView = ContactTextView.init()
//        textView.layer.cornerRadius = 6
//        textView.layer.masksToBounds = true
//        textView.textField.delegate = self
//        return textView
//    }()
    
//    lazy var addressView: AddressView = {
//        let address = AddressView.init()
//        address.layer.cornerRadius = 6
//        address.layer.masksToBounds = true
//        address.title = "请选择地区"
//        address.addressLab.textColor = UIColor(hexString: "#BCBCBC")
//        return address
//    }()
    
    lazy var remindLab : YYLabel = {
        let remind = YYLabel.init()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = scaleXSize(3.0)     //设置行间距
        paragraphStyle.alignment = .justified      //文本对齐方向
        let attribute = NSMutableAttributedString.init()
        let title = "禁止出现商业广告、低俗、色情、暴力、具有侮辱性语音或与宠物无关等内容，违规者帖子会被删除！"
        attribute.append(NSAttributedString(string: title,
                                            attributes: [
                                                NSAttributedString.Key.foregroundColor: UIColor.color(.desc)!,
                                                NSAttributedString.Key.font: UIFont.et.font(size: 13),
                                                NSAttributedString.Key.paragraphStyle: paragraphStyle
                                            ]))
        remind.attributedText = attribute
        remind.numberOfLines = 0
        remind.preferredMaxLayoutWidth = SCREEN_WIDTH - 30
        return remind
    }()
    
    lazy var releaseBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("发布", for: .normal)
        button.setTitleColor(UIColor.color(.system), for: .normal)
        button.titleLabel?.font = UIFont.et.fontSize(.medium, .content)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        return button
    }()
    
    lazy var bottomBack: UIView = {
        let back = UIView()
        back.backgroundColor = UIColor.color(.tableBack)
        return back
    }()
    
    lazy var toolBar : UIToolbar = {
        let toolBar = UIToolbar.init()
        toolBar.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 50)
        return toolBar
    }()
    
    lazy var qnManager : QNUploadManager = {
        let config = QNConfiguration.build { (config) in
            config?.setZone(QNFixedZone.zone1())
        }
        let manager = QNUploadManager.init(configuration: config)
        return manager!
    }()
    var releaseSuccess: ((Bool) -> Void)?
    
    // 记录在本地的tags 和 layoutview 的高度，只有在值变化的时候才更新高度
    fileprivate var tags: [TagInfoModel] = []
    fileprivate var photoViewHeight: CGFloat = 0
    
    fileprivate var photoHeightConstraint: Constraint?
    
    init(navi: NavigatorServiceType,result: ((Bool) -> Void)?) {
        super.init(navi: navi)
        self.releaseSuccess = result
        defer {
            self.reactor = ReleaseShowInfoReactor.init()
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "秀宠"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notify:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notify:)),
                                               name: UIResponder.keyboardWillHideNotification ,
                                               object: nil)
        
        self.gambitButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.pushToGambitView()
        }).disposed(by: disposeBag)
        
        self.layoutView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.pushToGambitView()
            }).disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: releaseBtn)
        /* FkV6TtZjT0GzvcXAqJM4kHwqwXr0  FkV6TtZjT0GzvcXAqJM4kHwqwXr0*/
        self.releaseBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if let released = UserDefaults.standard.value(forKey: ShowReleased) as? Bool,released == true {
                self.pushBtnRelease()
            }else{
                self.showPushAlert()
            }
        }).disposed(by: disposeBag)
        
        self.view.addSubview(self.layoutView)
        self.view.addSubview(self.gambitButton)
        self.view.addSubview(self.textView)
        
        self.view.addSubview(photoView)
//        self.view.addSubview(addressView)
//        self.view.addSubview(contactView)
        self.view.addSubview(remindLab)
        self.view.addSubview(self.textCountLab)
        
        remindLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-25)
        }
        
//        addressView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.right.lessThanOrEqualToSuperview().offset(-15)
//            make.bottom.equalTo(remindLab.snp.top).offset(-15)
//            make.height.equalTo(40)
//        }
        

        
//        contactView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.right.equalToSuperview().offset(-15)
//            make.bottom.equalTo(addressView.snp.top).offset(-15)
//            make.height.equalTo(40)
//        }
        
        self.layoutView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.lessThanOrEqualTo(self.view.snp.right).offset(-10)
            make.height.equalTo(24)
        }
        
        photoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(layoutView.snp.bottom).offset(10)
            self.photoHeightConstraint = make.height.equalTo(ReleaseShowInfoController.cellW).constraint
        }
        
        self.textView.snp.makeConstraints { (make) in
            make.top.equalTo(photoView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(remindLab.snp.top).offset(-15)
        }
        
        textCountLab.snp.makeConstraints { (make) in
            make.right.equalTo(textView.snp.right)
            make.bottom.equalTo(textView.snp.bottom).offset(-5)
        }
        
        self.gambitButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(18)
            make.height.equalTo(24)
        }
        
        let photoBtn = UIButton.init(type: .custom)
        photoBtn.setImage(UIImage(named: "icon_img"), for: .normal)
        photoBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        photoBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.resignFirst()
            self.imageSelectPicker()
        }).disposed(by: disposeBag)
        
//        let atBtn = UIButton.init(type: .custom)
//        atBtn.setTitle("话题", for: .normal)
//        atBtn.titleLabel?.font = UIFont.et.fontSize()
//        atBtn.setTitleColor(UIColor.color(.system), for: .normal)
//        atBtn.layer.borderWidth = 1
//        atBtn.layer.borderColor = UIColor.color(.system)?.cgColor
//        atBtn.layer.cornerRadius = 5
//        atBtn.layer.masksToBounds = true
//        atBtn.frame = CGRect(x: 0, y: 10, width: 50, height: 30)
        
        let tagBtn = UIButton.init(type: .custom)
        tagBtn.setImage(UIImage(named: "icon_release_gb"), for: .normal)
        tagBtn.frame = CGRect(x: 0, y: 10, width: 50, height: 30)
        tagBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.pushToGambitView()
        }).disposed(by: disposeBag)
        
//        let addressBtn = UIButton.init(type: .custom)
//        addressBtn.setImage(UIImage(named: "icon_location"), for: .normal)
//        addressBtn.frame = CGRect(x: 0, y: 10, width: 50, height: 30)
//        addressBtn.rx.tap.subscribe(onNext: { [weak self] in
//            guard let `self` = self else { return }
//            self.resignFirst()
//            self.naviService.navigatorSubject.onNext(.selectCity(selectedBlock: { (location) in
//                self.reactor?.action.onNext(.changeLocation(location))
//            }))
//        }).disposed(by: disposeBag)

        
        let doneBtn = UIButton.init(type: .custom)
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.titleLabel?.font = UIFont.et.fontSize()
        doneBtn.setTitleColor(UIColor.color(.system), for: .normal)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        doneBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.resignFirst()
        }).disposed(by: disposeBag)
        
        let photoItem = UIBarButtonItem.init(customView: photoBtn)
//        let atItem = UIBarButtonItem.init(customView: atBtn)
        let tagItem = UIBarButtonItem.init(customView: tagBtn)
//        let addreessItem = UIBarButtonItem(customView: addressBtn)
        //空隙
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(customView: doneBtn)
        var items: [UIBarButtonItem] = []
        items.append(tagItem)
        items.append(photoItem)
        items.append(flexSpace)
        items.append(doneItem)
        toolBar.items = items
        
        self.textView.inputAccessoryView = self.toolBar
//        self.contactView.textField.inputAccessoryView = self.toolBar
        toolBar.sizeToFit()
        
        self.photoView.model = reactor?.currentState.photoModels
        
        photoView.addPhotoClick = { [weak self] () in
            guard let `self` = self else { return }
            self.imageSelectPicker()
        }
        
        photoView.deleteItmeBlock = { [weak self](item) in
            guard let `self` = self else { return }
            self.reactor?.action.onNext(.deletePhoto(img: item))
        }
        
        self.textCountLab.text = "\(self.textView.text.count)/1000"
    }
    
    func resignFirst() {
        self.textView.resignFirstResponder()
//        self.contactView.textField.resignFirstResponder()
    }
    
    @objc private func keyboardWillShow(notify: Notification) {
        
//        guard self.contactView.textField.isFirstResponder else{
//            return
//        }
        
        guard let info = notify.userInfo else { return }
        let rect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let keyboardHeight = rect.size.height
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
 
//        let keyHeight :CGFloat = keyboardHeight - (SystemSafeBottomHeight + 120)
        let textRect = self.textView.convert(self.view.frame, to: self.view)
        let y = textRect.origin.y - SystemNavigationBarHeight
        let keyHeight = y
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.init(translationX: 0, y: -keyHeight)
        } completion: { (completion) in
            
        }

    }
    
    @objc private func keyBoardWillHide(notify: Notification) {
        guard self.view.origin.y != 0 else{
            return
        }
        guard let info = notify.userInfo else { return }
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.0
    
        UIView.animate(withDuration: duration) {
            self.view.transform = .identity
        }
    }
    
    func contactResignFirst(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.view.transform = .identity
        }
    }
    
    func pushToGambitView() {
        self.resignFirst()
        self.naviService.navigatorSubject.onNext(.selectGambit(normal: self.reactor?.currentState.gambitInfo, selected: { (gambit) in
            self.reactor?.action.onNext(.gambitInfo(gambit))
        }))
    }
}

extension ReleaseShowInfoController {
    func bind(reactor: ReleaseShowInfoReactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            guard let `self` = self else { return }
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.gambitInfo
        }.subscribe(onNext: { [weak self](model) in
            guard let `self` = self else { return }
            if let model = model {
                self.gambitButton.isHidden = true
                self.layoutView.isHidden = false
                self.layoutView.descLab.text = model.descript
            }else {
                self.gambitButton.isHidden = false
                self.layoutView.isHidden = true
                self.layoutView.descLab.text = ""
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.photoModels
        }.subscribe(onNext: { [weak self](models) in
            guard let `self` = self else { return }
            self.photoView.model = models
            if models.count > 3 {
                self.photoHeightConstraint?.update(offset: ReleaseShowInfoController.cellW * 2 + 10)
            }else{
                self.photoHeightConstraint?.update(offset: ReleaseShowInfoController.cellW)
            }
        }).disposed(by: disposeBag)
        
        
        reactor.state.map {
            $0.updatePhotoComplet
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self](completion) in
            guard let `self` = self else { return }
            guard completion else {
                MBProgressHUD.xy_hide()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard let info = self.canRelease() else {
                    return
                }
                let imgArr = info.photos.map { (model) -> String in
                    MBProgressHUD.xy_hide()
                    return model.photoUrl
                }
                guard imgArr.count > 0 else {
                    return
                }
                let imgStr = imgArr.joined(separator: ",")
                var gambit_id: Int?
                if let gambitId = reactor.currentState.gambitInfo?.id {
                    gambit_id = gambitId
                }
                self.reactor?.action.onNext(.releaseShowInfo(content: info.content,
                                                             imgs: imgStr,
                                                             gambit_id: gambit_id
                                                          ))
            }

        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.releaseResult
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self](result) in
            guard result == true else {
                return
            }
            guard let `self` = self else { return }
            self.view.xy_hideHUD()
            self.view.xy_show("发布成功")
            self.releaseSuccess?(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.token
        }.distinctUntilChanged()
        .filter {
            $0 != nil
        }.subscribe(onNext: {[weak self] (token) in
            guard let `self` = self else { return }
            guard let token = token else {
                MBProgressHUD.xy_hide()
                return
            }
            self.uploadImg(token: token)
        }).disposed(by: disposeBag)
        
//        addressView.rx.tapGesture().when(.recognized)
//            .subscribe(onNext: { [weak self](tap) in
//                guard let `self` = self else { return }
//                self.naviService.navigatorSubject
//                    .onNext(.selectCity(selectedBlock: { (location) in
//                    self.reactor?.action.onNext(.changeLocation(location))
//                }))
//            }).disposed(by: disposeBag)
        
//        reactor.state.map {
//            $0.location
//        }.subscribe(onNext: { [weak self](locaiton) in
//            guard let `self` = self else { return }
//            if locaiton != nil {
//                self.addressView.title = locaiton
//                self.addressView.addressLab.textColor = UIColor.color(.content)
//
//            }else{
//                self.addressView.title = "请选择地区"
//                self.addressView.addressLab.textColor = UIColor(hexString: "#BCBCBC")
//            }
//        }).disposed(by: disposeBag)
        
//        contactView.textField.rx.text.share().subscribe(onNext: { [weak self](text) in
//            guard let `self` = self else { return }
//            self.reactor?.action.onNext(.updateContact(text))
//        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.message
        }.filter({
            $0 != nil
        })
        .subscribe(onNext: { [weak self](msg) in
            guard let `self` = self else { return }
            guard let message = msg else {
                return
            }
            self.view.xy_hideHUD()
            self.view.xy_show(message)
        }).disposed(by: disposeBag)
    }
    
    
    func canRelease() -> ReleaseShowInfo? {
        
        guard let photos = self.reactor?.currentState.photoModels.filter({ (model) -> Bool in
            return model.isAdd == false
        }),photos.count > 0 else {
            self.view.xy_hideHUD()
            self.view.xy_show("请添加图片")
            return nil
        }
        
        guard let content = self.textView.text,content.count > 0 else {
            self.view.xy_hideHUD()
            self.view.xy_show("请输入内容")
            return nil
        }

        let info = ReleaseShowInfo.init(content: content, photos: photos)
        return info
    }
    
    func uploadImg(token: String) {
        guard let photos = self.reactor?.currentState.photoModels else {
            return
        }
        for i in 0 ..< photos.count {
            var photo = photos[i]
            if photo.isAdd {
                continue
            }else{
                let option = QNUploadOption.init(mime: "image/jpeg",
                                                 progressHandler: { (progress, progressValue) in
                                                    print("progress",progressValue)
                                                    photo.progress = progressValue
                                                    self.reactor?.action.onNext(.updatePhotos(photo))
                                                 }, params: nil, checkCrc: true, cancellationSignal: nil)
                
                let data = photo.image?.jpegData(compressionQuality: 0.4)
                self.qnManager.put(data,
                                   key: photo.photoKey,
                                   token: token,
                                   complete: { [weak self](info, key, resp) in
                                    guard let `self` = self else { return }
                                    if let ok = info?.isOK,ok == true {
                                        photo.complete = true
                                        photo.progress = 1
                                        photo.photoUrl = (resp?["key"] as! String)
                                        self.reactor?.action.onNext(.updatePhotos(photo))
                                    }else{
                                        
                                    }
                                   }, option: option)
            }
        }
    }
    
    func showPushAlert() {

        let alert = QMUIDialogViewController.init()
        alert.title = "发布提示"
        alert.buttonHighlightedBackgroundColor = .white
        let content = ReleaseAlertView.init()
        content.clickProtocalUrl = {
            alert.hide()
            AppHelper.topNavigationController()?.pushViewController(WebPageViewController.init(url: baseUrlConfig.rawValue + UserProtocal.userAgreen.rawValue), animated: true)
        }
        alert.contentView = content
        alert.addCancelButton(withText: "取消") { (_) in
            alert.hide()
            if content.isSelected {
                UserDefaults.standard.setValue(true, forKey: ShowReleased)
            }
        }
        alert.addSubmitButton(withText: "确定发布") { (_) in
            alert.hide()
            if content.isSelected {
                UserDefaults.standard.setValue(true, forKey: ShowReleased)
            }
            self.pushBtnRelease()
        }
        alert.showWith(animated: true, completion: nil)
    }
    
    func pushBtnRelease() {
        self.resignFirst()
        self.view.xy_show(activity: "正在发布...")
        guard let info = self.canRelease(),info.photos.count > 0 else {
            return
        }
        if let token = self.reactor?.currentState.token,token.count > 0 {
            self.uploadImg(token: token)
        }else{
            self.reactor?.action.onNext(.getUploadToken)
        }
    }
}

//MARK: UIImagePickerController
extension ReleaseShowInfoController {
    
    func imageSelectPicker() {
        self.resignFirst()
        
        guard !((self.reactor?.currentState.photoModels.count ?? 0) > 6) else{
            return
        }
        qmImagePicker()
    }
    
    func qmImagePicker() {
        if QMUIAssetsManager.authorizationStatus() == .notDetermined {
            QMUIAssetsManager.requestAuthorization { [weak self](status) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.showImagePicker()

                }
            }
        }else{
            self.showImagePicker()
        }
    }
    
    func presentQMImagePicker() {
        let album = QMUIAlbumViewController.init()
        album.albumViewControllerDelegate = self
        album.contentType = .all
        album.title = "请选择图片"
        let navi = BaseNavigationController.init(rootViewController: album)
        album.pickLastAlbumGroupDirectlyIfCan()
        navi.modalPresentationStyle = .overFullScreen
        self.present(navi, animated: true, completion: nil)
    }
    
    func sendImageWithArr(imageAssets: [QMUIAsset]) {
        
        for asset in imageAssets {
            QMUIImagePickerHelper.requestImageAssetIfNeeded(asset) { [weak self](downloadStatus, error) in
                guard let `self` = self else { return }
                if downloadStatus == .downloading {
                    self.view.xy_show(activity: "从 iCloud 加载中")
                }else if downloadStatus == .succeed{
                    self.reactor?.action.onNext(.addPhoto(img: asset.originImage()))
                }else{
                    self.view.xy_show(activity: "iCloud 下载错误，请重新选图")
                }
            }
        }
    }
}
extension ReleaseShowInfoController: QMUIAlbumViewControllerDelegate,QMUIImagePickerViewControllerDelegate {
    func imagePickerViewController(for albumViewController: QMUIAlbumViewController) -> QMUIImagePickerViewController {
        let imagePicker = QMUIImagePickerViewController.init()
        imagePicker.imagePickerViewControllerDelegate = self
        imagePicker.maximumSelectImageCount = 4
        imagePicker.sendButton?.setTitle("确定", for: .normal)
        return imagePicker
        
    }
    
    func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, didFinishPickingImageWithImagesAssetArray imagesAssetArray: NSMutableArray) {
        QMUIImagePickerHelper.updateLastestAlbum(with: imagePickerViewController.assetsGroup, ablumContentType: .all, userIdentify: nil)
        self.sendImageWithArr(imageAssets: imagesAssetArray as! [QMUIAsset])
    }
    
    func imagePickerPreviewViewController(for imagePickerViewController: QMUIImagePickerViewController) -> QMUIImagePickerPreviewViewController {
        return QMUIImagePickerPreviewViewController.init()
    }
}

extension ReleaseShowInfoController: UITextFieldDelegate,YYTextViewDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.contactResignFirst(duration: 0.2)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirst()
        return true
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        let count = textView.text.count
        self.textCountLab.text = "\(count)/1000"
        if textView.text.count > 1000 {
            textView.text = textView.text.et.subStringWith(startIndex: 0, endIndex: 1000)
        }
    }
}

extension ReleaseShowInfoController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func showImagePicker() {
        let imagePicker = UIImagePickerController.init()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    ////MARK: - 图片选择代理方法
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard let image = editedImage ?? originalImage else {
            MBProgressHUD.xy_show("选择图片出错")
            return
        }
        self.reactor?.action.onNext(.addPhoto(img: image))
    }
    
}
