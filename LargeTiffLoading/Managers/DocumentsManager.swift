//
//  DocumentsManager.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 16.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import Foundation
import UIKit
class DocumentsManager: NSObject {
    var fileManager: FileManager = FileManager()
    var result:(([String]) -> Void)?
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    var documentsDirectory: String {
        get {
            return (self.paths.first != nil) ? self.paths.first! : ""
        }
    }
    var syncTimer: Timer? //One timer. It's too expensive to initialize it every loop.
    
    override init() {}
    
    /// Main setup of the manager. Every 10 seconds it calls for documents directory. So user could delete or add new big
    /// picture via Finder
    
    func setup() {
        self.listFilesFromDocumentsFolder()
        self.syncTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {[weak self] (timer) in
            self?.listFilesFromDocumentsFolder()
        })
    }
    
    /// Get list of files shared via Itunes/Finder
    
    func listFilesFromDocumentsFolder(){
        var imageNames:[String] = []
        do {
            let fileList = try self.fileManager.contentsOfDirectory(atPath: self.documentsDirectory)
            for s in fileList {
                imageNames.append(s)
            }
        } catch {
            print("error: ", error)
        }
        self.result?(imageNames)
    }
    
    func writeImage(image:UIImage, with name:String) {
        
    }
}
