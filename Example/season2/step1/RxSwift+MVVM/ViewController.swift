//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"


//class Observable<T> {
//    private let task: (@escaping (T) -> Void) -> Void
//
//    init(task: @escaping (@escaping (T) -> Void) -> Void) {
//        self.task = task
//    }
//
//    func subscribe(_ f: @escaping (T) -> Void) {
//        task(f)
//    }
//}

// RxSwift 의 용도는 비동기적으로 발생하는 데이터를 completion 으로 처리하지 않고 return 값으로 전달하는 거다.
// 그 값을 사용할 때는, 나중에오면 (subscribe) method 를 호출하면 된다.

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    var disposeBag = DisposeBag() // 멤버변수

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        disposable?.dispose() // 다운로드 받고 있는 도중에 뷰에서 나가도 다운로드를 취소시킴
//    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    // observable 의 생명주기: create -> subscribe -> next 로 데이터 전달 -> completed 되면서 사라진다
    // 1. Create
    // 2. Subscribe - Observable 은 create 됐을 때가 아니라 subscribe 됐을 때 실행된다.
    // 3. onNext
    // ---- end ----
    // 4. onCompleted / onError
    // 5. Disposed - 캔슬되면 dispose 됨
    // 동작이 끝난 observable 은 재사용 불가능하다.
    
    // 함수가 optional 함수일 경우 escaping 이 default
    func downloadJson(_ url: String) -> Observable<String> {
        // 1. 비동기로 생기는 데이터를 Observable 로 감싸서 리턴하는방법
        return Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }
                
                emitter.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create() {
                task.cancel()
            }
        }
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted()
//                }
//            }
//
//            return Disposables.create()
//        }
//
    }
    
    func obserVableJust() -> Observable<String?> {
        return Observable.from(["Hello", "World"]) // 데이터를 하나 보낼 때도 원래는 아래와 같이 보내야함 -> 귀차늠 -> just 탄생, 배열자체를 보내줌, sugar api
    //    return Observable.from(["hello","world"]) // 배열의 element 를 하나씩 보내줌, from
        //    return Observable.create() { emitter in
    //        emitter.onNext("Hello World")
    //        emitter.onCompleted()
    //
    //        return Disposables.create()
    //    }
    }

    // MARK: SYNC
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        
        Observable.zip(jsonObservable, helloObservable, resultSelector: { (jsonElement, helloElement) in
            helloElement + "\n"  + jsonElement
        })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                self.editView.text = result
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
        .disposed(by: disposeBag) // disposable bag 에 넣는 sugar
        
//        disposable.insert(d) // Disposable bag 에 넣음
        
//        _ = downloadJson(MEMBER_LIST_URL) // just, from 은 생성 operator
//            .map { json in json?.count ?? 0} // operator
//            .filter{ cnt in cnt > 0 } // operator
//            .map { "\($0)"} // operator
//            .observeOn(MainScheduler.instance) // dispatchqueue.main.aysnc 를 없내는 sugar api : observable 과 subscribe 사이에 데이터가 전달되는 중간에 데이터를 바꾸는 sugar 들을 operator 라고 함
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // 위치랑 상관없이 처음 스레드를 결정함
//            .subscribe(onNext: { json in
//                self.editView.text = json
//                self.setVisibleWithAnimation(self.activityIndicator, false)
//            })
        
        
        // 2. Observable 로 오는 데이터를 받아서 처리하는 방법
//        let observable = downloadJson(MEMBER_LIST_URL)
//        obserVableJust().subscribe { event in
//            switch event {
//            case .next(let t):
//                print(t)
//                break
//
//            case .error(let err):
//                break
//
//            case .completed:
//                break
//            }
//        }
        
//        obserVableJust().subscribe(onNext: { print($0) } ) // subscribe sugar api
        
//        let disposable = observable.subscribe{ event in // subscribe() - 데이터를 받아옴, subscribe 를 호출하면 disposble 이 리턴됨.
//            switch event {
//            case .next(let json):
//                break
//
//            case .error(let err):
//                break
//
//            case .completed:
//                break
//            }
            
//            disposable.dispose() - disposable 은 dispose() 를 호출해서 취소시킬 수 있다.
        }
        
        
//        let ob = downloadJson(MEMBER_LIST_URL)
//
//        let dispose = ob.subscribe { event in
//            switch event {
//            case let .next(json):
//
//                DispatchQueue.main.async {
//                    self.editView.text = json
//                    self.setVisibleWithAnimation(self.activityIndicator, false)
//                }
//
//            case .completed:
//                break
//            case .error:
//                break
//            }
//        }
//        dispose.dispose()
        
        // 한번 dispose 된 실행된(completed or error) ob 는 재사용 불가능, ob 를 쓰려면 다시 subscribe 해야함
    
}



