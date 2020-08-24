import Foundation
import RxSwift

example(of: "toArray") {
  let disposeBag = DisposeBag()
  
  // 1
  Observable.of("A", "B", "C")
    // 2
    .toArray()
    .subscribe(onSuccess: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "map") {
  let disposeBag = DisposeBag()
  
  // 1
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut
  
  // 2
  Observable<Int>.of(123, 4, 56)
    // 3
    .map {
      formatter.string(for: $0) ?? ""
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
  let disposeBag = DisposeBag()
  
  // 1
  Observable.of(1, 2, 3, 4, 5, 6)
    // 2
    .enumerated()
    // 3
    .map { index, integer in
      index > 2 ? integer * 2 : integer
    }
    // 4
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}

example(of: "compactMap") {
  let disposeBag = DisposeBag()

  // 1
  Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
    // 2
    .compactMap { $0 }
    // 3
    .toArray()
    // 4
    .map { $0.joined(separator: " ") }
    // 5
    .subscribe(onSuccess: {
      print($0)
    })
    .disposed(by: disposeBag)
}

struct Student {
  let score: BehaviorSubject<Int>
}

example(of: "flatMap") {
  let disposeBag = DisposeBag()
  
  // 1
  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))
  
  // 2
  let student = PublishSubject<Student>()
  
  // 3
  student
    .flatMap {
      $0.score
    }
    // 4
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  student.onNext(laura)
  
  laura.score.onNext(85)
  
  student.onNext(charlotte)
  
  laura.score.onNext(95)
  
  charlotte.score.onNext(100)
}

example(of: "flatMapLatest") {
  let disposeBag = DisposeBag()
  
  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))
  
  let student = PublishSubject<Student>()
  
  student
    .flatMapLatest {
      $0.score
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  student.onNext(laura)
  
  laura.score.onNext(85)
  
  student.onNext(charlotte)
  
  // 1
  laura.score.onNext(95)
  
  charlotte.score.onNext(100)
}

example(of: "materialize and dematerialize") {
  // 1
  enum MyError: Error {
    case anError
  }
  
  let disposeBag = DisposeBag()
  
  // 2
  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 100))
  
  let student = BehaviorSubject(value: laura)
  
  // 1
  let studentScore = student
    .flatMapLatest {
      $0.score.materialize()
  }
  
  // 2
  studentScore
    // 1
    .filter {
      guard $0.error == nil else {
        print($0.error!)
        return false
      }
      
      return true
    }
    // 2
    .dematerialize()
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
  
  // 3
  laura.score.onNext(85)
  
  laura.score.onError(MyError.anError)
  
  laura.score.onNext(90)
  
  // 4
  student.onNext(charlotte)
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
