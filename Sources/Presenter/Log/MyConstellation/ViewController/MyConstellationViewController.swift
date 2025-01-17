//
//  MyConstellationViewController.swift
//  ComeIt
//
//  Created by YeongJin Jeong on 2022/11/08.
//  Copyright (c) 2022 Try-ing. All rights reserved.
//

import Combine
import UIKit

import CancelBag
import SnapKit

final class MyConstellationViewController: BaseViewController {

    var viewModel: MyConstellationViewModel
    
    weak var homeView: LogHomeViewController?
    
    lazy var myConstellationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (DeviceInfo.screenWidth - 40 - 10) / 2, height: 225)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // MARK: Initializer
    init(viewModel: MyConstellationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life-Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - UI
extension MyConstellationViewController {
    private func setUI() {
        view.addSubview(myConstellationCollectionView)
        myConstellationCollectionView.register(MyConstellationCollectionViewCell.self, forCellWithReuseIdentifier: MyConstellationCollectionViewCell.cellId)
        myConstellationCollectionView.delegate = self
        myConstellationCollectionView.dataSource = self
        myConstellationCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: NavigationBar Setting
    func setNavigationBar() {
        // MARK: 네비게이션 title의 font변경
        self.title = "내 별자리"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.gmarksans(weight: .bold, size: ._15)]
        
        // MARK: 네비게이션 rightButton, leftButton커스텀
        let dissmissButtonConfigure = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .default)
        let mapButtonConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)
        
        let mapButton = UIButton(type: .custom)
        mapButton.setImage(UIImage(systemName: "map", withConfiguration: mapButtonConfigure), for: .normal)
        mapButton.tintColor = .white
        mapButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        mapButton.addTarget(self, action: #selector(tapMapButton), for: .touchUpInside)
        
        let dismissButton = UIButton(type: .custom)
        dismissButton.setImage( UIImage(systemName: "chevron.backward", withConfiguration: dissmissButtonConfigure), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        dismissButton.addTarget(self, action: #selector(tapDismissButton), for: .touchUpInside)
        
        let rightBarButton = UIBarButtonItem(customView: mapButton)
        let leftBarButton = UIBarButtonItem(customView: dismissButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // MARK: 네비게이션이 너무 위에 붙어있어서 height증가
        self.additionalSafeAreaInsets.top = 20
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: Button Action
    @objc
    func tapDismissButton() {
        viewModel.tapDismissButton()
    }
    
    @objc
    func tapMapButton() {
        viewModel.pushLogMapViewController()
    }
}

// MARK: CollectionView - DataSource
extension MyConstellationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        homeView?.currentIndex = selectedIndex
        homeView?.logCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .left, animated: true)
        homeView?.setConstellationButtonOption()
        viewModel.popToCurrentConstellation()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyConstellationCollectionViewCell.cellId, for: indexPath) as? MyConstellationCollectionViewCell else { return UICollectionViewCell() }
        cell.course = viewModel.courses[indexPath.row]
        
        return cell
    }
}
