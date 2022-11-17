//
//  AlarmInterface.swift
//  ComeIt
//
//  Created by Hankyu Lee on 2022/11/16.
//  Copyright © 2022 Try-ing. All rights reserved.
//

import Foundation
import Combine

protocol AlarmInterface {
    func fetchAlarms() -> AnyPublisher<[AlarmEntity], Error>
    func readAlarm(id: Int)
    func removeAllAlarms()
}