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

import Foundation
import Cocoa
import RxSwift
import RxCocoa
import Then

class ListPeopleViewController: NSViewController {
  @IBOutlet var tableView: NSTableView!
  @IBOutlet weak var messageView: NSTextField!

  private let bag = DisposeBag()
  fileprivate var viewModel: ListPeopleViewModel!
  fileprivate var navigator: Navigator!

  private var lastSelectedRow = -1

  static func createWith(navigator: Navigator, storyboard: NSStoryboard, viewModel: ListPeopleViewModel) -> ListPeopleViewController {
    return storyboard.instantiateViewController(ofType: ListPeopleViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bindUI()
  }

  func bindUI() {
    //show tweets in table view
    viewModel.people.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)

    //show message when no account available
  }

  @IBAction func tableViewDidSelectRow(sender: NSTableView) {
    if sender.selectedRow >= 0, sender.selectedRow != lastSelectedRow, let user = viewModel.people.value?[sender.selectedRow] {
      navigator.show(segue: .personTimeline(viewModel.account, username: user.username), sender: self)
      lastSelectedRow = sender.selectedRow
    } else {
      navigator.show(segue: .listTimeline(viewModel.account, viewModel.list), sender: self)
      sender.deselectAll(nil)
      lastSelectedRow = -1
    }
  }
}

extension ListPeopleViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return viewModel.people.value?.count ?? 0
  }
}

extension ListPeopleViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let user = viewModel.people.value![row]
    return tableView.dequeueCell(ofType: UserCellView.self).then {cell in
      cell.update(with: user)
    }
  }
}
