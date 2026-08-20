import Observation
import os
@preconcurrency import Photos
import AVFoundation
import UIKit

@MainActor
@Observable
final class PhotoLibraryService {
    enum ReviewScope: String, CaseIterable, Identifiable {
        case notReviewed
        case reviewed
        case all

        var id: String { rawValue }

        var title: String {
            switch self {
            case .notReviewed: "Not reviewed"
            case .reviewed: "Reviewed"
            case .all: "All items"
            }
        }

        var shortTitle: String {
            switch self {
            case .notReviewed: "Not reviewed"
            case .reviewed: "Reviewed"
            case .all: "All"
            }
        }

        var systemImage: String {
            switch self {
            case .notReviewed: "bookmark"
            case .reviewed: "checkmark.seal.fill"
            case .all: "photo.stack.fill"
            }
        }

        var analyticsFilterType: AnalyticsService.FilterType {
            switch self {
            case .notReviewed: .notReviewed
            case .reviewed: .reviewed
            case .all: .all
            }
        }

        var filteringScope: ReviewScopeFiltering.Scope {
            switch self {
            case .notReviewed: .notReviewed
            case .reviewed: .reviewed
            case .all: .all
            }
        }
    }

    struct ReminderLibrarySnapshot: Equatable, Sendable {
        let totalPhotoCount: Int
        let totalEstimatedBytes: Int64
        let recentPhotoCount: Int
        let recentEstimatedBytes: Int64
        let capturedAt: Date
    }

    struct MediaSource: Identifiable, Hashable {
        enum Section: String, CaseIterable, Identifiable {
            case library = "Library"
            case mediaTypes = "Media Types"
            case albums = "Albums"

            var id: String { rawValue }
        }

        fileprivate enum Filter: Hashable {
            case all
            case recents
            case photos
            case videos
            case smartAlbum(PHAssetCollectionSubtype)
            case userAlbum(String)
        }

        let id: String
        let title: String
        let systemImage: String
        let section: Section
        let itemCount: Int
        fileprivate let filter: Filter

        fileprivate func withItemCount(_ itemCount: Int) -> MediaSource {
            MediaSource(
                id: id,
                title: title,
                systemImage: systemImage,
                section: section,
                itemCount: itemCount,
                filter: filter
            )
        }
    }

    private let imageManager = PHCachingImageManager()
    private let filterSignposter = OSSignposter(
        subsystem: "com.vitaliibadion.burnroll",
        category: "filters"
    )
    private var fetchResult: PHFetchResult<PHAsset>?
    private var currentAssetIdentifiers: [String] = []
    private var visibleAssetIndexes: [Int] = []
    private var cachedRange: Range<Int>?
    private var hasReviewScopeCounts = false
    private var isObservingLibraryChanges = false
    private let libraryChangeObserver = PhotoLibraryChangeObserver()
    nonisolated static let libraryDidChangeNotification = Notification.Name("BurnRollPhotoLibraryDidChange")

    private(set) var assetCount = 0
    private(set) var availableSources: [MediaSource] = []
    private(set) var selectedReviewScope = ReviewScope.notReviewed
    private(set) var reviewScopeCounts: [ReviewScope: Int] = [
        .notReviewed: 0,
        .reviewed: 0,
        .all: 0
    ]
    private(set) var selectedSource = MediaSource(
        id: "all",
        title: "All",
        systemImage: "photo.stack.fill",
        section: .library,
        itemCount: 0,
        filter: .all
    )

    func loadNewestFirst(
        source requestedSource: MediaSource? = nil,
        reviewScope requestedReviewScope: ReviewScope? = nil,
        reviewedAssetIdentifiers: Set<String> = [],
        refreshCatalog: Bool = false
    ) {
        let reviewScope = requestedReviewScope ?? selectedReviewScope
        if refreshCatalog {
            refreshAvailableSources(
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers
            )
        } else if !hasReviewScopeCounts {
            refreshReviewScopeCounts(reviewedAssetIdentifiers: reviewedAssetIdentifiers)
        }

        let source = resolvedSource(requestedSource)
        applyFetchedSource(
            source,
            reviewScope: reviewScope,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers
        )
    }

