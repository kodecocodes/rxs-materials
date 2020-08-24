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
import UIKit

public func colorFromDecimalRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
  return UIColor(
    red: red / 255.0,
    green: green / 255.0,
    blue: blue / 255.0,
    alpha: alpha
  )
}

extension UIColor {

  // MARK: Custom Defined Colors

  /// Dark Blue Aztec
  class var aztec: UIColor {
    return colorFromDecimalRGB(38, 39, 41)
  }

  /// Light Cream Color
  class var lightCream: UIColor {
    return colorFromDecimalRGB(232, 234, 221)
  }

  /// Cream Color
  class var cream: UIColor {
    return colorFromDecimalRGB(229, 231, 218)
  }

  /// Swirl Color
  class var swirl: UIColor {
    return colorFromDecimalRGB(228, 221, 202)
  }

  /// Travertine Color
  class var travertine: UIColor {
    return colorFromDecimalRGB(214, 206, 195)
  }

  /// Green
  class var ufoGreen: UIColor {
    return colorFromDecimalRGB(64, 186, 145)
  }

  class var textGrey: UIColor {
    return colorFromDecimalRGB(146, 146, 146)
  }

}
