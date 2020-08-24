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
import RxCocoa

class ViewController : UIViewController {
  @IBOutlet private var hexTextField: UITextField!
  @IBOutlet private var rgbTextField: UITextField!
  @IBOutlet private var colorNameTextField: UITextField!
  @IBOutlet private var textFields: [UITextField]!
  @IBOutlet private var zeroButton: UIButton!
  @IBOutlet private var buttons: [UIButton]!
  
  private let disposeBag = DisposeBag()
  private let viewModel = ViewModel()
  private let backgroundColor = PublishSubject<UIColor>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    
    guard let textField = self.hexTextField else { return }
    
    textField.rx.text.orEmpty
      .bind(to: viewModel.hexString)
      .disposed(by: disposeBag)
    
    for button in buttons {
      button.rx.tap
        .bind {
          var shouldUpdate = false
          
          switch button.titleLabel!.text! {
          case "⊗":
            textField.text = "#"
            shouldUpdate = true
          case "←" where textField.text!.count > 1:
            textField.text = String(textField.text!.dropLast())
            shouldUpdate = true
          case "←":
            break
          case _ where textField.text!.count < 7:
            textField.text!.append(button.titleLabel!.text!)
            shouldUpdate = true
          default:
            break
          }
          
          if shouldUpdate {
            textField.sendActions(for: .valueChanged)
          }
        }
        .disposed(by: disposeBag)
    }
    
    viewModel.color
      .drive(onNext: { [unowned self] color in
        UIView.animate(withDuration: 0.2) {
          self.view.backgroundColor = color
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.rgb
      .map { "\($0.0), \($0.1), \($0.2)" }
      .drive(rgbTextField.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.colorName
      .drive(colorNameTextField.rx.text)
      .disposed(by: disposeBag)
  }
  
  func configureUI() {
    textFields.forEach {
      $0.layer.shadowOpacity = 1.0
      $0.layer.shadowRadius = 0.0
      $0.layer.shadowColor = UIColor.lightGray.cgColor
      $0.layer.shadowOffset = CGSize(width: -1, height: -1)
    }
  }
}
