import SwiftUI
@preconcurrency import Photos

struct PhotoAssetImage: View {
    let library: PhotoLibraryService
    let assetID: String
    let targetSize: CGSize
    var contentMode: ContentMode = .fill
    var networkAccessAllowed = false

    @State private var image: UIImage?
    @State private var requestID: PHImageRequestID?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    BurnRollTheme.surface
                    ProgressView()
                        .tint(BurnRollTheme.ember)
                }
            }
        }
        .onAppear(perform: requestImage)
        .onDisappear(perform: cancelRequest)
        .onChange(of: assetID) { _, _ in
            image = nil
            cancelRequest()
            requestImage()
        }
    }

    private func requestImage() {
        requestID = library.requestImage(
            localIdentifier: assetID,
            targetSize: targetSize,
            contentMode: contentMode == .fill ? .aspectFill : .aspectFit,
            networkAccessAllowed: networkAccessAllowed
        ) { requestedImage in
            if let requestedImage {
                image = requestedImage
            }
        }
    }

    private func cancelRequest() {
        guard let requestID else { return }
        library.cancelImageRequest(requestID)
        self.requestID = nil
    }
}
