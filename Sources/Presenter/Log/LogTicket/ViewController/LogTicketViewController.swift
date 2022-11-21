//
//  LogTicketViewController.swift
//  MatStar
//
//  Created by 김승창 on 2022/10/12.
//  Modified by 정영진 on 2022/10/21
//  Copyright (c) 2022 Try-ing. All rights reserved.
//

import Combine
import UIKit

import CancelBag
import SnapKit

final class LogTicketViewController: BaseViewController {
    
    private var didTapLikeButton: Bool = false
    
    var viewModel: LogTicketViewModel?
    
    private var logTicketView = LogTicketView()
    /// View Model과 bind 합니다.
    private func bind() {
        // input
        
        // output
    }
    
    init(viewModel: LogTicketViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        addButtonTarget()
    }
}
// MARK: - UI
extension LogTicketViewController {
    
    private func setUI() {
        super.backgroundView.isHidden = true
        configureTicketView()
        setLayout()
    }
    
    private func configureTicketView() {
        guard let viewModel = viewModel else { return }
        logTicketView.dateLabel.text = viewModel.data?.date
        logTicketView.numberLabel.text = "\(viewModel.data!.id)번째"
        logTicketView.courseNameLabel.text = viewModel.data?.title
        logTicketView.fromLabel.text = viewModel.data?.planet
        logTicketView.imageUrl = viewModel.data!.images
        logTicketView.bodyTextView.text = viewModel.data?.body
    }
    /// 화면에 그려질 View들을 추가하고 SnapKit을 사용하여 Constraints를 설정합니다.
    private func setLayout() {
        view.addSubview(logTicketView)
        logTicketView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(DeviceInfo.screenWidth * 0.8974358974)
            make.height.equalTo(DeviceInfo.screenHeight * 0.8163507109)
        }
    }
    
    private func addButtonTarget() {
        logTicketView.likebutton.addTarget(self, action: #selector(tapLikeButton), for: .touchUpInside)
        logTicketView.flopButton.addTarget(self, action: #selector(tapFlopButton), for: .touchUpInside)
    }
    
    @objc
    func tapLikeButton() {
        print("like Button Tapped")
        switch didTapLikeButton {
        case true:
            logTicketView.likebutton.setImage(UIImage(named: "unlike_image"), for: .normal)
            didTapLikeButton.toggle()
        case false:
            logTicketView.likebutton.setImage(UIImage(named: "like_image"), for: .normal)
            didTapLikeButton.toggle()
        }
        viewModel?.tapLikeButton()
    }
    
    @objc
    func tapFlopButton() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        // MARK: Card Flip Animation
        UIView.transition(with: logTicketView, duration: 0.7, options: transitionOptions, animations: {
            self.logTicketView.isHidden = true
        })
        
        UIView.transition(with: logTicketView, duration: 0.7, options: transitionOptions, animations: {
            self.logTicketView.isHidden = false
        })
        
        viewModel?.tapFlopButton()
        
    }
}
