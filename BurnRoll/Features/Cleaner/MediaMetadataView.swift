import SwiftUI

struct MediaMetadataView: View {
    let asset: MediaAsset

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HStack(spacing: 7) {
                    BurnRollSymbol(
                        systemName: asset.mediaType == .video ? "video.fill" : "photo.fill",
                        size: 14,
                        role: .photo
                    )
                    Text(asset.mediaType.localizedTitle)
                }
                Spacer()
                Text("~\(asset.estimatedByteSize.formattedByteCount)")
            }
            .font(.subheadline.weight(.semibold))

            if let date = asset.creationDate {
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(BurnRollTheme.secondaryText)
            } else {
                Text("Capture date unavailable")
                    .font(.caption)
                    .foregroundStyle(BurnRollTheme.secondaryText)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }
}

extension Int64 {
    var formattedByteCount: String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}
