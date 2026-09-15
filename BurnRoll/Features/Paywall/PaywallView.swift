import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptions
    let onComplete: () -> Void
    @State private var pageIndex = 0

    private var isLastPage: Bool { pageIndex == 2 }

    private var isWeeklyTrial: Bool {
        subscriptions.selectedPlan.includesFreeTrial
    }

    private var primaryTitle: String {
        if isLastPage {
            if subscriptions.isPurchasing {
                String(localized: "Starting…")
            } else if isWeeklyTrial {
                String(localized: "Start 3-day free trial")
            } else {
                String(localized: "Subscribe now")
            }
        } else {
            String(localized: "Continue")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $pageIndex) {
                offerPage.tag(0)
                trialPage.tag(1)
                plansPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.smooth, value: pageIndex)

            if let errorMessage = subscriptions.errorMessage, isLastPage {
                Text(errorMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(BurnRollTheme.burn)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            PrimaryButton(
                title: primaryTitle,
                systemImage: isLastPage ? (isWeeklyTrial ? "flame.fill" : "checkmark") : "arrow.right",
                isEnabled: !subscriptions.isPurchasing
            ) {
                if isLastPage {
                    Task { await startSelectedPlan() }
                } else {
                    withAnimation(.snappy) {
                        pageIndex += 1
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, isLastPage ? 8 : 18)

            if isLastPage {
                legalFooter
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }
        }
        .burnRollBackground()
        .task {
            subscriptions.start()
        }
        .onAppear {
            AnalyticsService.log(.paywallStarted)
        }
    }

    private var offerPage: some View {
        paywallPage(
            animation: PaywallOfferReel(isActive: pageIndex == 0),
            title: String(localized: "Try BurnRoll free for 3 days."),
            message: String(localized: "No payment now. Unlimited Keep and Burn while you clear space your way.")
        )
    }

    private var trialPage: some View {
        paywallPage(
            animation: PaywallTrialReel(isActive: pageIndex == 1),
            title: String(localized: "How the free trial works."),
            message: String(localized: "Unlimited access from today. You're charged in 2 days unless you cancel first.")
        )
    }

    private var plansPage: some View {
        GeometryReader { geo in
            let compact = geo.size.height < 700
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: compact ? 10 : 14) {
                    Text(String(localized: "Choose your plan."))
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .padding(.top, 8)

                    if isWeeklyTrial {
                        freeTrialBanner
                    }

                    VStack(spacing: 10) {
                        ForEach(SubscriptionPlan.allCases) { plan in
                            planRow(plan)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .padding(.horizontal, 16)
    }

    private var freeTrialBanner: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(BurnRollTheme.keep)
                    Text(String(localized: "Free trial selected"))
                        .font(.headline.weight(.bold))
                }
                Text(String(localized: "3 days only. Cancel anytime."))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BurnRollTheme.secondaryText)
            }
            Spacer(minLength: 8)
            Text(subscriptions.trialPriceText)
                .font(.system(.title, design: .rounded, weight: .heavy))
                .foregroundStyle(BurnRollTheme.keep)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            BurnRollTheme.keep.opacity(0.10),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(BurnRollTheme.keep.opacity(0.45), lineWidth: 2)
        }
        .accessibilityElement(children: .combine)
    }

    private func planRow(_ plan: SubscriptionPlan) -> some View {
        let selected = subscriptions.selectedPlan == plan
        let price = subscriptions.priceText(for: plan)
        return Button {
            withAnimation(.snappy(duration: 0.28)) {
                subscriptions.selectedPlan = plan
            }
            Haptics.keep()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.headline.weight(.bold))
                        if plan.isRecommended {
                            Text(String(localized: "Best value"))
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(BurnRollTheme.ember, in: Capsule())
                        }
                    }
                    Text(planSubtitle(plan, price: price))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BurnRollTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text(price)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(BurnRollTheme.primaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                selected ? BurnRollTheme.burn.opacity(0.10) : BurnRollTheme.surface,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        selected ? BurnRollTheme.burn : BurnRollTheme.primaryText.opacity(0.08),
                        lineWidth: selected ? 2 : 1
                    )
            }
            .shadow(color: selected ? BurnRollTheme.burn.opacity(0.16) : .clear, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func planSubtitle(_ plan: SubscriptionPlan, price: String) -> String {
        switch plan {
        case .weekly:
            String(localized: "3 days free, then \(price) per week")
        case .monthly, .yearly:
            String(localized: "Pay now · \(plan.periodLabel)")
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 8) {
            Button(String(localized: "Restore purchases")) {
                Task {
                    if await subscriptions.restore() {
                        onComplete()
                    }
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(BurnRollTheme.secondaryText)

            Text(
                isWeeklyTrial
                    ? String(localized: "Payment is charged to your Apple Account after the 3-day trial. The plan renews automatically unless you cancel at least 24 hours before the period ends. Cancel in Settings → Apple Account → Subscriptions.")
                    : String(localized: "Payment is charged to your Apple Account at confirmation. The plan renews automatically unless you cancel at least 24 hours before the period ends. Cancel in Settings → Apple Account → Subscriptions.")
            )
                .font(.caption2)
                .foregroundStyle(BurnRollTheme.secondaryText)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link(String(localized: "Privacy policy"), destination: BurnRollLegal.privacyPolicyURL)
                Link(String(localized: "Terms of Use"), destination: BurnRollLegal.termsOfUseURL)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(BurnRollTheme.ember)
        }
    }

    private func paywallPage<Animation: View>(
        animation: Animation,
        title: String,
        message: String
    ) -> some View {
        GeometryReader { geo in
            let compact = geo.size.height < 620
            VStack(spacing: compact ? 16 : 22) {
                Spacer(minLength: 4)
                animation
                    .scaleEffect(compact ? 0.9 : 1, anchor: .center)
                VStack(spacing: compact ? 10 : 14) {
                    Text(title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.78)
                    Text(message)
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

    private func startSelectedPlan() async {
        if await subscriptions.purchaseSelected() {
            if isWeeklyTrial {
                AnalyticsService.log(.trialStarted)
            }
            onComplete()
        }
    }
}

#Preview {
    PaywallView(onComplete: {})
        .environment(SubscriptionService())
}
