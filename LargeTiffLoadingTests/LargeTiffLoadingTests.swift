//
//  LargeTiffLoadingTests.swift
//  LargeTiffLoadingTests
//
//  Created by Stanislav's MacBook Pro on 16.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import XCTest
import UIKit
@testable import LargeTiffLoading

class LargeTiffLoadingTests: XCTestCase {

    let url = Bundle.main.url(forResource: "test_image",
    withExtension: "tif")!
    let fileName = "test_image.tif"
    
    func resize_test() {
        var image: UIImage?
        
        self.measure {
            image = ImageProcessingManager().processImage(at: self.url, with: self.fileName)
        }
        
        XCTAssertNotNil(image)
        XCTAssertEqual(image!.size.width, ImageProcessingManager().imageViewWidth, accuracy: 0.001)
    }
    
    func cached_image_test () {
        var image: UIImage?
        
        self.measure {
            image = ImageProcessingManager().imageCache.object(forKey: NSString(string: self.fileName))?.image
        }
        
        XCTAssertNotNil(image)
        XCTAssertEqual(image!.size.width, ImageProcessingManager().imageViewWidth, accuracy: 0.001)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
