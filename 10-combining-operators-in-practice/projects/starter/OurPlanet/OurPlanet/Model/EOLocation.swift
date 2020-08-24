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
import CoreLocation

enum GeometryType: Decodable {
	case position
	case point
	case polygon

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let typeString = try container.decode(String.self)
		switch typeString {
			case "Point": self = .point
			case "Position": self = .position
			case "Polygon": self = .polygon
			default: throw EOError.invalidJSON("Unknown geometry type \(typeString)")
		}
	}
}

struct EOLocation: Decodable {

	let type: GeometryType
	let date: Date?
	let coordinates: Array<CLLocationCoordinate2D>

	private enum CodingKeys: String, CodingKey {
		case type, date, coordinates
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		type = try container.decode(GeometryType.self, forKey: .type)
		date = try container.decodeIfPresent(Date.self, forKey: .date)
		let coords = try container.decode([Double].self, forKey: .coordinates)
		guard (coords.count % 2) == 0 else {
			throw EOError.invalidJSON("Invalid coordinates")
		}
		coordinates = stride(from: 0, to: coords.count, by: 2).map { index in
			CLLocationCoordinate2D(latitude: coords[index], longitude: coords[index + 1])
		}
	}
}
