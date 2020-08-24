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
import Accounts
import RxSwift
import RxCocoa
import Unbox
import RealmSwift
import RxBlocking

@testable import Tweetie

class PersonTimelineViewModelTests: XCTestCase {

  private func createViewModel(_ account: Driver<TwitterAccount.AccountStatus>) -> PersonTimelineViewModel {
    return PersonTimelineViewModel(
      account: account,
      username: TestData.listId.username,
      apiType: TwitterTestAPI.self)
  }

  func test_whenInitialized_storesInitParams() {
    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    XCTAssertNotNil(viewModel.account)
    XCTAssertEqual(viewModel.username, TestData.listId.username)
  }

//  func test_whenInitialized_bindsTweets() {
//    TwitterTestAPI.reset()
//
//    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
//    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))
//
//    let allTweets = TestData.tweetsJSON
//
//    DispatchQueue.main.async {
//      accountSubject.onNext(.authorized(AccessToken()))
//      TwitterTestAPI.objects.onNext(allTweets)
//    }
//
//    let emitted = try! viewModel.tweets.asObservable().take(1).toBlocking(timeout: 1).toArray()
//    XCTAssertEqual(emitted[0].count, 3)
//    XCTAssertEqual(emitted[0][0].id, 1)
//    XCTAssertEqual(emitted[0][1].id, 2)
//    XCTAssertEqual(emitted[0][2].id, 3)
//  }
}
