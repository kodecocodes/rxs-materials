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

  /// The shared instance
  static var shared = ApiController()

  /// The api key to communicate with openweathermap.org
  /// Create you own on https://home.openweathermap.org/users/sign_up
  private let apiKey = "<#Your Key#>"

  /// API base URL
  let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!

  init() {
    Logging.URLRequests = { request in
      return true
    }
  }

  // MARK: - Api Calls
  func currentWeather(for city: String) -> Observable<Weather> {
    buildRequest(pathComponent: "weather", params: [("q", city)])
      .map { data in
        try JSONDecoder().decode(Weather.self, from: data)
      }
  }

  func currentWeather(at coordinate: CLLocationCoordinate2D) -> Observable<Weather> {
    buildRequest(pathComponent: "weather",
                 params: [("lat", "\(coordinate.latitude)"),
                          ("lon", "\(coordinate.longitude)")])
      .map { data in
        try JSONDecoder().decode(Weather.self, from: data)
      }
  }

  // MARK: - Private Methods

  /**
   * Private method to build a request with RxCocoa
   */
  private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
    let url = baseURL.appendingPathComponent(pathComponent)
    var request = URLRequest(url: url)
    let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
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

    let session = URLSession.shared

    return session.rx.data(request: request)
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

private func imageFromText(text: String, font: UIFont) -> UIImage {
  let size = text.size(withAttributes: [NSAttributedString.Key.font: font])

  UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
  text.draw(at: CGPoint(x: 0, y: 0), withAttributes: [NSAttributedString.Key.font: font])

  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()

  return image ?? UIImage()
}

extension ApiController.Weather {
  func overlay() -> Overlay {
    let coordinates: [CLLocationCoordinate2D] = [
      CLLocationCoordinate2D(latitude: coordinate.latitude - 0.25,
                             longitude: coordinate.longitude - 0.25),
      CLLocationCoordinate2D(latitude: coordinate.latitude + 0.25,
                             longitude: coordinate.longitude + 0.25)
    ]

    let points = coordinates.map { MKMapPoint($0) }
    let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
    let mapRectUnion: (MKMapRect, MKMapRect) -> MKMapRect = { $0.union($1) }
    let fittingRect = rects.reduce(MKMapRect.null, mapRectUnion)
    return Overlay(icon: icon, coordinate: coordinate, boundingMapRect: fittingRect)
  }

  class Overlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    let icon: String

    init(icon: String, coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect) {
      self.coordinate = coordinate
      self.boundingMapRect = boundingMapRect
      self.icon = icon
    }
  }

  class OverlayView: MKOverlayRenderer {
    var overlayIcon: String

    init(overlay:MKOverlay, overlayIcon:String) {
      self.overlayIcon = overlayIcon
      super.init(overlay: overlay)
    }

    public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
      let imageReference = imageFromText(text: overlayIcon, font: UIFont(name: "Flaticon", size: 32.0)!).cgImage
      let theMapRect = overlay.boundingMapRect
      let theRect = rect(for: theMapRect)

      context.scaleBy(x: 1.0, y: -1.0)
      context.translateBy(x: 0.0, y: -theRect.size.height)
      context.draw(imageReference!, in: theRect)
    }
  }
}
