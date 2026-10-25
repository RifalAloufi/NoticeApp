import SwiftUI

struct TopPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GreetingHeader(date: "Mon 10 Oct", greeting: "Good evening")
                .padding(.leading, 34)
                .padding(.top, 92)

            QuestCard(
                eyebrow: "TODAY'S QUESTS",
                title: "Find something orange",
                progressLabel: "0 of 3 quests done",
                counter: "0 / 3",
                completed: 0
            )
            .padding(.top, 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 338, alignment: .top)
        .background(
            UnevenRoundedRectangle(bottomLeadingRadius: 44, bottomTrailingRadius: 44, style: .continuous)
                .fill(Palette.mint)
        )
    }
}
