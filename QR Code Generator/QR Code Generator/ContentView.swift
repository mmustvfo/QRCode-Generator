//
//  ContentView.swift
//  QR Code Generator
//

import SwiftUI

struct ContentView: View {
    
  @State private var urlInput: String = ""
  @State private var qrCode: QRCode?

  private let qrCodeGenerator = QRCodeGenerator()
  @StateObject private var imageSaver = ImageSaver()

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)), Color(#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)),Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
        VStack {
          HStack {
            TextField("Enter url:", text: $urlInput)
                .textContentType(.URL)
                .background(Color.green)
              .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(8)
              .textContentType(.URL)
              .keyboardType(.URL)
              .shadow(color: Color.black.opacity(0.7), radius: 10, x: 0.0, y: 0.0)
            
        
            
            Button(action: {
                UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
                qrCode = qrCodeGenerator.generateQRCode(forUrlString: urlInput)
                urlInput = ""
            }, label: {
                Text("Generate")
                    .disabled(urlInput.isEmpty)
                    .padding(.leading)
            })
          }

          Spacer()

          if qrCode == nil {
            EmptyStateView(width: geometry.size.width)
          } else {
            QRCodeView(qrCode: qrCode!, width: geometry.size.width)
          }

          Spacer()
        }
        .padding()
        .navigationBarTitle("QR Code")
        .navigationBarItems(trailing: Button(action: {
          assert(qrCode != nil, "Cannot save nil QR code image")
            imageSaver.saveImage(qrCode!.image, for: qrCode!)
        }) {
          Image(systemName: "square.and.arrow.down")
        }
        .disabled(qrCode == nil))
        .alert(item: $imageSaver.saveResult) { saveResult in
          return alert(forSaveStatus: saveResult.saveStatus)
        }
      }
    }
  }

  private func alert(forSaveStatus saveStatus: ImageSaveStatus) -> Alert {
    switch saveStatus {
    case .success:
      return Alert(
        title: Text("Success!"),
        message: Text("The QR code was saved to your photo library.")
      )
    case .error:
      return Alert(
        title: Text("Oops!"),
        message: Text("An error occurred while saving your QR code.")
      )
    case .libraryPermissionDenied:
      return Alert(
        title: Text("Oops!"),
        message: Text("This app needs permission to add photos to your library."),
        primaryButton: .cancel(Text("Ok")),
        secondaryButton: .default(Text("Open settings")) {
          guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
          UIApplication.shared.open(settingsUrl)
        }
      )
    }
  }
}

struct QRCodeView: View {
  let qrCode: QRCode
  let width: CGFloat

  var body: some View {
    VStack {
      Label("QR code for \(qrCode.url):", systemImage: "qrcode.viewfinder")
        .foregroundColor(.white)
        .lineLimit(3)
      Image(uiImage: qrCode.image)
        .resizable()
        .frame(width: width * 2 / 3, height: width * 2 / 3)
    }
  }
}

struct EmptyStateView: View {

  let width: CGFloat

  private var imageLength: CGFloat {
    width / 2.5
  }

  var body: some View {
    VStack {
      Image(systemName: "qrcode")
        .resizable()
        .frame(width: imageLength, height: imageLength)

      Text("Create your own QR code")
        .padding(.top)
    }
    .foregroundColor(Color(UIColor.systemGray))
  }
}
