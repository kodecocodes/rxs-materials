import Foundation
import RxSwift
import RxRelay

example(of: "PublishSubject") {
  let subject = PublishSubject<String>()
  subject.on(.next("Is anyone listening?"))

  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print(string)
    })

  subject.on(.next("1"))
  subject.onNext("2")

  let subscriptionTwo = subject
    .subscribe { event in
      print("2)", event.element ?? event)
  }

  subject.onNext("3")

  subscriptionOne.dispose()

  subject.onNext("4")

  // 1
  subject.onCompleted()

  // 2
  subject.onNext("5")

  // 3
  subscriptionTwo.dispose()

  let disposeBag = DisposeBag()

  // 4
  subject
    .subscribe {
      print("3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

  subject.onNext("?")
}

// 1
enum MyError: Error {
  case anError
}

// 2
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
  print(label, (event.element ?? event.error) ?? event)
}

// 3
example(of: "BehaviorSubject") {
  // 4
  let subject = BehaviorSubject(value: "Initial value")
  let disposeBag = DisposeBag()
  subject.onNext("X")

  subject
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)

  // 1
  subject.onError(MyError.anError)

  // 2
  subject
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
  // 1
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  let disposeBag = DisposeBag()

  // 2
  subject.onNext("1")
  subject.onNext("2")
  subject.onNext("3")

  // 3
  subject
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)

  subject
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)

  subject.onNext("4")
  subject.onError(MyError.anError)
  subject.dispose()

  subject
    .subscribe {
      print(label: "3)", event: $0)
    }
    .disposed(by: disposeBag)
}

example(of: "PublishRelay") {
  let relay = PublishRelay<String>()

  let disposeBag = DisposeBag()

  relay.accept("Knock knock, anyone home?")

  relay
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)

  relay.accept("1")
}

example(of: "BehaviorRelay") {
  // 1
  let relay = BehaviorRelay(value: "Initial value")
  let disposeBag = DisposeBag()

  // 2
  relay.accept("New initial value")

  // 3
  relay
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)

  // 1
  relay.accept("1")

  // 2
  relay
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)

  // 3
  relay.accept("2")

  print(relay.value)
}

/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
