import SwiftUI

struct DiaryPreview: View {
    let items: [DiaryItem]
    var onSeeAll: () -> Void = {}
    var onOpen: (DiaryItem) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your diary")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)

                Spacer()

                Button(action: onSeeAll) {
                    HStack(spacing: 6) {
                        Text("See all")
                            .font(.system(size: 15))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .top, spacing: 12) {
                ForEach(items.prefix(2)) { item in
                    Button {
                        onOpen(item)
                    } label: {
                        DiaryEntryCard(item: item)
                    }
                    .buttonStyle(.plain)
                }

                if items.count < 2 {
                    DiaryEmptySlot()
                }
            }
        }
    }
}

struct DiaryEntryCard: View {
    let item: DiaryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    item.photo
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.bottom, 6)

            Text(item.questName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)

            Text(item.date)
                .font(.system(size: 12))
                .foregroundStyle(Palette.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DiaryEmptySlot: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Palette.placeholderFill)
            .aspectRatio(1, contentMode: .fit)
            .overlay(DashedOutline(cornerRadius: 20, dash: [6, 4]))
            .overlay(
                Image(systemName: "viewfinder.circle")
                    .font(.system(size: 30))
                    .foregroundStyle(Palette.placeholderStroke)
            )
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    DiaryPreview(items: [.sampleRed])
        .padding(20)
}
