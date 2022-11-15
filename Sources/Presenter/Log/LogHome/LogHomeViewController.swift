//
//  LogHomeViewController.swift
//  ComeIt
//
//  Created by YeongJin Jeong on 2022/11/07.
//  Copyright (c) 2022 Try-ing. All rights reserved.
//

import Combine
import UIKit

import CancelBag
import SnapKit
import Lottie

final class LogHomeViewController: BaseViewController {
    
    var viewModel: LogHomeViewModel
    
    private var currentIndex: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.setConstellationButtonOption()
            }
        }
    }
    
    lazy var previousConstellationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.layer.cornerRadius = 9
        button.layer.borderWidth = 1
        button.layer.borderColor = .designSystem(.mainYellow)
        return button
    }()
    
    lazy var currentConstellationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = .designSystem(.mainYellow)
        return button
    }()
    
    lazy var nextConstellationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.layer.cornerRadius = 9
        button.layer.borderWidth = 1
        button.layer.borderColor = .designSystem(.mainYellow)
        return button
    }()
    
    let constellationDetailButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setImage(UIImage(named: "ic_ticket")?.resizeImageTo(size: CGSize(width: 20, height: 20)), for: .normal)
        button.titleLabel?.font = UIFont.designSystem(weight: .bold, size: ._11)
        button.setTitle("별자리 후기", for: .normal)
        button.setTitleColor(.designSystem(.mainYellow), for: .normal)
        button.semanticContentAttribute = .forceLeftToRight
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 13
        button.layer.borderWidth = 2
        button.layer.borderColor = .designSystem(.mainYellow)
        return button
    }()
    
    private var mapButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_map"), for: .normal)
        return button
    }()
    
    private var listButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_list"), for: .normal)
        return button
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let width = DeviceInfo.screenWidth
        let height = DeviceInfo.screenHeight * 0.68
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width, height: height)
        return layout
    }()
    
    private lazy var logCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(LogCollectionViewCell.self, forCellWithReuseIdentifier: LogCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    // MARK: Initializer
    init(viewModel: LogHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

extension LogHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LogCollectionViewCell.identifier, for: indexPath) as? LogCollectionViewCell else { return UICollectionViewCell() }
        cell.courseNameLabel.text = viewModel.courses[indexPath.row].courseName
        cell.dateLabel.text = viewModel.courses[indexPath.row].date
        cell.configure(with: viewModel.courses[indexPath.row].places)
        return cell
    }
}

extension LogHomeViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = self.logCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        currentIndex = Int(round(index))
        
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            currentIndex = Int(floor(index))
        } else {
            currentIndex = Int(ceil(index))
        }
        offset = CGPoint(x: CGFloat(currentIndex) * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}

// MARK: - UI
extension LogHomeViewController {
    /// View Model과 bind 합니다.
    private func bind() {
        // input
        
        // output
    }
    
    private func setUI() {
        setAttributes()
        setConstraints()
    }
    /// Attributes를 설정합니다.
    private func setAttributes() {
        logCollectionView.delegate = self
        setButtonTarget()
        setConstellationButtonOption()
    }
    
