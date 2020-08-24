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

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import OHHTTPStubs

@testable import iGif

class iGifTests: XCTestCase {
  let obj = ["array": ["foo", "bar"], "foo": "bar"] as [String: AnyHashable]
  let request = URLRequest(url: URL(string: "http://raywenderlich.com")!)
  let errorRequest = URLRequest(url: URL(string: "http://rw.com")!)
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    stub(condition: isHost("raywenderlich.com")) { _ in
      return HTTPStubsResponse(jsonObject: self.obj, statusCode: 200, headers: nil)
    }
    stub(condition: isHost("rw.com")) { _ in
      return HTTPStubsResponse(error: RxURLSessionError.unknown)
    }
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    HTTPStubs.removeAllStubs()
  }

  func testData() {
    let observable = URLSession.shared.rx.data(request: self.request)
    expect(observable.toBlocking().firstOrNil()).toNot(beNil())
  }

  func testString() {
    let observable = URLSession.shared.rx.string(request: self.request)
    let result = observable.toBlocking().firstOrNil() ?? ""

    let option1 = "{\"array\":[\"foo\",\"bar\"],\"foo\":\"bar\"}"
    let option2 = "{\"foo\":\"bar\",\"array\":[\"foo\",\"bar\"]}"

    expect(result == option1 || result == option2).to(beTrue())
  }

  func testJSON() {
    let observable = URLSession.shared.rx.json(request: self.request)
    let obj = self.obj
    let result = observable.toBlocking().firstOrNil()
    expect(result as? [String: AnyHashable]) == obj
  }

  func testError() {
    var erroredCorrectly = false
    let observable = URLSession.shared.rx.json(request: self.errorRequest)
    do {
      _ = try observable.toBlocking().first()
      assertionFailure()
    } catch RxURLSessionError.unknown {
      erroredCorrectly = true
    } catch {
      assertionFailure()
    }
    expect(erroredCorrectly) == true
  }
}

extension BlockingObservable {
  func firstOrNil() -> Element? {
    do {
      return try first()
    } catch {
      return nil
    }
  }
}
