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
import RxSwift

private var internalCache = [String: Data]()

public enum RxURLSessionError: Error {
  case unknown
  case invalidResponse(response: URLResponse)
  case requestFailed(response: HTTPURLResponse, data: Data?)
  case deserializationFailed
}

extension Reactive where Base: URLSession {
  func response(request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
    return Observable.create { observer in
      // content goes here
      let task = self.base.dataTask(with: request) { data, response, error in
        guard let response = response,
              let data = data else {
          observer.onError(error ?? RxURLSessionError.unknown)
          return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
          observer.onError(RxURLSessionError.invalidResponse(response: response))
          return
        }

        observer.onNext((httpResponse, data))
        observer.onCompleted()
      }
      
      task.resume()

      return Disposables.create { task.cancel() }
    }
  }

  func data(request: URLRequest) -> Observable<Data> {
    if let url = request.url?.absoluteString,
       let data = internalCache[url] {
      return Observable.just(data)
    }

    return response(request: request).cache().map { response, data -> Data in
      guard 200 ..< 300 ~= response.statusCode else {
        throw RxURLSessionError.requestFailed(response: response, data: data)
      }

      return data
    }
  }

  func string(request: URLRequest) -> Observable<String> {
    return data(request: request).map { data in
      return String(data: data, encoding: .utf8) ?? ""
    }
  }

  func json(request: URLRequest) -> Observable<Any> {
    return data(request: request).map { data in
      return try JSONSerialization.jsonObject(with: data)
    }
  }

  func decodable<D: Decodable>(request: URLRequest, type: D.Type) -> Observable<D> {
    return data(request: request).map { data in
      let decoder = JSONDecoder()
      return try decoder.decode(type, from: data)
    }
  }

  func image(request: URLRequest) -> Observable<UIImage> {
    return data(request: request).map { data in
      return UIImage(data: data) ?? UIImage()
    }
  }
}

extension ObservableType where Element == (HTTPURLResponse, Data) {
  func cache() -> Observable<Element> {
    return self.do(onNext: { response, data in
      guard let url = response.url?.absoluteString,
            200 ..< 300 ~= response.statusCode else { return }

      internalCache[url] = data
    })
  }
}