    @discardableResult
    func applyReviewScope(
        _ reviewScope: ReviewScope,
        reviewedAssetIdentifiers: Set<String>
    ) -> Int {
        let signpostID = filterSignposter.makeSignpostID()
        let interval = filterSignposter.beginInterval("applyReviewScope", id: signpostID)
        let startedAt = CFAbsoluteTimeGetCurrent()

        selectedReviewScope = reviewScope
        visibleAssetIndexes = ReviewScopeFiltering.visibleIndexes(
            identifiers: currentAssetIdentifiers,
            reviewedIdentifiers: reviewedAssetIdentifiers,
            scope: reviewScope.filteringScope
        )
        assetCount = visibleAssetIndexes.count
        selectedSource = selectedSource.withItemCount(assetCount)
        if let index = availableSources.firstIndex(where: { $0.id == selectedSource.id }) {
            availableSources[index] = selectedSource
        }
        imageManager.stopCachingImagesForAllAssets()
        cachedRange = nil

        filterSignposter.endInterval("applyReviewScope", interval)
        return max(0, Int(((CFAbsoluteTimeGetCurrent() - startedAt) * 1_000).rounded()))
    }

    func itemCount(for reviewScope: ReviewScope) -> Int {
        reviewScopeCounts[reviewScope, default: 0]
    }

    func updateReviewScopeCounts(markedReviewed: Bool) {
        let reviewedDelta = markedReviewed ? 1 : -1
        let notReviewedDelta = -reviewedDelta
        reviewScopeCounts[.reviewed] = max(
            0,
            reviewScopeCounts[.reviewed, default: 0] + reviewedDelta
        )
        reviewScopeCounts[.notReviewed] = max(
            0,
            reviewScopeCounts[.notReviewed, default: 0] + notReviewedDelta
        )
    }

    func refreshAvailableSources(
        reviewScope: ReviewScope,
        reviewedAssetIdentifiers: Set<String>
    ) {
        let options = makeFetchOptions()
        var sources: [MediaSource] = []

        refreshReviewScopeCounts(
            reviewedAssetIdentifiers: reviewedAssetIdentifiers,
            allAssets: fetchAssets(for: .all, options: options)
        )

        sources.append(
            makeSource(
                id: "all",
                title: "All",
                systemImage: "photo.stack.fill",
                section: .library,
                filter: .all,
                options: options,
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers
            )
        )
        sources.append(
            makeSource(
                id: "recents",
                title: "Recents",
                systemImage: "clock.arrow.circlepath",
                section: .library,
                filter: .recents,
                options: options,
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers
            )
        )
        appendSmartAlbum(
            .smartAlbumRecentlyAdded,
            title: "Recently Added",
            systemImage: "calendar.badge.plus",
            section: .library,
            options: options,
            reviewScope: reviewScope,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers,
            to: &sources
        )
        appendSmartAlbum(
            .smartAlbumFavorites,
            title: "Favorites",
            systemImage: "heart.fill",
            section: .library,
            options: options,
            reviewScope: reviewScope,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers,
            to: &sources
        )

        sources.append(
            makeSource(
                id: "photos",
                title: "Photos",
                systemImage: "photo.fill",
                section: .mediaTypes,
                filter: .photos,
                options: options,
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers
            )
        )
        sources.append(
            makeSource(
                id: "videos",
                title: "Videos",
                systemImage: "video.fill",
                section: .mediaTypes,
                filter: .videos,
                options: options,
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers
            )
        )

        let smartMediaTypes: [(PHAssetCollectionSubtype, String, String)] = [
            (.smartAlbumSelfPortraits, "Selfies", "person.crop.square.fill"),
            (.smartAlbumLivePhotos, "Live Photos", "livephoto"),
            (.smartAlbumDepthEffect, "Portrait", "person.crop.rectangle.fill"),
            (.smartAlbumPanoramas, "Panoramas", "pano.fill"),
            (.smartAlbumTimelapses, "Time-lapse", "timer"),
            (.smartAlbumSlomoVideos, "Slo-mo", "gauge.with.dots.needle.33percent"),
            (.smartAlbumCinematic, "Cinematic", "camera.metering.center.weighted"),
            (.smartAlbumBursts, "Bursts", "square.stack.3d.up.fill"),
            (.smartAlbumScreenshots, "Screenshots", "iphone"),
            (.smartAlbumScreenRecordings, "Screen Recordings", "record.circle"),
            (.smartAlbumSpatial, "Spatial", "visionpro.fill"),
            (.smartAlbumRAW, "RAW", "camera.filters"),
            (.smartAlbumAnimated, "Animated", "sparkles.rectangle.stack.fill"),
            (.smartAlbumLongExposures, "Long Exposures", "camera.aperture")
        ]

        for (subtype, title, systemImage) in smartMediaTypes {
            appendSmartAlbum(
                subtype,
                title: title,
                systemImage: systemImage,
                section: .mediaTypes,
                options: options,
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers,
                to: &sources
            )
        }

        var albums: [MediaSource] = []
        let albumCollections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil
        )
        albumCollections.enumerateObjects { collection, _, _ in
            let result = PHAsset.fetchAssets(in: collection, options: options)
            let itemCount = self.scopedCount(
                in: result,
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers
            )
            guard itemCount > 0 else { return }

            albums.append(
                MediaSource(
                    id: "album-\(collection.localIdentifier)",
                    title: collection.localizedTitle ?? "Album",
                    systemImage: "rectangle.stack.fill",
                    section: .albums,
                    itemCount: itemCount,
                    filter: .userAlbum(collection.localIdentifier)
                )
            )
        }
        albums.sort { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        sources.append(contentsOf: albums)

        availableSources = sources
        hasReviewScopeCounts = true
    }

