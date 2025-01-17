//
//  LogHomeViewController.swift
//  ComeIt
//
//  Created by YeongJin Jeong on 2022/11/07.
//  Copyright (c) 2022 Try-ing. All rights reserved.
//
import Combine
import CoreMotion
import UIKit

import CancelBag
import SnapKit
import Lottie

final class LogHomeViewController: BaseViewController {
    
    var viewModel: LogHomeViewModel
    
    var currentIndex: Int = 0
    
    private lazy var mediumStarBackgroundView = MediumStarBackgroundView(
        frame: CGRect(
            x: 0,
            y: 0,
            width: view.frame.width + 30,
            height: view.frame.height + 30
        )
    )
    
    lazy var previousConstellationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.alpha = 0.7
        button.clipsToBounds = true
        button.layer.cornerRadius = 9
        button.isHidden = true
        return button
    }()
    
    lazy var currentConstellationButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 0.5
        button.layer.borderColor = .designSystem(.mainYellow)
        return button
    }()
    
    lazy var nextConstellationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.alpha = 0.7
        button.clipsToBounds = true
        button.layer.cornerRadius = 9
        button.isHidden = true
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
    
    lazy var logCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(LogCollectionViewCell.self, forCellWithReuseIdentifier: LogCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private lazy var logHomeEmptyView = LogHomeEmptyView()
    
    private lazy var logHomeEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 행성에 별자리가 없어요!"
        label.font = .designSystem(weight: .regular, size: ._13)
        return label
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
        self.setGyroMotion()
        self.navigationController?.isNavigationBarHidden = true
        Task {
            try await viewModel.fetchConstellation()
            DispatchQueue.main.async {
                self.logCollectionView.reloadData()
                self.setConstellationButtonOption()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        viewModel.$courses.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.setEmptyView()
            }
            .cancel(with: cancelBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

extension LogHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // MARK: 수정
        return viewModel.courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LogCollectionViewCell.identifier, for: indexPath) as? LogCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configure(with: viewModel.courses[indexPath.row])
        cell.courseNameButton.addTarget(self, action: #selector(tapConstellationDetailButton), for: .touchUpInside)
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setConstellationButtonOption()
    }
}

// MARK: - UI
extension LogHomeViewController {
    /// View Model과 bind 합니다.
    private func bind() {
        viewModel.$courses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.logCollectionView.reloadData()
            }
            .cancel(with: cancelBag)
        
        viewModel.$alarmIndex
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] index in
                self?.logCollectionView.scrollToItem(at: IndexPath(row: max(0, index), section: 0), at: .left, animated: true)
                guard let course = self?.viewModel.courses[index] else { return }
                self?.viewModel.presentTicketView(
                    course: course,
                    selectedCourseIndex: index,
                    rootViewState: RootViewState.LogHome
                )
            }
            .cancel(with: cancelBag)
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
    
    private func setEmptyView() {
        mapButton.isHidden = viewModel.courses.isEmpty ? true : false
        listButton.isHidden = viewModel.courses.isEmpty ? true : false
        logCollectionView.isHidden = viewModel.courses.isEmpty ? true : false
        logHomeEmptyView.isHidden = viewModel.courses.isEmpty ? false : true
        logHomeEmptyLabel.isHidden = viewModel.courses.isEmpty ? false : true
    }
    
    private func setButtonTarget() {
        mapButton.addTarget(self, action: #selector(tapMapButton), for: .touchUpInside)
        listButton.addTarget(self, action: #selector(tapListButton), for: .touchUpInside)
        previousConstellationButton.addTarget(self, action: #selector(tapPreviousConstellationButton), for: .touchUpInside)
        nextConstellationButton.addTarget(self, action: #selector(tapNextConstellationButton), for: .touchUpInside)
    }
    /// 화면에 그려질 View들을 추가하고 SnapKit을 사용하여 Constraints를 설정합니다.
    private func setConstraints() {
        
        view.addSubviews(
            mediumStarBackgroundView,
            mapButton,
            listButton,
            logCollectionView,
            previousConstellationButton,
            currentConstellationButton,
            nextConstellationButton,
            logHomeEmptyView,
            logHomeEmptyLabel
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
            make.bottom.equalToSuperview().inset(DeviceInfo.screenHeight * 135 / 844)
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
        
        logHomeEmptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(85)
        }
        
        logHomeEmptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(logHomeEmptyView.snp.top).offset(-20)
        }
    }
    
    private func setGyroMotion() {
        motionManager = CMMotionManager()
        
        motionManager?.gyroUpdateInterval = 0.01
        motionManager?.startGyroUpdates(to: .main, withHandler: { [weak self] data, _ in
            guard let self = self,
                  let data = data else { return }
            
            let offsetRate = 0.2
            self.lastXOffset += data.rotationRate.x * offsetRate
            self.lastYOffset += data.rotationRate.y * offsetRate
            
            let backgroundOffsetRate = 0.3
            let mediumStarBackgroundOffsetRate = 1.0
            let constellationOffsetRate = 2.0
            
            if abs(self.lastYOffset) < 50 {
                self.backgroundView.center.x = DeviceInfo.screenWidth / 2 + self.lastYOffset * backgroundOffsetRate
                self.mediumStarBackgroundView.center.x = DeviceInfo.screenWidth / 2 + self.lastYOffset * mediumStarBackgroundOffsetRate
                
                if let cell = self.logCollectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? LogCollectionViewCell {
                    cell.constellationView.center.x = (DeviceInfo.screenWidth / 2) - (self.lastYOffset * constellationOffsetRate)
                }
            }
            
            if abs(self.lastXOffset) < 50 {
                self.backgroundView.center.y = DeviceInfo.screenHeight / 2 + self.lastXOffset * backgroundOffsetRate
                self.mediumStarBackgroundView.center.y = DeviceInfo.screenHeight / 2 + self.lastXOffset * mediumStarBackgroundOffsetRate
                
                if let cell = self.logCollectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? LogCollectionViewCell {
                    cell.constellationView.center.y = (cell.center.y) - (self.lastXOffset * constellationOffsetRate) - 80.0
                }
            }
        })
    }
    
    @objc
    func tapConstellationDetailButton() {
        viewModel.presentTicketView(course: viewModel.courses[currentIndex], selectedCourseIndex: currentIndex, rootViewState: RootViewState.LogHome)
    }
    
    @objc
    func tapMapButton() {
        viewModel.pushLogMapViewController(courses: viewModel.courses)
    }
    
    @objc
    func tapListButton() {
        viewModel.pushMyConstellationView(courses: viewModel.courses, homeView: self)
    }
    
    @objc
    func tapPreviousConstellationButton() {
        currentIndex -= 1
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logCollectionView.scrollToItem(at: IndexPath(row: max(0, self.currentIndex), section: 0), at: .left, animated: true)
            self.setConstellationButtonOption()
        }
    }
    
    @objc
    func tapNextConstellationButton() {
        currentIndex += 1
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logCollectionView.scrollToItem(at: IndexPath(row: min(self.currentIndex, self.viewModel.courses.count - 1), section: 0), at: .left, animated: true)
            self.setConstellationButtonOption()
        }
    }
    
    /// 이전, 이후, 현재 별자리의 제약조건을 추가합니다.
    func setConstellationButtonOption() {
        
        let courses = viewModel.courses
        
        if courses.isEmpty {
            previousConstellationButton.isHidden = true
            currentConstellationButton.isHidden = true
            nextConstellationButton.isHidden = true
            return
        } else {
            previousConstellationButton.isHidden = (currentIndex == 0) ? true : false
            currentConstellationButton.isHidden = false
            nextConstellationButton.isHidden = (currentIndex == viewModel.courses.count - 1) ? true : false
        }
        
        let currentConstellationImage = StarMaker.makeStars(places: courses[currentIndex].places)?.resizeImageTo(size: CGSize(width: 22, height: 22))
        
        let previousConstellationImage = StarMaker.makeStars(places: courses[max(currentIndex - 1, 0)].places)?.resizeImageTo(size: CGSize(width: 13, height: 13))
        
        let nextConstellationImage = StarMaker.makeStars(places: courses[min(currentIndex + 1, courses.count - 1)].places)?.resizeImageTo(size: CGSize(width: 13, height: 13))
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentConstellationButton.setImage(currentConstellationImage, for: .normal)
            self.previousConstellationButton.setImage(previousConstellationImage, for: .normal)
            self.nextConstellationButton.setImage(nextConstellationImage, for: .normal)
        }
    }
}
