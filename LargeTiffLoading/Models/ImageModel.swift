//
//  ImageModel.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 16.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import Foundation
struct ImageModel {
    let name:String
    let format:String
    let fileUrl:URL
    var imageHeight:Float?
    
    
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
    
    mutating func setImageHeight(height:Float) {
        self.imageHeight = height
    }
    
}
