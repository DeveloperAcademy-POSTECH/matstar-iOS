//
//  SearchTestViewModel.swift
//  MatStar
//
//  Created by 김승창 on 2022/10/12.
//  Copyright (c) 2022 Try-ing. All rights reserved.
//

import Combine
import UIKit

final class SearchTestViewModel: BaseViewModel {
    
    @Published var currentCategory: CoursePlanet = .course
    @Published var infos = []
    
    @Published private var infos1 = []
    @Published private var infos2 = []
    
    var cancelbag2 = Set<AnyCancellable>()
    
    override init() {
        super.init()
        bind()
    }
    
    func changeTo(_ coursePlanet: CoursePlanet) {
        guard self.currentCategory != coursePlanet else { return }
        infos = []
        currentCategory = coursePlanet
    }
    
    private func bind() {
        
        $currentCategory
            .sink { coursePlanet in
                switch coursePlanet {
                case .course:
                    self.fetchInfos()
                case .planet:
                    self.fetchInfos2()
                }
            }
            .store(in: &cancelbag2)
        
        
        Publishers.Merge($infos2, $infos1)
            .sink { i1 in
                self.infos = i1
            }
            .store(in: &cancelbag2)
            
    }
}

extension SearchTestViewModel {
    func fetchInfos() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            //TODO: Operator을 통한 처리가 될듯
            guard self.currentCategory == .course else { return }
            self.infos1 = [Info(planetImageString: "MyPlanetImage", planetNameString: "한규행성", timeString: "32분 전", locationString: "한규", isFollow: false, isLike: true, imageURLStrings: ["picture_sample", "picture_sample", "picture_sample", "picture_sample", "picture_sample", "picture_sample"]), Info(planetImageString: "MyPlanetImage", planetNameString: "한규행성", timeString: "32분 전", locationString: "한규", isFollow: true, isLike: false, imageURLStrings: ["picture_sample", "picture_sample", "picture_sample", "picture_sample", "picture_sample", "picture_sample"]), Info(planetImageString: "MyPlanetImage", planetNameString: "한규행성", timeString: "32분 전", locationString: "한규", isFollow: true, isLike: false, imageURLStrings: ["picture_sample", "picture_sample", "picture_sample", "picture_sample", "picture_sample", "picture_sample"])]
        }
    }
    
    func fetchInfos2() {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            guard self.currentCategory == .planet else { return }
            self.infos2 = [Info2(planetImageString: "MyPlanetImage", planetNameString: "한규행성", isFollow: true, hosts: ["이한규", "엠마왔쓴"]),Info2(planetImageString: "MyPlanetImage", planetNameString: "한규행성", isFollow: true, hosts: ["이한규", "엠마왔쓴"])]
        }
        
    }
}
struct Info {
    //TODO: TestViewController 바꾸고 올리기
    let planetImageString: String
    let planetNameString: String
    let timeString: String
    let locationString: String
    let isFollow: Bool
    let isLike: Bool
    let imageURLStrings: [String]
}

struct Info2 {
    //TODO: TestViewController 바꾸고 올리기
    let planetImageString: String
    let planetNameString: String
    let isFollow: Bool
    let hosts: [String]
}
