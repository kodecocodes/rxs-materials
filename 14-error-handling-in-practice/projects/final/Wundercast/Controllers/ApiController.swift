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
import RxCocoa
import CoreLocation
import MapKit

class ApiController {
  struct Weather: Decodable {
    let cityName: String
    let temperature: Int
    let humidity: Int
    let icon: String
    let coordinate: CLLocationCoordinate2D

    static let empty = Weather(
      cityName: "Unknown",
      temperature: -1000,
      humidity: 0,
      icon: iconNameToChar(icon: "e"),
      coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
    )

    static let dummy = Weather(
      cityName: "RxCity",
      temperature: 20,
      humidity: 90,
      icon: iconNameToChar(icon: "01d"),
      coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
    )

    init(cityName: String,
         temperature: Int,
         humidity: Int,
         icon: String,
         coordinate: CLLocationCoordinate2D) {
      self.cityName = cityName
      self.temperature = temperature
      self.humidity = humidity
      self.icon = icon
      self.coordinate = coordinate
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      cityName = try values.decode(String.self, forKey: .cityName)
      let info = try values.decode([AdditionalInfo].self, forKey: .weather)
      icon = iconNameToChar(icon: info.first?.icon ?? "")

      let mainInfo = try values.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
      temperature = Int(try mainInfo.decode(Double.self, forKey: .temp))
      humidity = try mainInfo.decode(Int.self, forKey: .humidity)
      let coordinate = try values.decode(Coordinate.self, forKey: .coordinate)
      self.coordinate = CLLocationCoordinate2D(latitude: coordinate.lat, longitude: coordinate.lon)
    }

    enum CodingKeys: String, CodingKey {
      case cityName = "name"
      case main
      case weather
      case coordinate = "coord"
    }

    enum MainKeys: String, CodingKey {
      case temp
      case humidity
    }

    private struct AdditionalInfo: Decodable {
      let id: Int
      let main: String
      let description: String
      let icon: String
    }

    private struct Coordinate: Decodable {
      let lat: CLLocationDegrees
      let lon: CLLocationDegrees
    }
  }

  enum ApiError: Error {
    case cityNotFound
    case serverFailure
    case invalidKey
  }

  /// The shared instance
  static var shared = ApiController()

  /// The api key to communicate with openweathermap.org
  /// Create your own on https://home.openweathermap.org/users/sign_up
  let apiKey = BehaviorSubject(value: "<#Your Key#>")

  /// API base URL
  let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!

  init() {
    Logging.URLRequests = { request in
      return true
    }
  }

  // MARK: - Api Calls
  func currentWeather(city: String) -> Observable<Weather> {
    return buildRequest(pathComponent: "weather", params: [("q", city)])
      .map { data in
        let decoder = JSONDecoder()
        return try decoder.decode(Weather.self, from: data)
      }
  }

  func currentWeather(at coordinate: CLLocationCoordinate2D) -> Observable<Weather> {
    return buildRequest(pathComponent: "weather", params: [("lat", "\(coordinate.latitude)"),
                                                           ("lon", "\(coordinate.longitude)")])
      .map { data in
        let decoder = JSONDecoder()
        return try decoder.decode(Weather.self, from: data)
      }
  }

  // MARK: - Private Methods

  /**
   * Private method to build a request with RxCocoa
   */
  private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
    let request: Observable<URLRequest> = Observable.create { observer in
      let url = self.baseURL.appendingPathComponent(pathComponent)
      var request = URLRequest(url: url)
      let keyQueryItem = URLQueryItem(name: "appid", value: try? self.apiKey.value())
      let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
      let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

      if method == "GET" {
        var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
        queryItems.append(keyQueryItem)
        queryItems.append(unitsQueryItem)
        urlComponents.queryItems = queryItems
      } else {
        urlComponents.queryItems = [keyQueryItem, unitsQueryItem]

        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.httpBody = jsonData
      }

      request.url = urlComponents.url!
      request.httpMethod = method

      request.setValue("application/json", forHTTPHeaderField: "Content-Type")

      observer.onNext(request)
      observer.onCompleted()

      return Disposables.create()
    }

    let session = URLSession.shared
    return request.flatMap { request in
      return session.rx.response(request: request)
      .map { response, data in
        switch response.statusCode {
        case 200 ..< 300:
          return data
        case 401:
          throw ApiError.invalidKey
        case 400 ..< 500:
          throw ApiError.cityNotFound
        default:
          throw ApiError.serverFailure
        }
      }
    }
  }

}

/**
 * Maps an icon information from the API to a local char
 * Source: http://openweathermap.org/weather-conditions
 */
public func iconNameToChar(icon: String) -> String {
  switch icon {
  case "01d":
    return "\u{f11b}"
  case "01n":
    return "\u{f110}"
  case "02d":
    return "\u{f112}"
  case "02n":
    return "\u{f104}"
  case "03d", "03n":
    return "\u{f111}"
  case "04d", "04n":
    return "\u{f111}"
  case "09d", "09n":
    return "\u{f116}"
  case "10d", "10n":
    return "\u{f113}"
  case "11d", "11n":
    return "\u{f10d}"
  case "13d", "13n":
    return "\u{f119}"
  case "50d", "50n":
    return "\u{f10e}"
  default:
    return "E"
  }
}
