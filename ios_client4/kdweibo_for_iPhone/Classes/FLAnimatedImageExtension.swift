//
//  FLAnimatedImageExtension.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/10/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

extension FLAnimatedImage {
    class func animatedImage(fileName: String?) -> FLAnimatedImage? {
        guard let fileName = fileName, let path = Bundle.main.path(forResource: fileName, ofType: "gif")
            else { return nil }
        return FLAnimatedImage(animatedGIFData: try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
}
