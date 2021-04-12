//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by klioop on 2021/04/11.
//  Copyright © 2021 iamchiwon. All rights reserved.
//

import Foundation

// Model : View 를 위한 Model, ViewModel
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
