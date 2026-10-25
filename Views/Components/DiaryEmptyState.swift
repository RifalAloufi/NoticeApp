import SwiftUI

struct DiaryEmptyState: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ForEach(1...3, id: \.self) { number in
                    Text("\(number)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Palette.placeholderStroke)
                        .frame(width: 64, height: 80.4)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(DashedOutline(cornerRadius: 16, dash: [4, 3]))
                }
            }

            Text("Your diary starts here")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .frame(height: 20)
                .padding(.top, 24.6)

            Text("Capture today’s quest and your first photo will appear here. Each day brings three quests.")
                .font(.system(size: 14))
                .lineSpacing(-0.8)
                .foregroundStyle(Palette.secondaryLabel)
                .multilineTextAlignment(.center)
                .frame(width: 300, height: 32)
                .padding(.top, 17)
        }
        .padding(.top, 30)
        .frame(maxWidth: .infinity)
        .frame(height: 270, alignment: .top)
        .background(Palette.placeholderFill, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(DashedOutline(cornerRadius: 20, dash: [6, 4]))
    }
}