    private func resolvedSource(_ requestedSource: MediaSource?) -> MediaSource {
        let sourceID = requestedSource?.id ?? selectedSource.id
        return availableSources.first(where: { $0.id == sourceID })
            ?? requestedSource
            ?? availableSources.first
            ?? selectedSource
    }

    private func applyFetchedSource(
        _ source: MediaSource,
        reviewScope: ReviewScope,
        reviewedAssetIdentifiers: Set<String>
    ) {
        let signpostID = filterSignposter.makeSignpostID()
        let interval = filterSignposter.beginInterval("fetchSource", id: signpostID)

        let result = fetchAssets(for: source.filter, options: makeFetchOptions())
        let identifiers = identifiers(in: result)
        let indexes = ReviewScopeFiltering.visibleIndexes(
            identifiers: identifiers,
            reviewedIdentifiers: reviewedAssetIdentifiers,
            scope: reviewScope.filteringScope
        )
        let updatedSource = source.withItemCount(indexes.count)

        fetchResult = result
        currentAssetIdentifiers = identifiers
        visibleAssetIndexes = indexes
        assetCount = indexes.count
        selectedSource = updatedSource
        selectedReviewScope = reviewScope
        if let index = availableSources.firstIndex(where: { $0.id == updatedSource.id }) {
            availableSources[index] = updatedSource
        }
        imageManager.stopCachingImagesForAllAssets()
        cachedRange = nil

        filterSignposter.endInterval("fetchSource", interval)
    }

    private func refreshReviewScopeCounts(
        reviewedAssetIdentifiers: Set<String>,
        allAssets: PHFetchResult<PHAsset>? = nil
    ) {
        let result = allAssets ?? fetchAssets(for: .all, options: makeFetchOptions())
        let counts = ReviewScopeFiltering.counts(
            identifiers: identifiers(in: result),
            reviewedIdentifiers: reviewedAssetIdentifiers
        )
        reviewScopeCounts = [
            .notReviewed: counts.notReviewed,
            .reviewed: counts.reviewed,
            .all: counts.all
        ]
        hasReviewScopeCounts = true
    }

