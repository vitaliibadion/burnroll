import SwiftUI

struct OnboardingView: View {
    private struct Page {
        let kind: OnboardingDemoKind
        let title: String
        let message: String
        let accent: Color
    }

    var isReplay: Bool = false
    var hasReviewedMedia: Bool = false
    let onComplete: () -> Void
    @State private var pageIndex = 0

    private var pages: [Page] {
        [
            Page(
                kind: .swipe,
                title: isReplay
                    ? String(localized: "A quick refresher.")
                    : String(localized: "Swipe. Decide. Done."),
                message: isReplay
                    ? (hasReviewedMedia
                        ? String(localized: "Your reviewed items stay marked. This is just a reminder of how BurnRoll works.")
                        : String(localized: "Swipe through your camera roll one decision at a time. Your library and settings stay as they are."))
                    : String(localized: "Keep or burn with one gesture. Nothing deletes until you confirm."),
                accent: BurnRollTheme.keep
            ),
            Page(
                kind: .undo,
                title: String(localized: "Undo a Keep or Burn."),
                message: String(localized: "The middle button takes back your last decision. That item leaves Reviewed and the burn list, so you can choose again."),
                accent: BurnRollTheme.ember
            ),
            Page(
                kind: .review,
                title: String(localized: "Review before you delete."),
                message: hasReviewedMedia
                    ? String(localized: "Items you've already reviewed stay marked. Confirm again before anything is deleted.")
                    : String(localized: "See every thumbnail. Drop anything you still want. Then confirm."),
                accent: BurnRollTheme.burn
            ),
            Page(
                kind: .storage,
                title: String(localized: "Clear space your way."),
                message: String(localized: "Watch the storage you selected add up before anything is burned."),
                accent: BurnRollTheme.ember
            )
        ]
    }

    private var isLastPage: Bool {
        pageIndex == pages.count - 1
    }

    private var primaryTitle: String {
        if isLastPage {
            isReplay ? String(localized: "Got it") : String(localized: "Continue")
        } else {
            String(localized: "Continue")
        }
    }

    private var primarySystemImage: String {
        if isLastPage {
            isReplay ? "checkmark" : "arrow.right"
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
                    page(pages[index], index: index)
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

    private func page(_ page: Page, index: Int) -> some View {
        GeometryReader { geo in
            let compact = geo.size.height < 620
            VStack(spacing: compact ? 16 : 22) {
                Spacer(minLength: 4)

                OnboardingDemoReel(
                    kind: page.kind,
                    isActive: pageIndex == index,
                    accent: page.accent
                )
                .scaleEffect(compact ? 0.9 : 1, anchor: .center)

                VStack(spacing: compact ? 10 : 14) {
                    Text(page.title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BurnRollTheme.primaryText)
                        .minimumScaleFactor(0.8)

                    Text(page.message)
                        .font(compact ? .body : .title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BurnRollTheme.secondaryText)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 4)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .padding(.horizontal, 8)
    }
}

#Preview("First run") {
    OnboardingView(onComplete: {})
}

#Preview("Replay") {
    OnboardingView(isReplay: true, hasReviewedMedia: true, onComplete: {})
}
