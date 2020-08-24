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

import SystemConfiguration
import Foundation
import RxSwift
import RxCocoa

enum Reachability {
  case offline
  case online
  case unknown

  init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
    let connectionRequired = flags.contains(.connectionRequired)
    let isReachable = flags.contains(.reachable)

    if !connectionRequired && isReachable {
      self = .online
    } else {
      self = .offline
    }
  }
}

class RxReachability {
  static let shared = RxReachability()

  private init() {}

  private static var _status = BehaviorRelay<Reachability>(value: .unknown)
  var status: Observable<Reachability> {
    return RxReachability._status.asObservable().distinctUntilChanged()
  }

  class func reachabilityStatus() -> Reachability {
    return RxReachability._status.value
  }

  func isOnline() -> Bool {
    switch RxReachability._status.value {
    case .online:
      return true
    case .offline, .unknown:
      return false
    }
  }

  private var reachability: SCNetworkReachability?

  func startMonitor(_ host: String) -> Bool {
    guard reachability != nil else {
      return true
    }

    var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)

    if let reachability = SCNetworkReachabilityCreateWithName(nil, host) {
      SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
        let status = Reachability(reachabilityFlags: flags)
        RxReachability._status.accept(status)
      }, &context)

      SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
      self.reachability = reachability

      return true
    }

    return true
  }

  func stopMonitor() {
    if let _reachability = reachability {
      SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue);
      reachability = nil
    }
  }

}
