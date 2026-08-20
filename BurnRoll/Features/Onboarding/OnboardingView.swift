import SwiftUI

struct OnboardingView: View {
    private struct Page {
        let symbol: String
        let title: String
        let message: String
        let accent: Color
    }

    private let pages = [
        Page(
            symbol: "photo.stack.fill",
            title: "Burn the clutter.\nKeep the memories.",
            message: "Clear your camera roll one thoughtful decision at a time.",
            accent: BurnRollTheme.burn
        ),
        Page(
            symbol: "hand.draw.fill",
            title: "Swipe. Decide. Done.",
            message: "Swipe left to Burn. Swipe right to Keep.",
            accent: BurnRollTheme.keep
        ),
        Page(
            symbol: "checkmark.shield.fill",
            title: "Nothing burns by accident.",
            message: "Review everything before deletion.",
            accent: BurnRollTheme.ember
        )
    ]

    let onComplete: () -> Void
    @State private var pageIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $pageIndex) {
                ForEach(pages.indices, id: \.self) { index in
                    page(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.smooth, value: pageIndex)

            PrimaryButton(
                title: pageIndex == pages.count - 1 ? "Continue to Photos" : "Continue",
                systemImage: pageIndex == pages.count - 1 ? "photo.on.rectangle" : "arrow.right"
            ) {
                if pageIndex == pages.count - 1 {
                    onComplete()
                } else {
                    withAnimation(.snappy) {
                        pageIndex += 1
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
        }
        .burnRollBackground()
        .onAppear {
            AnalyticsService.log(.onboardingStarted)
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
                        role: page.symbol == "checkmark.shield.fill" ? .keep : .burn
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
