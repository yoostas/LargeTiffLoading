//
//  UncompressedImageListViewModel.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 17.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import Foundation
import UIKit
protocol UncompressedImageListViewModelDelegate: AnyObject {
    func reloadTable()
    func showActivity()
    func hideActivity()
    func sendAlertMessage(message:String)
}
class UncompressedImageListViewModel {
    let docManager = DocumentsManager()
    let imageManager = ImageProcessingManager()
    var images:[ImageModel] = []
    weak var delegate: UncompressedImageListViewModelDelegate?
}


// MARK: model methods
extension UncompressedImageListViewModel {
    
    /// Main setup for the viewmodel.
    func setup() {
        self.docManager.result = {[weak self] (fileNames) in
            if let self = self {
                self.delegate?.showActivity()
                if fileNames.count < self.images.count {
                    self.images.removeAll()
                }
                self.processFileNames(fileNames: fileNames)
            }
        }
        self.docManager.setup()
    }
    
    /// Method for ImageModel setup
    /// - Parameter fileNames: array of filenames from shared folder
    func processFileNames(fileNames:[String]) {
        for name in fileNames {
            if var model = ImageModel(filename: name, documentsDirectory: self.docManager.documentsDirectory) {
                if !self.images.contains(where: {$0.name == model.name}) {
                    if let image = self.imageManager.processImage(at: model.fileUrl, with: model.name+"."+model.format) {
                        model.setImageHeight(height: Float(image.size.height))
                        self.addModel(model: model, image: image)
                    }
                }
            }
        }
        if fileNames.count == 0 {
            self.delegate?.sendAlertMessage(message: NSLocalizedString("warning.text", comment: ""))
        }
        self.delegate?.hideActivity()
    }
    
    /// Method for filling the collection, and cacheing resized photo. This kind of ptimisation is for old devices support. Checked with iPhone 6s
    /// - Parameters:
    ///   - model: imade model
    ///   - image: resized image
    func addModel(model:ImageModel, image:UIImage)  {
        DispatchQueue.main.async {
            let cachedImage = CachedImage()
            cachedImage.image = image
            self.imageManager.imageCache.setObject(cachedImage, forKey: NSString(string: model.name+"."+model.format))
            self.images.append(model)
            self.delegate?.reloadTable()
        }
    }
}


// MARK: TableView setup

extension UncompressedImageListViewModel {
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section:Int) -> Int {
        return self.images.count
    }
    
    func imageAtIndex(_ index: Int) -> ImageViewModel {
        let image = self.images[index]
        let imageVM = ImageViewModel(image)
        imageVM.image = self.imageManager.imageCache.object(forKey: NSString(string: imageVM.fullName))?.image
        return imageVM
    }
    
    func heightForRow(at index:Int) -> Float {
        let image = self.images[index]
        if let height = image.imageHeight {
            return height+26.0
        }
        return 0.0
    }
}

// MARK: viewmodel for cell

class ImageViewModel {
    private let imageModel:ImageModel
    var image:UIImage?
    init(_ imageModel:ImageModel) {
        self.imageModel = imageModel
    }
}

extension ImageViewModel {
    var name:String{
        return self.imageModel.name
    }
    var format: String {
        return self.imageModel.format
    }
    
    var imageUrl:URL {
        return self.imageModel.fileUrl
    }
    
    var fullName: String {
        return self.imageModel.name+"."+self.imageModel.format
    }
}
