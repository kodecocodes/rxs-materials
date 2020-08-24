import Foundation
import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

example(of: "startWith") {
  // 1
  let numbers = Observable.of(2, 3, 4)

  // 2
  let observable = numbers.startWith(1)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "Observable.concat") {
  // 1
  let first = Observable.of(1, 2, 3)
  let second = Observable.of(4, 5, 6)

  // 2
  let observable = Observable.concat([first, second])

  observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "concat") {
  let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
  let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")

  let observable = germanCities.concat(spanishCities)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "concatMap") {
  // 1
  let sequences = [
    "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
    "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
  ]

  // 2
  let observable = Observable.of("German cities", "Spanish cities")
      .concatMap { country in sequences[country] ?? .empty() }

  // 3
  _ = observable.subscribe(onNext: { string in
    print(string)
  })
}

example(of: "merge") {
  // 1
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()

  // 2
  let source = Observable.of(left.asObservable(), right.asObservable())

  // 3
  let observable = source.merge()
  _ = observable.subscribe(onNext: { value in
    print(value)
  })

  // 4
  var leftValues = ["Berlin", "Munich", "Frankfurt"]
  var rightValues = ["Madrid", "Barcelona", "Valencia"]
  repeat {
    switch Bool.random() {
    case true where !leftValues.isEmpty:
      left.onNext("Left:  " + leftValues.removeFirst())
    case false where !rightValues.isEmpty:
      right.onNext("Right: " + rightValues.removeFirst())
    default:
      break
    }
  } while !leftValues.isEmpty || !rightValues.isEmpty

  left.onCompleted()
  right.onCompleted()
}

example(of: "combineLatest") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()

  // 1
  let observable = Observable.combineLatest([left, right]) {
    strings in strings.joined(separator: " ")
  }

  _ = observable.subscribe(onNext: { value in
    print(value)
  })

  // 2
  print("> Sending a value to Left")
  left.onNext("Hello,")
  print("> Sending a value to Right")
  right.onNext("world")
  print("> Sending another value to Right")
  right.onNext("RxSwift")
  print("> Sending another value to Left")
  left.onNext("Have a good day,")

  left.onCompleted()
  right.onCompleted()
}

example(of: "combine user choice and value") {
  let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
  let dates = Observable.of(Date())

  let observable = Observable.combineLatest(choice, dates) {
    format, when -> String in
    let formatter = DateFormatter()
    formatter.dateStyle = format
    return formatter.string(from: when)
  }

  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "zip") {
  enum Weather {
    case cloudy
    case sunny
  }

  let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
  let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")

  let observable = Observable.zip(left, right) { weather, city in
    return "It's \(weather) in \(city)"
  }

  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "withLatestFrom") {
  // 1
  let button = PublishSubject<Void>()
  let textField = PublishSubject<String>()

  // 2
  let observable = button.withLatestFrom(textField)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })

  // 3
  textField.onNext("Par")
  textField.onNext("Pari")
  textField.onNext("Paris")
  button.onNext(())
  button.onNext(())
}

example(of: "amb") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()

  // 1
  let observable = left.amb(right)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })

  // 2
  left.onNext("Lisbon")
  right.onNext("Copenhagen")
  left.onNext("London")
  left.onNext("Madrid")
  right.onNext("Vienna")

  left.onCompleted()
  right.onCompleted()
}

example(of: "switchLatest") {
  // 1
  let one = PublishSubject<String>()
  let two = PublishSubject<String>()
  let three = PublishSubject<String>()

  let source = PublishSubject<Observable<String>>()

  // 2
  let observable = source.switchLatest()
  let disposable = observable.subscribe(onNext: { value in
    print(value)
  })

  // 3
  source.onNext(one)
  one.onNext("Some text from sequence one")
  two.onNext("Some text from sequence two")

  source.onNext(two)
  two.onNext("More text from sequence two")
  one.onNext("and also from sequence one")

  source.onNext(three)
  two.onNext("Why don't you see me?")
  one.onNext("I'm alone, help me")
  three.onNext("Hey it's three. I win.")

  source.onNext(one)
  one.onNext("Nope. It's me, one!")

  disposable.dispose()
}

example(of: "reduce") {
  let source = Observable.of(1, 3, 5, 7, 9)

  // 1
  let observable = source.reduce(0) { summary, newValue in
    return summary + newValue
  }

  _ = observable.subscribe(onNext: { value in
    print(value)
  })
}

example(of: "scan") {
  let source = Observable.of(1, 3, 5, 7, 9)

  let observable = source.scan(0, accumulator: +)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
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
