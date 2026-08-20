import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PrivacyFootnote()

                ForEach(BurnRollLegal.policySections) { section in
                    policySection(title: section.title, text: section.text)
                }

                RecentlyDeletedNotice()

                Link("Open privacy policy on the web", destination: BurnRollLegal.privacyPolicyURL)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BurnRollTheme.keep)

                Text("This disclosure describes BurnRoll version \(BurnRollLegal.policyVersion).")
                    .font(.caption)
                    .foregroundStyle(BurnRollTheme.secondaryText)
            }
            .padding(20)
        }
        .burnRollBackground()
        .navigationTitle("Privacy policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.body)
                .foregroundStyle(BurnRollTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
