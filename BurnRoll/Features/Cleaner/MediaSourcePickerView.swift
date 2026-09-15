import SwiftUI

struct MediaSourcePickerView: View {
    private enum CheckpointAlert: Identifiable {
        case resetConfirmation
        case resetFailure(String)

        var id: String {
            switch self {
            case .resetConfirmation: "reset-confirmation"
            case .resetFailure: "reset-failure"
            }
        }
    }

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var checkpointAlert: CheckpointAlert?

    var body: some View {
        NavigationStack {
            List {
                Section("Review status") {
                    ForEach(PhotoLibraryService.ReviewScope.allCases) { reviewScope in
                        reviewScopeRow(reviewScope)
                    }
                }

                ForEach(visibleSections) { section in
                    Section(section.localizedTitle) {
                        ForEach(sources(in: section)) { source in
                            sourceRow(source)
                        }
                    }
                }

                Section("Bookmark") {
                    HStack(spacing: 13) {
                        BurnRollIconTile(
                            systemName: "bookmark.fill",
                            role: .keep,
                            size: 40,
                            symbolSize: 17
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Review checkpoint")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(BurnRollTheme.primaryText)
                            Text(bookmarkSummary)
                                .font(.caption)
                                .foregroundStyle(BurnRollTheme.secondaryText)
                        }
                    }

                    Button("Reset reviewed bookmark", role: .destructive) {
                        checkpointAlert = .resetConfirmation
                    }
                    .disabled(reviewedItemCount == 0)
                }

                Section {
                    Text(
                        "BurnRoll opens Not reviewed by default, so you continue where you stopped and new photos appear automatically. Categories and albums come from your Photos library. Hidden and Recently Deleted items are excluded."
                    )
                        .font(.caption)
                        .foregroundStyle(BurnRollTheme.secondaryText)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .burnRollBackground()
            .navigationTitle("Choose media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                appState.refreshMediaCatalog()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .alert(item: $checkpointAlert) { alert in
            switch alert {
            case .resetConfirmation:
                Alert(
                    title: Text("Do you really want to reset your bookmark?"),
                    message: Text(
                        "Every item will become Not reviewed again. Your current Keep and Burn decisions will remain available in Review until this session ends."
                    ),
                    primaryButton: .destructive(Text("Reset bookmark")) {
                        if appState.resetReviewCheckpoint() {
                            Haptics.threshold()
                        } else {
                            checkpointAlert = .resetFailure(
                                appState.reviewCheckpointErrorMessage
                                    ?? String(localized: "The review bookmark could not be reset.")
                            )
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .resetFailure(let message):
                Alert(
                    title: Text("Bookmark wasn’t reset"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var reviewedItemCount: Int {
        appState.photoLibrary.itemCount(for: .reviewed)
    }

    private var bookmarkSummary: String {
        "\(reviewedItemCount.formatted()) \(reviewedItemCount == 1 ? String(localized: "item remembered") : String(localized: "items remembered"))"
    }

    private var visibleSections: [PhotoLibraryService.MediaSource.Section] {
        PhotoLibraryService.MediaSource.Section.allCases.filter { !sources(in: $0).isEmpty }
    }

    private func sources(
        in section: PhotoLibraryService.MediaSource.Section
    ) -> [PhotoLibraryService.MediaSource] {
        appState.photoLibrary.availableSources.filter { $0.section == section }
    }

    private func reviewScopeRow(
        _ reviewScope: PhotoLibraryService.ReviewScope
    ) -> some View {
        let isSelected = reviewScope == appState.photoLibrary.selectedReviewScope
        let itemCount = appState.photoLibrary.itemCount(for: reviewScope)

        return Button {
            appState.selectReviewScope(reviewScope)
            Haptics.keep()
            dismiss()
        } label: {
            HStack(spacing: 13) {
                BurnRollIconTile(
                    systemName: reviewScope.systemImage,
                    role: reviewScope == .notReviewed ? .photo : .keep,
                    size: 40,
                    symbolSize: 17,
                    isSelected: isSelected
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(reviewScope.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(BurnRollTheme.primaryText)
                    Text(L10n.items(itemCount))
                        .font(.caption)
                        .foregroundStyle(BurnRollTheme.secondaryText)
                }

                Spacer()

                if isSelected {
                    BurnRollSymbol(
                        systemName: "checkmark.circle.fill",
                        size: 21,
                        weight: .bold,
                        role: .keep
                    )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(BurnRollTheme.surface)
        .accessibilityLabel(
            "\(reviewScope.title), \(L10n.items(itemCount))\(isSelected ? ", \(String(localized: "selected"))" : "")"
        )
    }

    private func sourceRow(_ source: PhotoLibraryService.MediaSource) -> some View {
        let isSelected = source.id == appState.photoLibrary.selectedSource.id

        return Button {
            appState.selectMediaSource(source)
            Haptics.keep()
            dismiss()
        } label: {
            HStack(spacing: 13) {
                BurnRollIconTile(
                    systemName: source.systemImage,
                    role: .photo,
                    size: 40,
                    symbolSize: 17,
                    isSelected: isSelected
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(source.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(BurnRollTheme.primaryText)
                    Text(L10n.items(source.itemCount))
                        .font(.caption)
                        .foregroundStyle(BurnRollTheme.secondaryText)
                }

                Spacer()

                if isSelected {
                    BurnRollSymbol(
                        systemName: "checkmark.circle.fill",
                        size: 21,
                        weight: .bold,
                        role: .keep
                    )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(BurnRollTheme.surface)
        .accessibilityLabel(
            "\(source.title), \(L10n.items(source.itemCount))\(isSelected ? ", \(String(localized: "selected"))" : "")"
        )
    }
}
