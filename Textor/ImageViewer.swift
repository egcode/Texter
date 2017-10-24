//
//  ImageViewer.swift
//  Textor
//
//  Created by eugene golovanov on 3/9/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class ImageViewer: UIViewController {
    
    var image: UIImage?
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    
    //-----------------------------------------------------------------------------------
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let im = self.image {
            imageView = UIImageView(image: im)
            
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            scrollView.backgroundColor = UIColor.white
            scrollView.contentSize = imageView.bounds.size
            scrollView.addSubview(imageView)
            self.view.addSubview(scrollView)
            scrollView.delegate = self
            
            self.setZoomParametersForSize(scrollViewSize: scrollView.bounds.size)
            scrollView.zoomScale = scrollView.minimumZoomScale
            
            self.recenterImage()
        }
    }
    
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollViewSize: scrollView.bounds.size)
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        recenterImage()
        
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    //-----------------------------------------------------------------------------------
    //MARK: - ScrollView methods
    
    //Calculate Minimum Zoom Scale, to fit image to screen
    func setZoomParametersForSize(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
    }
    
    ///Center image while image less than screen
    func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let horizontalSpace = imageViewSize.width < scrollViewSize.width ?
            (scrollViewSize.width - imageViewSize.width) / 2.0 : 0
        
        let verticalSpace = imageViewSize.height < scrollViewSize.height ?
            (scrollViewSize.height - imageViewSize.height) / 2.0 : 0
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalSpace,
            left: horizontalSpace,
            bottom: verticalSpace,
            right: horizontalSpace)
    }
}

//-----------------------------------------------------------------------------------
// MARK: - UIScrollViewDelegate

extension ImageViewer: UIScrollViewDelegate {
    
//    /////SWIFT 2 Method
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
    
    //SWIFT 3 Method
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImage()
    }
}
