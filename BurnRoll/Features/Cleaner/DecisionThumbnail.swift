import SwiftUI
@preconcurrency import Photos

struct DecisionThumbnail: View {
    let library: PhotoLibraryService
    let asset: MediaAsset
    let decision: ReviewDecision
    let size: CGFloat

    @State private var image: UIImage?
    @State private var requestID: PHImageRequestID?

    var body: some View {
        ZStack {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    BurnRollTheme.surface
                        .overlay {
                            ProgressView()
                                .controlSize(.small)
                        }
                }
            }
            .frame(width: size, height: size)
            .clipped()

            if asset.mediaType == .video {
                Image(systemName: "video.fill")
                    .font(.system(size: max(9, size * 0.15), weight: .bold))
                    .foregroundStyle(.white)
                    .padding(max(4, size * 0.07))
                    .background(.black.opacity(0.58), in: Capsule())
                    .padding(max(5, size * 0.08))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }

            Image(systemName: decision == .burn ? "flame.fill" : "heart.fill")
                .font(.system(size: max(10, size * 0.18), weight: .black))
                .foregroundStyle(.white)
                .frame(width: max(25, size * 0.32), height: max(25, size * 0.32))
                .background(decisionColor, in: Circle())
                .overlay {
                    Circle().strokeBorder(.white.opacity(0.78), lineWidth: 1)
                }
                .contentTransition(.symbolEffect(.replace))
                .padding(max(5, size * 0.07))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: max(12, size * 0.16), style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: max(12, size * 0.16), style: .continuous)
                .strokeBorder(decisionColor.opacity(0.95), lineWidth: 2)
        }
        .shadow(color: decisionColor.opacity(0.22), radius: 8, y: 4)
        .animation(.snappy(duration: 0.28), value: decision)
        .onAppear(perform: requestImage)
        .onDisappear(perform: cancelRequest)
        .onChange(of: asset.id) { _, _ in
            image = nil
            cancelRequest()
            requestImage()
        }
    }

    private var decisionColor: Color {
        decision == .burn ? BurnRollTheme.burn : BurnRollTheme.keep
    }

    private func requestImage() {
        requestID = library.requestImage(
            localIdentifier: asset.id,
            targetSize: CGSize(width: size * 3, height: size * 3)
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
