import SwiftUI

struct DiaryPreview: View {
    // Width ÷ height of each photo tile (slightly tall, like a phone photo)
    static let tileRatio: CGFloat = 0.72
    static let tilesPerRow = 3

    let items: [DiaryItem]
    var onSeeAll: () -> Void = {}
    var onOpen: (DiaryItem) -> Void = { _ in }

    // Newest first
    private var newestFirst: [DiaryItem] {
        items.sorted { $0.takenAt > $1.takenAt }
    }

    // First row: today's photos
    private var todayRow: [DiaryItem] {
        Array(newestFirst.filter { Calendar.current.isDateInToday($0.takenAt) }.prefix(Self.tilesPerRow))
    }

    // Second row: yesterday's photos
    private var yesterdayRow: [DiaryItem] {
        Array(newestFirst.filter { Calendar.current.isDateInYesterday($0.takenAt) }.prefix(Self.tilesPerRow))
    }

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

            // Two rows of three, no scrolling. Missing photos show a placeholder.
            VStack(spacing: 10) {
                row(todayRow)
                row(yesterdayRow)
            }
        }
    }

    private func row(_ photos: [DiaryItem]) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(0..<Self.tilesPerRow, id: \.self) { index in
                if index < photos.count {
                    let item = photos[index]
                    Button {
                        onOpen(item)
                    } label: {
                        DiaryEntryCard(item: item)
                    }
                    .buttonStyle(.plain)
                } else {
                    DiaryEmptySlot()
                }
            }
        }
    }
}

struct DiaryEntryCard: View {
    let item: DiaryItem

    var body: some View {
        Color.clear
            .aspectRatio(DiaryPreview.tileRatio, contentMode: .fit)
            .overlay(
                item.photo
                    .resizable()
                    .scaledToFill()
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: .infinity)
    }
}

struct DiaryEmptySlot: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Palette.placeholderFill)
            .aspectRatio(DiaryPreview.tileRatio, contentMode: .fit)
            .overlay(DashedOutline(cornerRadius: 16, dash: [6, 4]))
            .overlay(
                Image(systemName: "viewfinder.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(Palette.placeholderStroke)
            )
            .frame(maxWidth: .infinity)
    }
}

#Preview("Today and yesterday") {
    DiaryPreview(items: [.sampleOrange, .sampleSunset, .sampleForest, .sampleDesert, .sampleNight])
        .padding(20)
}

#Preview("Only yesterday") {
    DiaryPreview(items: [.sampleForest, .sampleDesert])
        .padding(20)
}
