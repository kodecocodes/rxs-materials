//
//  ImageView+setURL.swift
//  Tweetie
//
//  Created by Marin Todorov on 12/9/18.
//  Copyright © 2018 Underplot ltd. All rights reserved.
//

#if os(iOS)
import UIKit
typealias ImageView = UIImageView
typealias Image = UIImage
#endif

#if os(macOS)
import AppKit
typealias ImageView = NSImageView
typealias Image = NSImage
#endif

extension ImageView {
  func setImage(with url: URL?) {
    guard let url = url else {
      image = nil
      return
    }

    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let strongSelf = self else { return }
      URLSession.shared.dataTask(with: url) { data, response, error in
        var result: Image? = nil
        if let data = data, let newImage = Image(data: data) {
          result = newImage
        } else {
          print("Fetch image error: \(error?.localizedDescription ?? "n/a")")
        }
        DispatchQueue.main.async {
          strongSelf.image = result
        }
      }.resume()
    }
  }
}

