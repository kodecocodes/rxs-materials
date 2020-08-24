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

class InfoView: UIView {

  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!

  private static var sharedView: InfoView!

  static func loadFromNib() -> InfoView {
    let nibName = "\(self)".split{$0 == "."}.map(String.init).last!
    let nib = UINib(nibName: nibName, bundle: nil)
    return nib.instantiate(withOwner: self, options: nil).first as! InfoView
  }

  static func showIn(viewController: UIViewController, message: String) {

    var displayVC = viewController

    if let tabController = viewController as? UITabBarController {
      displayVC = tabController.selectedViewController ?? viewController
    }

    if sharedView == nil {
      sharedView = loadFromNib()

      sharedView.layer.masksToBounds = false
      sharedView.layer.shadowColor = UIColor.darkGray.cgColor
      sharedView.layer.shadowOpacity = 1
      sharedView.layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    sharedView.textLabel.text = message

    if sharedView?.superview == nil {
      let y = displayVC.view.frame.height - sharedView.frame.size.height - 12
      sharedView.frame = CGRect(x: 12, y: y, width: displayVC.view.frame.size.width - 24, height: sharedView.frame.size.height)
      sharedView.alpha = 0.0

      displayVC.view.addSubview(sharedView)
      sharedView.fadeIn()

      // this call needs to be counter balanced on fadeOut [1]
      sharedView.perform(#selector(fadeOut), with: nil, afterDelay: 3.0)
    }
  }

  @IBAction func closePressed(_ sender: UIButton) {
    fadeOut()
  }


  // MARK: Animations
  func fadeIn() {
    UIView.animate(withDuration: 0.33, animations: {
      self.alpha = 1.0
    })
  }

  @objc func fadeOut() {

    // [1] Counter balance previous perfom:with:afterDelay
    NSObject.cancelPreviousPerformRequests(withTarget: self)

    UIView.animate(withDuration: 0.33, animations: {
      self.alpha = 0.0
    }, completion: { _ in
      self.removeFromSuperview()
    })
  }
}
