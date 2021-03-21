//
//  WebPageViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/14.
//

import UIKit
import WebKit
class WebPageViewController: UIViewController {

    lazy var webView : WKWebView = {
        let web = WKWebView.init()
        return web
    }()
    
    lazy var progress: UIProgressView = {
        let progress = UIProgressView.init()
        progress.progressTintColor = UIColor.color(.system)
        progress.trackTintColor =  .white
        progress.isHidden = true
        return progress
    }()
    fileprivate var webUrl : String = ""
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        webUrl = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        self.view.addSubview(progress)
        self.progress.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        self.webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        loadWKWebView()
    }

    func loadWKWebView() {
        guard let weburl = URL(string: self.webUrl) else {
            return
        }
        self.webView.load(URLRequest(url: weburl))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let value = self.webView.estimatedProgress
            self.progress.setProgress(Float(value), animated: true)
        }else if keyPath == "title" {
            self.title = self.webView.title
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "title")
    }
}

extension WebPageViewController: WKUIDelegate,WKNavigationDelegate {
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.progress.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.progress.isHidden = true
        }
    }
}
