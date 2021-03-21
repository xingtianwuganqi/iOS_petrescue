//
//  ShowPageMainViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import UIKit

class ShowPageMainViewController: ContentPageViewController {

    lazy var segmentControl : UISegmentedControl = {
        let segment = UISegmentedControl.init(items: ["秀宠","话题"])
        segment.tintColor = .white
        segment.layer.borderColor = rgb(238,238,238).cgColor
        segment.layer.masksToBounds = true
        segment.layer.cornerRadius = 8
        segment.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = .white
        } else {
            segment.backgroundColor = rgb(238,238,238)
        }
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([NSMutableAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([NSMutableAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segment.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        return segment
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.titleView = self.segmentControl
        self.segmentControl.addTarget(self, action: #selector(segmentControlClickAction), for: .valueChanged)
        self.delegate = self
    }
    
    @objc func segmentControlClickAction(segment: UISegmentedControl) {
        self.showPage(index: segment.selectedSegmentIndex, animated: true)
    }
}
extension ShowPageMainViewController: ContentPageViewControllerDelegate {
    func didChangePageWithIndex(index: Int, controller: ContentPageViewController) {
        self.segmentControl.selectedSegmentIndex = index
    }
}
