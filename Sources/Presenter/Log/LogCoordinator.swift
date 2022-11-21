//
//  LogCoordinator.swift
//  MatStar
//
//  Created by 김승창 on 2022/10/12.
//  Copyright © 2022 Try-ing. All rights reserved.
//

import UIKit

final class LogCoordinator: Coordinator,
                            MyConstellationViewCoordinating,
                            TicketViewCoodinating,
                            LogMapViewCoordinating,
                            Popable {
    
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) { self.navigationController = navigationController }
    
    // MARK: Coordinating functions
    func start() {
        guard let navigationController = navigationController else { return }
        let viewModel = LogHomeViewModel(coordinator: self)
        let viewController = LogHomeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    // TicketView로 전환
    func presentTicketViewController(course: CourseEntity, currentIndex: Int) {
        let viewModel = LogTicketViewModel(coordinator: self, course: course, currentIndex: currentIndex)
        let viewController = LogTicketViewController(viewModel: viewModel)
        navigationController?.present(viewController, animated: true)
    }
    
    func pushMyConstellationViewController(courses: [CourseEntity]) {
        let viewModel = MyConstellationViewModel(coordinator: self, courses: courses)
        let viewController = MyConstellationViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func pushLogMapViewController(courses: [CourseEntity]) {
        let viewModel = LogMapViewModel(coordinator: self, courses: courses)
        let viewController = LogMapViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
