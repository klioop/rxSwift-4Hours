//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by klioop on 2021/04/11.
//  Copyright © 2021 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    
    lazy var menuObservable = BehaviorRelay<[Menu]>(value: []) // BehaviorSubject needs an initial value, here []
    // Relay 는 subject 와 같지만 error 가 나도 끊어지지 않는다.
    
    lazy var itemsCount = menuObservable.map{ $0.map{$0.count}.reduce(0, +) }
    lazy var totalPrice = menuObservable.map{
        $0.map{ $0.price * $0.count }.reduce(0, +)
    }
    
    init() {
//        let menus : [Menu] = [
//            Menu(id: 0, name: "menu 1", price: 100, count: 0),
//            Menu(id: 1, name: "menu 2", price: 200, count: 1),
//            Menu(id: 2, name: "menu 3", price: 300, count: 2),
//            Menu(id: 3, name: "menu 4", price: 400, count: 3),
//        ]
        
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { index, item in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .bind(to: menuObservable)
        
//        menuObservable.onNext(menus)
        
    }
    
    func clearAllItemSelections() {
       _ = menuObservable
            .map{ menus in
                return menus.map{ m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
    
    func changeCount(item: Menu, increase: Int) {
        _ = menuObservable
            .map { menus in
                 menus.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id, name: m.name, price: m.price, count: max(0, m.count + increase))
                    } else {
                        return Menu(id: m.id, name: m.name, price: m.price, count: m.count)
                    }
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
    
    func onOrder() {
        
    }
    
}
