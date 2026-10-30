import SwiftUI

struct MonthView: View {

    @Environment(\.dismiss) private var dismiss

    // الشهر والسنة، تجيهم من صفحة الدايري
    let month: String
    let year: Int

    // صور هذا الشهر من الجهاز (الأحدث أول)
    @State private var photos: [SavedPhoto] = []

    private static let monthNames = ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]

    // 2 columns on iPhone, more on wider screens
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 20)]

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                if photos.isEmpty {
                    Text("No photos in \(month) yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(photos) { photo in
                            // لما تضغطين على الصورة تفتح تفاصيلها
                            NavigationLink(value: DiaryRoute.photo(photo.id)) {
                                EntryCard(photo: photo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .readableWidth(900)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: load)
    }

    // يقرأ صور هذا الشهر والسنة
    private func load() {
        guard let index = Self.monthNames.firstIndex(of: month) else { photos = []; return }
        photos = PhotoStorage.loadAll().filter {
            diaryCalendar.component(.year, from: $0.date) == year &&
            diaryCalendar.component(.month, from: $0.date) == index + 1
        }
    }

    var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(deepGreen)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }

            Text("\(month) \(String(year))")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(deepGreen)
                .padding(.top, 8)

            Text(photos.count == 1 ? "1 entry" : "\(photos.count) entries")
                .font(.subheadline)
                .foregroundColor(deepGreen)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.69, green: 0.86, blue: 0.72),
                         Color(red: 0.90, green: 0.96, blue: 0.91)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(
                UnevenRoundedRectangle(bottomLeadingRadius: 40,
                                       bottomTrailingRadius: 40)
            )
            .ignoresSafeArea(edges: .top)
        )
    }
}

// بطاقة وحدة: الصورة + العنوان + التاريخ
struct EntryCard: View {
    let photo: SavedPhoto

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // الصورة الحقيقية (أو مربع رمادي لو ما انقرأت)
            Color(white: 0.88)
                .frame(height: 140)
                .overlay(
                    Group {
                        if let image = PhotoStorage.thumbnail(for: photo) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 28))

            Text(photo.quest)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(1)
                .padding(.top, 6)

            Text(photo.dayText)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NavigationStack {
        MonthView(month: "October", year: 2026)
    }
}
