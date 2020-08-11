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
    func reloadRows(indexPath:IndexPath)
}
class UncompressedImageListViewModel {
    let docManager = DocumentsManager()
    var images:[ImageModel] = []
    weak var delegate: UncompressedImageListViewModelDelegate?
    let pendingOperations = PendingOperations()
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
            if let model = ImageModel(filename: name, documentsDirectory: self.docManager.documentsDirectory) {
                if !self.images.contains(where: {$0.name == model.name}) {
                    self.images.append(model)
//                    if let image = self.imageManager.processImage(at: model.fileUrl, with: model.name+"."+model.format) {
//                        model.setImageHeight(height: Float(image.size.height))
//                        self.addModel(model: model, image: image)
//                    }
                }
            }
        }
        if fileNames.count == 0 {
            self.delegate?.sendAlertMessage(message: NSLocalizedString("warning.text", comment: ""))
        }
        self.delegate?.reloadTable()
        self.delegate?.hideActivity()
    }
    
//    /// Method for filling the collection, and cacheing resized photo. This kind of ptimisation is for old devices support. Checked with iPhone 6s
//    /// - Parameters:
//    ///   - model: imade model
//    ///   - image: resized image
//    func addModel(model:ImageModel, image:UIImage)  {
//        DispatchQueue.main.async {
//            let cachedImage = CachedImage()
//            cachedImage.image = image
//            self.imageManager.imageCache.setObject(cachedImage, forKey: NSString(string: model.name+"."+model.format))
//            self.images.append(model)
//            self.delegate?.reloadTable()
//        }
//    }
}


// MARK: TableView setup

extension UncompressedImageListViewModel {
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section:Int) -> Int {
        return self.images.count
    }
    
//    func imageAtIndex(_ index: Int) -> ImageViewModel {
//        let image = self.images[index]
//        let imageVM = ImageViewModel(image)
//        imageVM.image = self.imageManager.imageCache.object(forKey: NSString(string: imageVM.fullName))?.image
//        return imageVM
//    }
    
    func heightForRow(at index:Int) -> Float {
        let image = self.images[index]
        if image.imageHeight > 0.0 {
            return image.imageHeight+26.0
        }
        return 0.0
    }
}

// MARK: Operations setup
extension UncompressedImageListViewModel {
    
    func loadImagesForOnscreenCells(pathsArray:[IndexPath]) {
        var allPendingOperations = Set(pendingOperations.resizingInProgress.keys)
        allPendingOperations.formUnion(pendingOperations.cachingInProgress.keys)
        var toBeCancelled = allPendingOperations
        let visiblePaths = Set(pathsArray)
        toBeCancelled.subtract(visiblePaths)
        
        var toBeStarted = visiblePaths
        toBeStarted.subtract(allPendingOperations)
        
        for indexPath in toBeCancelled {
            if let pendingResizing = self.pendingOperations.resizingInProgress[indexPath] {
                pendingResizing.cancel()
            }
            
            self.pendingOperations.resizingInProgress.removeValue(forKey: indexPath)
            
            if let pendingCaching = self.pendingOperations.cachingInProgress[indexPath] {
                pendingCaching.cancel()
            }
            self.pendingOperations.cachingInProgress.removeValue(forKey: indexPath)
        }
        
        for indexPath in toBeStarted {
            let imageToProcess = self.images[indexPath.row]
            self.startOperations(for: imageToProcess, at: indexPath)
        }
     }
    
    func suspendAllOperations() {
        self.pendingOperations.resizingQueue.isSuspended = true
        self.pendingOperations.cachingQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        self.pendingOperations.resizingQueue.isSuspended = false
        self.pendingOperations.cachingQueue.isSuspended = false
    }
    
    func startOperations(for model: ImageModel, at indexPath: IndexPath) {
        switch model.state {
        case .new:
            self.startResizing(for: model, at: indexPath)
        case .resized:
            self.startCaching(for: model, at: indexPath)
        default:
            print("Do noting")
        }
    }
    
    func startResizing(for model: ImageModel, at indexPath: IndexPath) {
        guard self.pendingOperations.resizingInProgress[indexPath] == nil else {
            return
        }
        let resizer = ImageResizing(model)
        resizer.completionBlock = {
            if resizer.isCancelled {
                return
            }
            self.pendingOperations.resizingInProgress.removeValue(forKey: indexPath)
            self.images[indexPath.row] = resizer.photoModel
            self.delegate?.reloadRows(indexPath: indexPath)
        }
        self.pendingOperations.resizingInProgress[indexPath] = resizer
        self.pendingOperations.resizingQueue.addOperation(resizer)
    }
    
    func startCaching(for model: ImageModel, at indexPath: IndexPath) {
        guard self.pendingOperations.cachingInProgress[indexPath] == nil else {
            return
        }
        let cacher = ImageCaching(model)
        cacher.completionBlock = {
            if cacher.isCancelled {
                return
            }
            self.pendingOperations.cachingInProgress.removeValue(forKey: indexPath)
            self.images[indexPath.row] = cacher.photoModel
            self.delegate?.reloadRows(indexPath: indexPath)
        }
        self.pendingOperations.cachingInProgress[indexPath] = cacher
        self.pendingOperations.cachingQueue.addOperation(cacher)
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


class PendingOperations {
    lazy var resizingInProgress: [IndexPath: Operation] = [:]
    lazy var resizingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Resizing queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var cachingInProgress: [IndexPath: Operation] = [:]
    lazy var cachingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Caching queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
