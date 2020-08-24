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

struct EOEventCategory: Decodable {
  let id: Int
  let title: String
}

struct EOEvent: Decodable {
  let id: String
  let title: String
  let description: String
  let link: URL?
  let closeDate: Date?
  let categories: [EOEventCategory]
  let locations: [EOLocation]?
  var date: Date? {
    return closeDate ?? locations?.compactMap(\.date).first
  }

  private enum CodingKeys: String, CodingKey {
    case id, title, description, link, closeDate = "closed", categories, locations = "geometries"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    description = try container.decode(String.self, forKey: .description)
    link = try container.decode(URL?.self, forKey: .link)
    closeDate = try container.decode(Date.self, forKey: .closeDate)
    categories = try container.decode([EOEventCategory].self, forKey: .categories)
    // This may throw because we don't fully implement the GeoJSON spec. Let's igore those errors for now.
    locations = try? container.decode([EOLocation].self, forKey: .locations)
  }

  static func compareDates(lhs: EOEvent, rhs: EOEvent) -> Bool {
    switch (lhs.date, rhs.date) {
    case (nil, nil): return false
    case (nil, _): return true
    case (_, nil): return false
    case (let ldate, let rdate): return ldate! < rdate!
    }
  }
}
