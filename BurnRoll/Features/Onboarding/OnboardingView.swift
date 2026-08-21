import SwiftUI

struct OnboardingView: View {
    private struct Page {
        let symbol: String
        let title: String
        let message: String
        let accent: Color
        let role: BurnRollSymbolRole
    }

    var isReplay: Bool = false
    var hasReviewedMedia: Bool = false
    let onComplete: () -> Void
    @State private var pageIndex = 0

    private var pages: [Page] {
        [
            Page(
                symbol: "photo.stack.fill",
                title: isReplay
                    ? "A quick refresher."
                    : "Burn the clutter.\nKeep the memories.",
                message: isReplay
                    ? (hasReviewedMedia
                        ? "Your reviewed items stay marked. This is just a reminder of how BurnRoll works."
                        : "Swipe through your camera roll one decision at a time. Your library and settings stay as they are.")
                    : "Clear your camera roll one thoughtful decision at a time.",
                accent: BurnRollTheme.burn,
                role: .burn
            ),
            Page(
                symbol: "hand.draw.fill",
                title: "Swipe. Decide. Done.",
                message: "Swipe left to Burn. Swipe right to Keep. The first photo will show you both.",
                accent: BurnRollTheme.keep,
                role: .keep
            ),
            Page(
                symbol: "arrow.uturn.backward",
                title: "Undo a Keep or Burn.",
                message: "The middle button takes back your last decision. That item leaves Reviewed and the burn list, so you can choose again.",
                accent: BurnRollTheme.ember,
                role: .neutral
            ),
            Page(
                symbol: "checkmark.shield.fill",
                title: "Nothing burns by accident.",
                message: hasReviewedMedia
                    ? "Items you've already reviewed stay marked. Confirm again before anything is deleted."
                    : "Review everything before deletion.",
                accent: BurnRollTheme.ember,
                role: .keep
            )
        ]
    }

    private var isLastPage: Bool {
        pageIndex == pages.count - 1
    }

    private var primaryTitle: String {
        if isLastPage {
            isReplay ? "Got it" : "Continue to Photos"
        } else {
            "Continue"
        }
    }

    private var primarySystemImage: String {
        if isLastPage {
            isReplay ? "checkmark" : "photo.on.rectangle"
        } else {
            "arrow.right"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isReplay {
                HStack {
                    Spacer()
                    Button("Close") {
                        onComplete()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(BurnRollTheme.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
            }

            TabView(selection: $pageIndex) {
                ForEach(pages.indices, id: \.self) { index in
                    page(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.smooth, value: pageIndex)

            PrimaryButton(
                title: primaryTitle,
                systemImage: primarySystemImage
            ) {
                if isLastPage {
                    onComplete()
                } else {
                    withAnimation(.snappy) {
                        pageIndex += 1
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
            .zIndex(1)
        }
        .burnRollBackground()
        .onAppear {
            if !isReplay {
                AnalyticsService.log(.onboardingStarted)
            }
        }
    }

    private func page(_ page: Page) -> some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 46, style: .continuous)
                    .fill(BurnRollTheme.surface)
                    .frame(width: 250, height: 250)
                    .shadow(color: page.accent.opacity(0.17), radius: 35, y: 18)

                Circle()
                    .fill(page.accent.opacity(0.13))
                    .frame(width: 166, height: 166)

                if page.symbol == "photo.stack.fill" {
                    BurnRollBrandMark(size: 132)
                } else {
                    BurnRollSymbol(
                        systemName: page.symbol,
                        size: 76,
                        weight: .medium,
                        role: page.role
                    )
                }
            }
            .accessibilityHidden(true)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BurnRollTheme.primaryText)

                Text(page.message)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BurnRollTheme.secondaryText)
                    .padding(.horizontal, 22)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
