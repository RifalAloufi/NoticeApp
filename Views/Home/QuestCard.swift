import SwiftUI

struct QuestCard: View {
    let eyebrow: String
    let title: String
    let progressLabel: String
    let counter: String
    let completed: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Palette.mintStrong, Palette.mint],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 0) {
                Text(eyebrow)
                    .font(Typography.inter(12, semibold: true))
                    .tracking(1)
                    .foregroundStyle(Palette.brandPrimary)
                    .frame(height: 15)

                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.black)
                    // Longer quest titles shrink a little instead of being cut off
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(height: 34)
                    .padding(.top, 12)

                ProgressSegments(completed: completed)
                    .padding(.top, 13)

                Text(progressLabel)
                    .font(Typography.inter(12))
                    .tracking(1)
                    .foregroundStyle(Palette.progressLabel)
                    .frame(height: 15)
                    .padding(.top, 13)
            }
            .padding(.leading, 23)
            .padding(.trailing, 23)
            .padding(.top, 30)

            CounterChip(text: counter)
                .offset(x: 319, y: 33)
        }
        .frame(height: 162)
    }
}
