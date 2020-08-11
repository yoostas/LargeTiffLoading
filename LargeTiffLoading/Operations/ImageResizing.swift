//
//  ImageResizing.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 09.08.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import Foundation
import UIKit

class ImageResizing: Operation {
    let imageViewWidth = UIScreen.main.bounds.size.width-40.0
    let imageCache = NSCache<NSString, CachedImage>()
    var photoModel: ImageModel
    
    init(_ model:ImageModel) {
        self.photoModel = model
    }
    
    override func main() {
        if self.isCancelled {
          return
        }
        
        if let image = self.processImage(at: self.photoModel.fileUrl, with: self.photoModel.name+"."+self.photoModel.format) {
            self.photoModel.image = image
            self.photoModel.state = .resized
        }
    }
    
    
    /// Function wrapper, for image processing
    /// - Parameters:
    ///   - url: image  path in the shared folder
    ///   - fullName: future name of the resized image
    /// - Returns: final scaled image
    func processImage(at url: URL, with fullName:String) -> UIImage?  {
        if let image = self.resizedImage(at: url, with: fullName) {
            return image
        }
        return nil
    }
    
    
    /// Main resize and rendering function. For the rendering I'm using UIKit/UIGraphicsImageRenderer metod. Most efficient and hight leveled one
    /// - Parameters:
    ///   - url: image  path in the shared folder
    ///   - fullName: future name of the resized image
    /// - Returns: final scaled image
    private func resizedImage(at url: URL,with fullName:String) -> UIImage? {
        if let cachedImage = self.imageCache.object(forKey: NSString(string: fullName)) {
            return cachedImage.image
        }
        guard let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        let scaledSize = self.scaledSize(imageSize: image.size)
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let finalImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
            
        }
        print(finalImage.size.height)
        DispatchQueue.main.async {
            let cachedImage = CachedImage()
            cachedImage.image = finalImage
            self.imageCache.setObject(cachedImage, forKey: NSString(string: fullName))
        }
        return finalImage
    }
    
    /// Different images have different sides ratio. So for following the requirenments about correct rendering, we are doing this
    /// - Parameter imageSize: original image size
    /// - Returns: scaled image size for rendering
    private func scaledSize(imageSize:CGSize) -> CGSize {
        let ratio = imageSize.width/self.imageViewWidth
        
        let size = CGSize(width: imageSize.width/ratio, height: imageSize.height/ratio)
        return size
    }
}
