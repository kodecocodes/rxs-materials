import Foundation
import RxSwift

example(of: "ignoreElements") {
  // 1
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()

  // 2
  strikes
    .ignoreElements()
    .subscribe { _ in
      print("You're out!")
    }
    .disposed(by: disposeBag)

  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onCompleted()
}

example(of: "elementAt") {
  // 1
  let strikes = PublishSubject<String>()
  let disposeBag = DisposeBag()

  // 2
  strikes
    .elementAt(2)

    .subscribe(onNext: { _ in
      print("You're out!")
    })
    .disposed(by: disposeBag)

  strikes.onNext("X")
  strikes.onNext("X")
  strikes.onNext("X")
}

example(of: "filter") {
  let disposeBag = DisposeBag()
  // 1
  Observable.of(1, 2, 3, 4, 5, 6)
    // 2
    .filter { $0.isMultiple(of: 2) }
    // 3
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "skip") {
  let disposeBag = DisposeBag()
  // 1
  Observable.of("A", "B", "C", "D", "E", "F")
    // 2
    .skip(3)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "skipWhile") {
  let disposeBag = DisposeBag()

  // 1
  Observable.of(2, 2, 3, 4, 4)
    // 2
    .skipWhile { $0.isMultiple(of: 2) }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "skipUntil") {
  let disposeBag = DisposeBag()
  // 1
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()
  // 2
  subject
    .skipUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)

  subject.onNext("A")
  subject.onNext("B")
  trigger.onNext("X")
  subject.onNext("C")
}

example(of: "take") {
  let disposeBag = DisposeBag()

  // 1
  Observable.of(1, 2, 3, 4, 5, 6)
    // 2
    .take(3)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "takeWhile") {
  let disposeBag = DisposeBag()

  // 1
  Observable.of(2, 2, 4, 4, 6, 6)
    // 2
    .enumerated()
    // 3
    .takeWhile { index, integer in
      // 4
      integer.isMultiple(of: 2) && index < 3
    }
    // 5
    .map(\.element)
    // 6
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "takeUntil") {
  let disposeBag = DisposeBag()

  Observable.of(1, 2, 3, 4, 5)
    .takeUntil(.exclusive) { $0.isMultiple(of: 4) }
    .subscribe(onNext: {
      print($0)
    })
  .disposed(by: disposeBag)
}

example(of: "takeUntil trigger") {
  let disposeBag = DisposeBag()
  // 1
  let subject = PublishSubject<String>()
  let trigger = PublishSubject<String>()

  // 2
  subject
    .takeUntil(trigger)
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)

  // 3
  subject.onNext("1")
  subject.onNext("2")
  trigger.onNext("X")
  subject.onNext("3")
}

example(of: "distinctUntilChanged") {
  let disposeBag = DisposeBag()
  // 1
  Observable.of("A", "A", "B", "B", "A")
    // 2
    .distinctUntilChanged()
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
  let disposeBag = DisposeBag()

  // 1
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut

  // 2
  Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    // 3
    .distinctUntilChanged { a, b in
      // 4
      guard
        let aWords = formatter
          .string(from: a)?
          .components(separatedBy: " "),
        let bWords = formatter
          .string(from: b)?
          .components(separatedBy: " ")
        else {
          return false
      }

      var containsMatch = false

      // 5
      for aWord in aWords where bWords.contains(aWord) {
        containsMatch = true
        break
      }

      return containsMatch
    }
    // 4
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
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
