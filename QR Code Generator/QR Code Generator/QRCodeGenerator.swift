//
//  QRCodeGenerator.swift
//  QR Code Generator
//
//  Created by Mustafo on 04/04/21.
//

import CoreImage.CIFilterBuiltins
import UIKit

struct QRCodeGenerator{
    
    let filter = CIFilter.qrCodeGenerator()
    let context = CIContext()
    
    public func generateQRCode(forUrlString url:String)-> QRCode?{
        guard !url.isEmpty else {return nil}
        
        let data = Data(url.utf8)
        filter.setValue(data,forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        if let outPutImage = filter.outputImage?.transformed(by: transform) {
            if let cgImage = context.createCGImage(outPutImage, from: outPutImage.extent){
                let qrCode = QRCode(url: url, image: UIImage(cgImage: cgImage))
                return qrCode
            }
        }
        return nil
    }
    
 
}
struct QRCode{
    let url:String
    let image:UIImage
}
