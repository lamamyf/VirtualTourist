//
//  ImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Lama AlMayouf on 8/12/20.
//  Copyright © 2020 Lama AlMayouf. All rights reserved.
//

import UIKit
import Kingfisher
class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    var imageObj: Image!{
        didSet{
            if let image = imageObj.fetchImage(){
                imageView.image = image
            }else if let urlString = imageObj.url, let url = URL(string: urlString){
                imageView.kf.indicatorType = .activity

                imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (result) in
                     switch result{
                        case .success(let value):
                            let image = value.image
                            DispatchQueue.main.async{
                               self.imageView.image = image
                                self.imageObj.image = image.jpegData(compressionQuality: 0.2)
                               try? DataController.shared.viewContext.save()
                            }
                        case .failure(let error):
                           debugPrint(error)
                    }
                }
            }
        }
    }
}
