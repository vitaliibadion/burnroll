import SwiftUI

struct PaywallOfferReel: View {
    var isActive = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var anchor = Date()

    private let slogans = [
        String(localized: "Swipe. Decide. Done."),
        String(localized: "Keep what matters."),
        String(localized: "Review before you delete."),
        String(localized: "Clear space your way.")
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !isActive || reduceMotion)) { context in
            let time = displayTime(at: context.date)
            offer(at: time)
        }
        .frame(maxWidth: 280)
        .frame(height: 318)
        .onAppear { if isActive { anchor = Date() } }
        .onChange(of: isActive) { _, active in
            if active { anchor = Date() }
        }
        .accessibilityHidden(true)
    }

    private func displayTime(at date: Date) -> CGFloat {
        if reduceMotion || !isActive { return 1.2 }
        return CGFloat(date.timeIntervalSince(anchor).truncatingRemainder(dividingBy: 2.8))
    }

    private func offer(at time: CGFloat) -> some View {
        let pulse = 0.5 + 0.5 * sin(Double(time) * .pi * 1.4)
        let sloganIndex = min(slogans.count - 1, Int(time / 0.7) % slogans.count)

        return ZStack {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(BurnRollTheme.surface)
                .shadow(color: BurnRollTheme.ember.opacity(0.18), radius: 28, y: 16)

            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(BurnRollTheme.ember.opacity(0.14 + 0.10 * pulse))
                        .frame(width: 128, height: 128)
                    Circle()
                        .stroke(BurnRollTheme.burn.opacity(0.35), lineWidth: 3)
                        .frame(width: 118, height: 118)
                        .scaleEffect(0.96 + 0.04 * pulse)

                    VStack(spacing: -2) {
                        Text("3")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(BurnRollTheme.burn)
                        Text(String(localized: "days free"))
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(BurnRollTheme.ember)
                    }
                }

                Text(slogans[sloganIndex])
                    .font(.headline.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BurnRollTheme.primaryText)
                    .frame(height: 44)
                    .padding(.horizontal, 12)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 8) {
                    perk(String(localized: "No payment now"))
                    perk(String(localized: "Unlimited access"))
                }
                .padding(.horizontal, 12)
            }
            .padding(16)
        }
    }

    private func perk(_ title: String) -> some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(BurnRollTheme.keep, in: Capsule())
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

struct PaywallTrialReel: View {
    var isActive = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var anchor = Date()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !isActive || reduceMotion)) { context in
            let time = displayTime(at: context.date)
            trial(at: time)
        }
        .frame(maxWidth: 280)
        .frame(height: 318)
        .onAppear { if isActive { anchor = Date() } }
        .onChange(of: isActive) { _, active in
            if active { anchor = Date() }
        }
        .accessibilityHidden(true)
    }

    private func displayTime(at date: Date) -> CGFloat {
        if reduceMotion || !isActive { return 1.8 }
        return CGFloat(date.timeIntervalSince(anchor).truncatingRemainder(dividingBy: 2.8))
    }

    private func trial(at time: CGFloat) -> some View {
        let step: Int = {
            if time < 0.7 { return 0 }
            if time < 1.5 { return 1 }
            return 2
        }()

        return ZStack {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(BurnRollTheme.surface)
                .shadow(color: BurnRollTheme.keep.opacity(0.16), radius: 28, y: 16)

            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)

            VStack(alignment: .leading, spacing: 0) {
                trialStep(
                    index: 0,
                    active: step >= 0,
                    title: String(localized: "Today"),
                    message: String(localized: "Unlimited Keep and Burn. Nothing to pay."),
                    color: BurnRollTheme.keep
                )
                connector(lit: step >= 1)
                trialStep(
                    index: 1,
                    active: step >= 1,
                    title: String(localized: "In 2 days"),
                    message: String(localized: "A reminder before charging. Cancel if you want."),
                    color: BurnRollTheme.ember
                )
                connector(lit: step >= 2)
                trialStep(
                    index: 2,
                    active: step >= 2,
                    title: String(localized: "Unless you cancel"),
                    message: String(localized: "Your plan starts. Cancel earlier in Subscriptions."),
                    color: BurnRollTheme.burn
                )
            }
            .padding(20)
        }
    }

    private func trialStep(
        index: Int,
        active: Bool,
        title: String,
        message: String,
        color: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(active ? color : BurnRollTheme.primaryText.opacity(0.12))
                    .frame(width: 28, height: 28)
                Text("\(index + 1)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(active ? .white : BurnRollTheme.secondaryText)
            }
            .scaleEffect(active ? 1 : 0.92)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(active ? BurnRollTheme.primaryText : BurnRollTheme.secondaryText)
                Text(message)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BurnRollTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .opacity(active ? 1 : 0.45)
        .padding(.vertical, 6)
    }

    private func connector(lit: Bool) -> some View {
        Rectangle()
            .fill(lit ? BurnRollTheme.ember : BurnRollTheme.primaryText.opacity(0.12))
            .frame(width: 3, height: 18)
            .padding(.leading, 12)
    }
}
