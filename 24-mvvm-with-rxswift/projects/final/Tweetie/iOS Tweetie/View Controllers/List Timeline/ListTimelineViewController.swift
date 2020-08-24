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

import UIKit
import RxSwift
import Then
import Alamofire
import RxRealmDataSources

class ListTimelineViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var messageView: UIView!

  private let bag = DisposeBag()
  fileprivate var viewModel: ListTimelineViewModel!
  fileprivate var navigator: Navigator!

  static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: ListTimelineViewModel) -> ListTimelineViewController {
    return storyboard.instantiateViewController(ofType: ListTimelineViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 90
    tableView.rowHeight = UITableView.automaticDimension

    title = "@\(viewModel.list.username)/\(viewModel.list.slug)"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: nil, action: nil)
    
    bindUI()
  }

  func bindUI() {
    // Bind button to the people view controller
    navigationItem.rightBarButtonItem!.rx.tap
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.navigator.show(segue: .listPeople(self.viewModel.account, self.viewModel.list), sender: self)
      })
      .disposed(by: bag)
    
    // Show tweets in table view
    let dataSource = RxTableViewRealmDataSource<Tweet>(cellIdentifier:
      "TweetCellView", cellType: TweetCellView.self) { cell, _, tweet in
        cell.update(with: tweet)
    }
    viewModel.tweets
      .bind(to: tableView.rx.realmChanges(dataSource))
      .disposed(by: bag)

    // Show message when no account available
    viewModel.loggedIn
      .drive(messageView.rx.isHidden)
      .disposed(by: bag)
  }
}
