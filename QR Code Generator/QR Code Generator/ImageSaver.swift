//
//  ImageSaver.swift
//  QR Code Generator
//
//  Created by Mustafo on 05/04/21.
//

import Photos
import UIKit

class ImageSaver:NSObject,ObservableObject{
    
    @Published var saveResult:ImageSaveResult?
    
    
    public func saveImage(_ image:UIImage,for qrCode: QRCode){
        let imageLabel = "Link: \(qrCode.url)"
        let photoLibaryAuthStatus = PHPhotoLibrary.authorizationStatus()
        if photoLibaryAuthStatus == .authorized{
            saveImage(image, withLabel: imageLabel)
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for:.addOnly){ status in
            DispatchQueue.main.async {
                if status == .authorized{
                    self.saveImage(image, withLabel: imageLabel)
                    return
                }
                self.saveResult = ImageSaveResult(saveStatus: .libraryPermissionDenied)
            }
        }
    }
    
    private func saveImage(_ image:UIImage,withLabel label:String){
        if let imageWithLabel = addLabeL(label, toImage: image){
            UIImageWriteToSavedPhotosAlbum(imageWithLabel, self, #selector(saveError), nil)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    
    private func addLabeL(_ label:String,toImage image:UIImage)->UIImage?{
        
        let font = UIFont.boldSystemFont(ofSize: 12)
        let text:NSString = NSString(string:label)
        
        let attr = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor: UIColor.systemIndigo,
        ]
        
        let textPadding:CGFloat = 8
        
        let sizeOfText = text.size(withAttributes: attr)
        let heighOffSet = sizeOfText.height + textPadding * 2
        let width = image.size.width
        let height = image.size.height + heighOffSet
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        
        if let context = UIGraphicsGetCurrentContext(){
          //  #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 0.9556084437).setFill()
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            context.fill(rect)
        }
        
        //Draw Image
        
        
        
        image.draw(in: CGRect(x: 0, y: heighOffSet, width: width, height: image.size.height))
     
        
        //Draw Text
        
        text.draw(in: CGRect(x: (width / 2) - (sizeOfText.width / 2),
                               y: textPadding, width: width, height: height),
                  withAttributes: attr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    @objc private func saveError(
        _ image:UIImage,
        didFinishSavingWithError error:Error?,
        contextInfo:UnsafeRawPointer
    ){
        if error != nil{
            saveResult = ImageSaveResult(saveStatus: .error)
        }else{
            saveResult = ImageSaveResult(saveStatus: .success)
        }
        
    }
    
}



struct ImageSaveResult:Identifiable{
    let  id = UUID()
    let saveStatus:ImageSaveStatus
}

enum ImageSaveStatus{
    case success
    case error
    case libraryPermissionDenied
}

