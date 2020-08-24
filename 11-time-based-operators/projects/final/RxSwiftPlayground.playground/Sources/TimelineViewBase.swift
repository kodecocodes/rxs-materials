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
import os

public struct TimelineEvent  {
  public enum EventType {
    case next(String)
    case completed(Bool)
    case error
  }
  public let date: Date
  public let event: EventType
  fileprivate var view: UIView? = nil
  
  public static func next(_ text: String) -> TimelineEvent {
    return TimelineEvent(.next(text))
  }
  public static func next(_ value: Int) -> TimelineEvent {
    return TimelineEvent(.next(String(value)))
  }
  public static func completed(_ keepRunning: Bool = false) -> TimelineEvent {
    return TimelineEvent(.completed(keepRunning))
  }
  public static func error() -> TimelineEvent {
    return TimelineEvent(.error)
  }
  
  var text: String {
    switch self.event {
    case .next(let s):
      return s
    case .completed(_):
      return "C"
    case .error:
      return "X"
    }
  }
  
  init(_ event: EventType) {
    // lose some precision to show nearly-simultaneous items at same position
    let ti = round(Date().timeIntervalSinceReferenceDate * 10) / 10
    date = Date(timeIntervalSinceReferenceDate: ti)
    self.event = event
  }
}

let BOX_WIDTH: CGFloat = 40

open class TimelineViewBase : UIView {
  var timeSpan: Double = 10.0
  var events: [TimelineEvent] = []
  var displayLink: CADisplayLink?
  
  public convenience init(width: CGFloat, height: CGFloat) {
    self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not supported here")
  }

  public func setup() {
    self.backgroundColor = .white
    self.widthAnchor.constraint(equalToConstant: CGFloat(frame.width)).isActive = true
    self.heightAnchor.constraint(equalToConstant: CGFloat(frame.height)).isActive = true
  }
  
  public func add(_ event: TimelineEvent) {
    let label = UILabel()
    label.isHidden = true
    label.textAlignment = .center
    label.text = event.text
    
    switch event.event {
    case .next(_):
      label.backgroundColor = .green

    case .completed(let keepRunning):
      label.backgroundColor = .black
      label.textColor = .white
      if !keepRunning {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.detachDisplayLink() }
      }
    
    case .error:
      label.backgroundColor = .red
      label.textColor = .white
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.detachDisplayLink() }
    }
    
    label.layer.borderColor = UIColor.lightGray.cgColor
    label.layer.borderWidth = 1.0
    label.sizeToFit()
    
    var r = label.frame
    r.size.width = BOX_WIDTH
    label.frame = r
    
    var newEvent = event
    newEvent.view = label
    events.append(newEvent)
    addSubview(label)
  }
  
  func detachDisplayLink() {
    displayLink?.remove(from: RunLoop.main, forMode: .common)
    displayLink = nil
  }
  
  override open func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    self.backgroundColor = .white
    if newSuperview == nil {
      detachDisplayLink()
    } else {
      displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
      displayLink?.add(to: RunLoop.main, forMode: .common)
    }
  }
  
  override open func draw(_ rect: CGRect) {
    UIColor.lightGray.set()
    UIRectFrame(CGRect(x: 0, y: rect.height/2, width: rect.width, height: 1))
    super.draw(rect)
  }
  
  @objc func update(_ sender: CADisplayLink) {
    let now = Date()
    let start = now.addingTimeInterval(-11)
    let width = frame.width
    let increment = (width - BOX_WIDTH) / 10.0
    events
      .filter { $0.date < start }
      .forEach { $0.view?.removeFromSuperview() }
    var eventsAt = [Int:Int]()
    events = events.filter { $0.date >= start }
    events.forEach { box in
      if let view = box.view {
        var r = view.frame
        let interval = CGFloat(box.date.timeIntervalSince(now))
        let origin = Int(width - BOX_WIDTH + interval * increment)
        let count = (eventsAt[origin] ?? 0) + 1
        eventsAt[origin] = count
        r.origin.x = CGFloat(origin)
        r.origin.y = (frame.height - r.height) / 2 + CGFloat(12 * (count - 1))
        view.frame = r
        view.isHidden = false
        //print("[\(eventsAt[origin]!)]: \"\(box.text)\" x=\(origin) y=\(r.origin.y)")
      }
    }
  }
}