    private func identifiers(in result: PHFetchResult<PHAsset>) -> [String] {
        var identifiers: [String] = []
        identifiers.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in
            identifiers.append(asset.localIdentifier)
        }
        return identifiers
    }

    private func makeSource(
        id: String,
        title: String,
        systemImage: String,
        section: MediaSource.Section,
        filter: MediaSource.Filter,
        options: PHFetchOptions,
        reviewScope: ReviewScope,
        reviewedAssetIdentifiers: Set<String>
    ) -> MediaSource {
        let result = fetchAssets(for: filter, options: options)
        return MediaSource(
            id: id,
            title: title,
            systemImage: systemImage,
            section: section,
            itemCount: scopedCount(
                in: result,
                reviewScope: reviewScope,
                reviewedAssetIdentifiers: reviewedAssetIdentifiers
            ),
            filter: filter
        )
    }

    private func appendSmartAlbum(
        _ subtype: PHAssetCollectionSubtype,
        title: String,
        systemImage: String,
        section: MediaSource.Section,
        options: PHFetchOptions,
        reviewScope: ReviewScope,
        reviewedAssetIdentifiers: Set<String>,
        to sources: inout [MediaSource]
    ) {
        let filter = MediaSource.Filter.smartAlbum(subtype)
        let result = fetchAssets(for: filter, options: options)
        let itemCount = scopedCount(
            in: result,
            reviewScope: reviewScope,
            reviewedAssetIdentifiers: reviewedAssetIdentifiers
        )
        guard itemCount > 0 else { return }

        sources.append(
            MediaSource(
                id: "smart-\(subtype.rawValue)",
                title: title,
                systemImage: systemImage,
                section: section,
                itemCount: itemCount,
                filter: filter
            )
        )
    }

    private func scopedCount(
        in result: PHFetchResult<PHAsset>,
        reviewScope: ReviewScope,
        reviewedAssetIdentifiers: Set<String>
    ) -> Int {
        guard reviewScope != .all else { return result.count }

        let scope = reviewScope.filteringScope
        var count = 0
        result.enumerateObjects { asset, _, _ in
            if ReviewScopeFiltering.includes(
                isReviewed: reviewedAssetIdentifiers.contains(asset.localIdentifier),
                scope: scope
            ) {
                count += 1
            }
        }
        return count
    }

    private func fetchAssets(
        for filter: MediaSource.Filter,
        options: PHFetchOptions
    ) -> PHFetchResult<PHAsset> {
        switch filter {
        case .all:
            return PHAsset.fetchAssets(with: options)
        case .recents:
            return fetchAssets(inSmartAlbum: .smartAlbumUserLibrary, options: options)
        case .photos:
            return PHAsset.fetchAssets(with: .image, options: options)
        case .videos:
            return PHAsset.fetchAssets(with: .video, options: options)
        case .smartAlbum(let subtype):
            return fetchAssets(inSmartAlbum: subtype, options: options)
        case .userAlbum(let localIdentifier):
            let collections = PHAssetCollection.fetchAssetCollections(
                withLocalIdentifiers: [localIdentifier],
                options: nil
            )
            guard let collection = collections.firstObject else {
                return PHAsset.fetchAssets(withLocalIdentifiers: [], options: options)
            }
            return PHAsset.fetchAssets(in: collection, options: options)
        }
    }

    private func fetchAssets(
        inSmartAlbum subtype: PHAssetCollectionSubtype,
        options: PHFetchOptions
    ) -> PHFetchResult<PHAsset> {
        let collections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: subtype,
            options: nil
        )
        guard let collection = collections.firstObject else {
            return PHAsset.fetchAssets(withLocalIdentifiers: [], options: options)
        }
        return PHAsset.fetchAssets(in: collection, options: options)
    }

    private func makeFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false
        return options
    }

    func reminderSnapshot(
        relativeTo date: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent,
        includeByteEstimates: Bool = false
    ) -> ReminderLibrarySnapshot {
        let recentStart = calendar.date(byAdding: .day, value: -30, to: date) ?? date
        let totalPhotoCount = fetchPhotoCount()
        let recentPhotoCount = fetchPhotoCount(createdOnOrAfter: recentStart)

        guard includeByteEstimates else {
            return ReminderLibrarySnapshot(
                totalPhotoCount: totalPhotoCount,
                totalEstimatedBytes: 0,
                recentPhotoCount: recentPhotoCount,
                recentEstimatedBytes: 0,
                capturedAt: date
            )
        }

        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        let assets = PHAsset.fetchAssets(with: options)
        var totalEstimatedBytes: Int64 = 0
        var recentEstimatedBytes: Int64 = 0

        assets.enumerateObjects { asset, _, _ in
            let mediaType: MediaAsset.MediaType = asset.mediaType == .video ? .video : .photo
            let estimatedBytes = StorageEstimator.estimatedBytes(
                mediaType: mediaType,
                pixelWidth: asset.pixelWidth,
                pixelHeight: asset.pixelHeight,
                duration: asset.duration
            )

            totalEstimatedBytes += estimatedBytes
            if let creationDate = asset.creationDate, creationDate >= recentStart {
                recentEstimatedBytes += estimatedBytes
            }
        }

        return ReminderLibrarySnapshot(
            totalPhotoCount: totalPhotoCount,
            totalEstimatedBytes: totalEstimatedBytes,
            recentPhotoCount: recentPhotoCount,
            recentEstimatedBytes: recentEstimatedBytes,
            capturedAt: date
        )
    }

    private func fetchPhotoCount(createdOnOrAfter date: Date? = nil) -> Int {
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        if let date {
            options.predicate = NSPredicate(
                format: "mediaType == %d AND creationDate >= %@",
                PHAssetMediaType.image.rawValue,
                date as NSDate
            )
        } else {
            options.predicate = NSPredicate(
                format: "mediaType == %d",
                PHAssetMediaType.image.rawValue
            )
        }
        return PHAsset.fetchAssets(with: options).count
    }

    func mediaAsset(at index: Int) -> MediaAsset? {
        guard let photoAsset = photoAsset(at: index) else { return nil }
        let mediaType: MediaAsset.MediaType = photoAsset.mediaType == .video ? .video : .photo
        let estimatedBytes = StorageEstimator.estimatedBytes(
            mediaType: mediaType,
            pixelWidth: photoAsset.pixelWidth,
            pixelHeight: photoAsset.pixelHeight,
            duration: photoAsset.duration
        )

        return MediaAsset(
            id: photoAsset.localIdentifier,
            mediaType: mediaType,
            creationDate: photoAsset.creationDate,
            estimatedByteSize: estimatedBytes,
            duration: photoAsset.duration,
            pixelWidth: photoAsset.pixelWidth,
            pixelHeight: photoAsset.pixelHeight
        )
    }

    @discardableResult
    func requestImage(
        at index: Int,
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFill,
        networkAccessAllowed: Bool = false,
        completion: @escaping (UIImage?) -> Void
    ) -> PHImageRequestID? {
        guard let asset = photoAsset(at: index) else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = networkAccessAllowed

        return imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: contentMode,
            options: options
        ) { image, _ in
            completion(image)
        }
    }

    func cancelImageRequest(_ requestID: PHImageRequestID) {
        imageManager.cancelImageRequest(requestID)
    }

    @discardableResult
    func requestImage(
        localIdentifier: String,
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFill,
        networkAccessAllowed: Bool = false,
        completion: @escaping (UIImage?) -> Void
    ) -> PHImageRequestID? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = result.firstObject else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = networkAccessAllowed

        return imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: contentMode,
            options: options
        ) { image, _ in
            completion(image)
        }
    }

    func updateCache(around index: Int, targetSize: CGSize) {
        guard let fetchResult else { return }

        let lowerBound = max(0, index - 2)
        let upperBound = min(visibleAssetIndexes.count, index + 8)
        let nextRange = lowerBound..<upperBound
        guard cachedRange != nextRange else { return }

        imageManager.stopCachingImagesForAllAssets()
        let assets = nextRange.map { visibleIndex in
            fetchResult.object(at: visibleAssetIndexes[visibleIndex])
        }
        imageManager.startCachingImages(
            for: assets,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil
        )
        cachedRange = nextRange
    }

    @discardableResult
    func requestPlayerItem(
        localIdentifier: String,
        networkAccessAllowed: Bool = true,
        completion: @escaping (AVPlayerItem?) -> Void
    ) -> PHImageRequestID? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = result.firstObject, asset.mediaType == .video else { return nil }

        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = networkAccessAllowed

        return imageManager.requestPlayerItem(forVideo: asset, options: options) { playerItem, _ in
            completion(playerItem)
        }
    }

    private func photoAsset(at index: Int) -> PHAsset? {
        guard
            let fetchResult,
            visibleAssetIndexes.indices.contains(index)
        else {
            return nil
        }
        return fetchResult.object(at: visibleAssetIndexes[index])
    }

    func startObservingLibraryChanges() {
        guard !isObservingLibraryChanges else { return }
        isObservingLibraryChanges = true
        PHPhotoLibrary.shared().register(libraryChangeObserver)
    }
}

private final class PhotoLibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        NotificationCenter.default.post(name: PhotoLibraryService.libraryDidChangeNotification, object: nil)
    }
}
