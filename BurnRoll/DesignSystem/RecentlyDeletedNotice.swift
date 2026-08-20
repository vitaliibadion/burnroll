import SwiftUI

struct RecentlyDeletedNotice: View {
    var body: some View {
        Label {
            Text(BurnRollLegal.recentlyDeletedNotice)
            .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "clock.badge.exclamationmark")
                .foregroundStyle(BurnRollTheme.ember)
        }
        .font(.caption)
        .foregroundStyle(BurnRollTheme.secondaryText)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            BurnRollTheme.ember.opacity(0.075),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}
