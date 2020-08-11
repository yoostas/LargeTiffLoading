//
//  ImageModel.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 16.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import Foundation
import UIKit
enum ImageModelState {
  case new, resized, cached
}
struct ImageModel {
    let name:String
    let format:String
    let imageViewWidth = UIScreen.main.bounds.size.width-40.0
    let fileUrl:URL
    var imageHeight:Float {
        guard let image = UIImage(contentsOfFile: self.fileUrl.path) else {
            return 0.0
        }
        let ratio = image.size.width/self.imageViewWidth
        return Float(image.size.height/ratio)
    }
    var state = ImageModelState.new
    var image = UIImage(named: "placeholderImage")
    
    
    public init?(filename:String?, documentsDirectory:String) {
        guard let fileName = filename else {
            return nil
        }
        let components = fileName.components(separatedBy: ".")
        if components.count == 2 {
            if let name = components.first, let format = components.last {
                self.name = name
                self.format = format
                self.fileUrl = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