    private func setButtonTarget() {
        mapButton.addTarget(self, action: #selector(tapMapButton), for: .touchUpInside)
        listButton.addTarget(self, action: #selector(TapTestButton), for: .touchUpInside)
        previousConstellationButton.addTarget(self, action: #selector(tapPreviousConstellationButton), for: .touchUpInside)
        nextConstellationButton.addTarget(self, action: #selector(tapNextConstellationButton), for: .touchUpInside)
        constellationDetailButton.addTarget(self, action: #selector(tapConstellationDetailButton), for: .touchUpInside)
    }
    /// 화면에 그려질 View들을 추가하고 SnapKit을 사용하여 Constraints를 설정합니다.
    private func setConstraints() {
        view.addSubviews(
            mapButton,
            listButton,
            logCollectionView,
            previousConstellationButton,
            currentConstellationButton,
            nextConstellationButton,
            constellationDetailButton
        )
        
        mapButton.snp.makeConstraints { make in
            make.width.equalTo(DeviceInfo.screenWidth * 0.1102)
            make.height.equalTo(DeviceInfo.screenHeight * 0.0509)
            make.right.equalToSuperview().inset(DeviceInfo.screenWidth * 0.0512)
            make.top.equalToSuperview().inset(DeviceInfo.screenHeight * 0.0663)
        }
        listButton.snp.makeConstraints { make in
            make.width.height.equalTo(mapButton.snp.width)
            make.centerX.equalTo(mapButton.snp.centerX)
            make.top.equalTo(mapButton.snp.bottom).offset(DeviceInfo.screenWidth * 0.0512)
        }
        logCollectionView.snp.makeConstraints { make in
            make.width.equalTo(DeviceInfo.screenWidth)
            make.height.equalTo(DeviceInfo.screenHeight * 0.7)
            make.centerX.equalToSuperview()
            make.top.equalTo(listButton.snp.bottom)
        }
        currentConstellationButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(constellationDetailButton.snp.top).offset(-DeviceInfo.screenHeight * 30 / 844)
            make.width.height.equalTo(DeviceInfo.screenWidth * 50 / 390)
        }
        previousConstellationButton.snp.makeConstraints { make in
            make.width.height.equalTo(currentConstellationButton.snp.width).multipliedBy(0.6)
            make.centerY.equalTo(currentConstellationButton.snp.centerY)
            make.right.equalTo(currentConstellationButton.snp.left).offset(-DeviceInfo.screenWidth * 20 / 390)
        }
        nextConstellationButton.snp.makeConstraints { make in
            make.width.height.equalTo(currentConstellationButton.snp.width).multipliedBy(0.6)
            make.centerY.equalTo(currentConstellationButton.snp.centerY)
            make.left.equalTo(currentConstellationButton.snp.right).offset(DeviceInfo.screenWidth * 20 / 390)
        }
        constellationDetailButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(DeviceInfo.screenHeight * 105 / 844)
        }
    }
    
    @objc
    func tapMapButton() {
        
    }
    
    @objc
    func tapConstellationDetailButton() {
        viewModel.pushMyConstellationView()
    }
    
    @objc
    func TapTestButton() {
        let viewModel = LogTicketViewModel.shared
        let viewController = LogTicketViewController(viewModel: viewModel)
        viewController.view.backgroundColor = .clear
        viewController.modalPresentationStyle = .pageSheet
        self.present(viewController, animated: true)
    }
    
    @objc
    func tapPreviousConstellationButton() {
        currentIndex -= 1
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logCollectionView.scrollToItem(at: IndexPath(row: max(0, self.currentIndex), section: 0), at: .left, animated: true)
        }
    }
    
    @objc
    func tapNextConstellationButton() {
        currentIndex += 1
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logCollectionView.scrollToItem(at: IndexPath(row: min(self.currentIndex, self.viewModel.courses.count - 1), section: 0), at: .left, animated: true)
        }
    }
    
    
    /// 이전, 이후, 현재 별자리의 제약조건을 추가합니다.
    func setConstellationButtonOption() {
        previousConstellationButton.isHidden = (currentIndex == 0) ? true : false
        nextConstellationButton.isHidden = (currentIndex == viewModel.courses.count - 1) ? true : false
        
        let courses = viewModel.courses
        let currentConstellationImage = StarMaker.makeStars(places: courses[currentIndex].places)?.resizeImageTo(size: CGSize(width: 35, height: 35))
        
        let previousConstellationImage = StarMaker.makeStars(places: courses[max(currentIndex - 1, 0)].places)?.resizeImageTo(size: CGSize(width: 20, height: 20))
        
        let nextConstellationImage = StarMaker.makeStars(places: courses[min(currentIndex + 1, courses.count - 1)].places)?.resizeImageTo(size: CGSize(width: 20, height: 20))
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentConstellationButton.setImage(currentConstellationImage, for: .normal)
            self.previousConstellationButton.setImage(previousConstellationImage, for: .normal)
            self.nextConstellationButton.setImage(nextConstellationImage, for: .normal)
        }
    }
}
