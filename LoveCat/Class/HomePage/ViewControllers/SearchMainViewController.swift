//
//  SourchMainViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import UIKit
import ReactorKit
class SearchMainViewController: BaseViewController,View {

    typealias Reactor = SearchMainReactor
    
    lazy var labsView: SearchLabViewController = {
        let vc = SearchLabViewController.init(navi: self.naviService)
        return vc
    }()
    
    lazy var resultView: SearchResultViewController = {
        let vc = SearchResultViewController.init(navi: self.naviService)
        return vc
    }()
    
    lazy var searchText: SearchNavigationTitleView = {
        let textView = SearchNavigationTitleView.init()
        textView.frame = CGRect(x: -15, y: 0, width: SCREEN_WIDTH - 50, height: 40)
        return textView
    }()
    
    override init(navi: NavigatorServiceType) {
        super.init(navi: navi)
        defer {
            self.reactor = SearchMainReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationItem.titleView = searchText
        searchText.delegate = self
        
        labsView.buttonClickBlock = { [weak self] btnText in
            guard let `self` = self else { return }
            self.beginSearch(keyWord: btnText)
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.addChild(labsView)
        self.addChild(resultView)
        self.didMove(toParent: labsView)
        self.didMove(toParent: resultView)
        self.view.addSubview(labsView.view)
        self.view.addSubview(resultView.view)
        labsView.view.frame = self.view.frame
        resultView.view.frame = self.view.frame
        resultView.view.isHidden = true
        labsView.view.isHidden = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchText.textField.resignFirstResponder()
    }

    func beginSearch(keyWord: String?) {
        guard let text = keyWord,text.count > 0 else {
            return
        }
        self.resultView.reactor?.action.onNext(.clearData)
        self.searchText.textField.text = text
        self.resultView.reactor?.action.onNext(.beginSearch(text))
        self.searchText.textField.resignFirstResponder()
        self.reactor?.action.onNext(.showLabsView(false))
    }
}
extension SearchMainViewController {
    func bind(reactor: SearchMainReactor) {
        rx.viewDidLoad.subscribe(onNext: {
            reactor.action.onNext(.showLabsView(true))
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.showLabs
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self] show in
            guard let `self` = self else { return }
            if show  {
                self.labsView.view.isHidden = false
                self.resultView.view.isHidden = true
            }else{
                self.labsView.view.isHidden = true
                self.resultView.view.isHidden = false
            }
        }).disposed(by: disposeBag)
    }
}

extension SearchMainViewController: SearchNavigationTitleViewDelegate {
    func textDidChange(_ searchView: SearchNavigationTitleView) {
        if searchView.textField.text?.count == 0 {
            self.resultView.reactor?.action.onNext(.clearData)
        }
    }
    
    func shouldReturn(_ searchView: SearchNavigationTitleView) -> Bool {
        self.beginSearch(keyWord: searchView.textField.text)
        return true
    }
    
    func didBeginEditing(_ searchView: SearchNavigationTitleView) {
        if self.labsView.view.isHidden {
            self.reactor?.action.onNext(.showLabsView(true))
        }
    }
    
    func clickCancelAction(_ searchView: SearchNavigationTitleView) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func clickClearText(_ searchView: SearchNavigationTitleView) {
        self.resultView.reactor?.action.onNext(.clearData)
    }
}
