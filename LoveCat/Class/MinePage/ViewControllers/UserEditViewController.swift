//
//  UserEditViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/11.
//

import UIKit
import ReactorKit
import RxDataSources
import MBProgressHUD

class UserEditViewController: BaseViewController,View {
    
    typealias Reactor = UserEditViewReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(SettingHeadImgCell.self, forCellReuseIdentifier: "SettingHeadImgCell")
        tableview.register(SettingEditCell.self, forCellReuseIdentifier: "SettingEditCell")
        return tableview
    }()
    
    lazy var saveBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("保存", for: .normal)
        button.setTitleColor(UIColor.color(.system), for: .normal)
        button.titleLabel?.font = UIFont.et.fontSize(.medium, .content)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        return button
    }()
    
    lazy var qnManager : QNUploadManager = {
        let config = QNConfiguration.build { (config) in
            config?.setZone(QNFixedZone.zone1())
        }
        let manager = QNUploadManager.init(configuration: config)
        return manager!
    }()
    
    lazy var jumpBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("跳过", for: .normal)
        button.setTitleColor(UIColor.color(.system), for: .normal)
        button.titleLabel?.font = UIFont.et.fontSize(.medium, .content)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        return button
    }()
    var fromType: Int = 0
    init(navi: NavigatorServiceType,type: Int = 0) {
        super.init(navi: navi)
        self.dataSource = self.dataSourceFactory()
        self.fromType = type
        defer {
            self.reactor = UserEditViewReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<UserEditSection>!
    private func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<UserEditSection>
    {
        return RxTableViewSectionedReloadDataSource<UserEditSection>.init { (dataSource, tableView, indexPath, items) -> UITableViewCell in
            switch items {
            case .editHeadImg(let model):
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingHeadImgCell", for: indexPath) as! SettingHeadImgCell
                cell.model = model
                cell.headImgClick = { [weak self] in
                    guard let `self` = self else { return }
                    self.imageSelectPicker()
                }
                return cell
            case .editItem(let reac):
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingEditCell", for: indexPath) as! SettingEditCell
                cell.model = reac
                cell.textChanged = { [weak self] text in
                    guard let `self` = self else { return }
                    if let text = text,text.count > 0 {
                        self.reactor?.action.onNext(.changeNickName(text))
                    }
                }
                return cell
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "编辑个人信息"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView:saveBtn)
        
        if fromType == 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: jumpBtn)
            jumpBtn.rx.tap.subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.navigationController?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func resignFirst() {
        self.view.endEditing(true)
    }
    
}
extension UserEditViewController: UITableViewDelegate {
    func bind(reactor: UserEditViewReactor) {
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.section.bind(to: tableview.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.loadData
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        saveBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.resignFirst()
            
            guard let nickName = self.reactor?.currentState.nickName,nickName.count > 0 else {
                MBProgressHUD.xy_show("请输入昵称")
                return
            }
            
            if reactor.currentState.photoModel != nil { // 改变了头像
                if let token = self.reactor?.currentState.token,token.count > 0 {
                    self.uploadImg(token: token)
                }else{
                    self.reactor?.action.onNext(.getUploadToken)
                }
            }else{
                self.reactor?.action.onNext(.uploadUserInfo(avator: reactor.currentState.avator, username: nickName))
            }
            
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.token
        }.distinctUntilChanged()
        .filter {
            $0 != nil
        }.subscribe(onNext: { (token) in
            guard let token = token else {
                MBProgressHUD.xy_hide()
                return
            }
            self.uploadImg(token: token)
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
            guard let nickName = self.reactor?.currentState.nickName,nickName.count > 0 else {
                MBProgressHUD.xy_show("请输入昵称")
                return
            }
            self.reactor?.action.onNext(.uploadUserInfo(avator: reactor.currentState.avator, username: nickName))
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { loading in
            if loading {
                MBProgressHUD.xy_show(activity: nil)
            }else{
                MBProgressHUD.xy_hide()
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.newInfo
        }.filter {
            $0 != nil
        }.subscribe(onNext: { [weak self] infoModel in
            guard let `self` = self else { return }
            guard let info = infoModel else {
                return
            }
            UserManager.shared.upLoadUserInfo(info)
            MBProgressHUD.xy_show("更新成功")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if self.fromType == 1 {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.errorMsg
        }.filter {
            $0 != nil
        }.subscribe(onNext: { message in
            if let msg = message {
                MBProgressHUD.xy_show(msg)
            }
        }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 150
            default:
                return 50
            }
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func uploadImg(token: String) {
        
        guard var photo = self.reactor?.currentState.photoModel else {
            return
        }
        // 更新图片
        let option = QNUploadOption.init(mime: "image/jpeg",
                                         progressHandler: { (progress, progressValue) in
                                            print("progress",progressValue)
                                            photo.progress = progressValue
                                         }, params: nil, checkCrc: true, cancellationSignal: nil)
        
        let data = photo.image?.jpegData(compressionQuality: 0.2)
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

extension UserEditViewController: QMUIAlbumViewControllerDelegate,QMUIImagePickerViewControllerDelegate {
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
    
    func imageSelectPicker() {
        self.resignFirst()
        
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
        self.present(navi, animated: true, completion: nil)
    }
    
    func sendImageWithArr(imageAssets: [QMUIAsset]) {
        
        for asset in imageAssets {
            QMUIImagePickerHelper.requestImageAssetIfNeeded(asset) { [weak self](downloadStatus, error) in
                guard let `self` = self else { return }
                if downloadStatus == .downloading {
                    MBProgressHUD.xy_show(activity: "从 iCloud 加载中")
                }else if downloadStatus == .succeed{
                    MBProgressHUD.xy_hide()
                    self.reactor?.action.onNext(.addPhoto(asset.originImage()))
                }else{
                    MBProgressHUD.xy_hide()
                    MBProgressHUD.xy_show(activity: "iCloud 下载错误，请重新选图")
                }
            }
        }
    }
    
}
extension UserEditViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
        self.reactor?.action.onNext(.addPhoto(image))
    }
    
}
