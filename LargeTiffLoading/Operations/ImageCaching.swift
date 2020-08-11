//
//  ImageCaching.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 11.08.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import Foundation
import UIKit

class ImageCaching: Operation {
    var photoModel: ImageModel
    let imageCache = NSCache<NSString, CachedImage>()
    init(_ model:ImageModel) {
        self.photoModel = model
    }
    
    override func main() {
        if self.isCancelled {
          return
        }
        if self.photoModel.image != nil {
            if self.cacheImage() {
                if let cachedImage = self.cachedImage() {
                    self.photoModel.image = cachedImage
                    self.photoModel.state = .cached
                }
            }
        }
    }
    
    func cacheImage() -> Bool {
        if let image = self.photoModel.image {
            let cachedImage = CachedImage()
            cachedImage.image = image
            let fullName = self.photoModel.name+"."+self.photoModel.format
            self.imageCache.setObject(cachedImage, forKey: NSString(string: fullName))
            return true
        }
        return false
    }
    
    func cachedImage() -> UIImage? {
        let fullName = self.photoModel.name+"."+self.photoModel.format
        return self.imageCache.object(forKey: NSString(string: fullName))?.image
    }
    
    
}
