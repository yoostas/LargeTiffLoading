//
//  CachedImage.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 17.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import Foundation
import UIKit

class CachedImage: NSObject , NSDiscardableContent {
    public var image: UIImage!

    func beginContentAccess() -> Bool {
        return true
    }

    func endContentAccess() {

    }

    func discardContentIfPossible() {

    }

    func isContentDiscarded() -> Bool {
        return false /// Do not let the cached data been deleted after entering in background
    }
}
