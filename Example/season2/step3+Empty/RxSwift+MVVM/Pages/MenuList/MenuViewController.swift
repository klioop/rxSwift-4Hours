//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    
    let cellId = "MenuItemTableViewCell"
    
    let viewModel = MenuListViewModel()
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        
        viewModel.menuObservable
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)){
                index, item, cell in // deque
                
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                cell.onChange = { [weak self] increase in
                    self?.viewModel.changeCount(item: item, increase: increase)
                }
                
            }.disposed(by: disposeBag)
        
        
        viewModel.itemsCount
            .map{ "\($0)" }
            .catchErrorJustReturn("")
            .observeOn(MainScheduler.instance)
            .bind(to: itemCountLabel.rx.text) // 이것과 subscribe(onNext: { self.itemCountlabel.text = $0 } ) 은 같은 동작을 함, sugar
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
//            .scan(0, accumulator: +)
            .map { $0.currencyKR() }
            .asDriver(onErrorJustReturn: "")
            .drive(itemCountLabel.rx.text) // drive 는 main thread 에서 돌아감
//            .subscribe(onNext: {
//                self.totalPrice.text = $0
//            })
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
        viewModel.clearAllItemSelections()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
//        viewModel.menuObservable.onNext([
//            Menu(name: "Changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3)),
//            Menu(name: "Changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3)),
//            Menu(name: "Changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3))
//        ])
        
        viewModel.onOrder()
    }
}

//extension MenuViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.menus.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//
//        let menu = viewModel.menus[indexPath.row]
//
//
//        return cell
//    }
//}
