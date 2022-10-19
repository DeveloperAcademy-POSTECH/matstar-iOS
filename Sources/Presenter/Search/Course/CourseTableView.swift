//
//  CourseTableView.swift
//  MatStar
//
//  Created by Hankyu Lee on 2022/10/12.
//  Copyright © 2022 Try-ing. All rights reserved.
//

import UIKit
import CancelBag
import Combine

class CourseTableView: UITableView {
    var cancelBag = CancelBag()
    var cancelBag2 = Set<AnyCancellable>()
    var searchViewModel: SearchTestViewModel?

    convenience init(viewModel: SearchTestViewModel?) {
        self.init(frame: .zero, style: .plain)
        self.searchViewModel = viewModel
        bind()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        register(CourseTableViewCell.self, forCellReuseIdentifier: CourseTableViewCell.identifier)
        register(PlanetTableViewCell.self, forCellReuseIdentifier: PlanetTableViewCell.identifier)
        backgroundColor = .black
        separatorColor = .clear
        showsVerticalScrollIndicator = false
        dataSource = self
    }
    
    private func bind() {
        guard let viewModel = searchViewModel else { return }
//        viewModel.$currentCategory
//            .flatMap { _ in
//                viewModel.$infos
//            }
//            .sink { acccccc in
//                print("Rr")
//                let kkkk = acccccc
//            }
//            .cancel(with: cancelBag)
        
//        viewModel.$currentCategory
//            .sink { _ in
//                print("view에서 currentCategory바뀜")
//                print("category change")
//                
//            }
//            .store(in: &cancelBag2)
        
        viewModel.$infos
            .receive(on: DispatchQueue.main)
            .sink { infos in
                print(infos)
                self.reloadData()
            }
            .store(in: &cancelBag2)
//        viewModel.$infos1
//            .receive(on: DispatchQueue.main)
//            .sink { infos in
//                self.reloadData()
//            }
//            .store(in: &cancelBag2)
//
//        viewModel.$infos2
//            .receive(on: DispatchQueue.main)
//            .sink { infos in
//                self.reloadData()
//            }
//            .store(in: &cancelBag2)
        
//        viewModel.$infos
//            .receive(on: DispatchQueue.main)
//            .sink { infos in
//                self.reloadData()
//            }
//            .store(in: &cancelBag2)
    }
    
}

extension CourseTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = searchViewModel else { return 0 }
        return viewModel.infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = searchViewModel,
              let courseTableCell = tableView.dequeueReusableCell(withIdentifier: CourseTableViewCell.identifier, for: indexPath) as? CourseTableViewCell,
              let planetTableCell = tableView.dequeueReusableCell(withIdentifier: PlanetTableViewCell.identifier, for: indexPath) as? PlanetTableViewCell
        else { return UITableViewCell() }
        
        switch viewModel.currentCategory {
        case .course:
            courseTableCell.info = viewModel.infos[indexPath.row] as? Info
            return courseTableCell
        case .planet:
            planetTableCell.info = viewModel.infos[indexPath.row] as? Info2
            return planetTableCell
        }
    }
    
}
