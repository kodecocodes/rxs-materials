/// Copyright (c) 2019 Razeware LLC
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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

extension CLLocationManager: HasDelegate {}

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {

  weak public private(set) var locationManager: CLLocationManager?

  public init(locationManager: ParentObject) {
    self.locationManager = locationManager
    super.init(parentObject: locationManager,
               delegateProxy: RxCLLocationManagerDelegateProxy.self)
  }

  static func registerKnownImplementations() {
    register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
  }
}

public extension Reactive where Base: CLLocationManager {
  var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
    RxCLLocationManagerDelegateProxy.proxy(for: base)
  }

  var didUpdateLocations: Observable<[CLLocation]> {
    delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
      .map { parameters in
        parameters[1] as! [CLLocation]
      }
  }

  var authorizationStatus: Observable<CLAuthorizationStatus> {
    delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
      .map { parameters in
        CLAuthorizationStatus(rawValue: parameters[1] as! Int32)!
      }
      .startWith(CLLocationManager.authorizationStatus())
  }

  func getCurrentLocation() -> Observable<CLLocation> {
    let location = authorizationStatus
      .filter { $0 == .authorizedWhenInUse || $0 == .authorizedAlways }
      .flatMap { _ in self.didUpdateLocations.compactMap(\.first) }
      .take(1)
      .do(onDispose: { [weak base] in base?.stopUpdatingLocation() })

    base.requestWhenInUseAuthorization()
    base.startUpdatingLocation()
    return location
  }
}
