import SwiftUI

// كل صورة في الصفحة (الصورة + العنوان + التاريخ)
struct Entry: Identifiable {
    let id = UUID()
    let title: String
    let date: String
}

struct MonthView: View {

    @Environment(\.dismiss) private var dismiss

    // الشهر والسنة، تجيهم من صفحة الدايري
    let month: String
    let year: Int

    // بيانات تجريبية مؤقتة، نبدلها بصور المستخدم وتحدياته بعدين
    let entries = [
        Entry(title: "Find something red", date: "12 Oct"),
        Entry(title: "Find something orange", date: "12 Oct"),
        Entry(title: "Find something blue", date: "12 Oct"),
        Entry(title: "Find something curved", date: "11 Oct"),
        Entry(title: "Find something golden", date: "11 Oct")
    ]

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(entries) { entry in
                        EntryCard(entry: entry)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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

            Text("\(String(entries.count)) entries")
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
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // مربع رمادي فاتح مكان الصورة، بعدين تنحط الصورة الحقيقية
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(white: 0.88))
                .frame(height: 140)

            Text(entry.title)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 6)

            Text(entry.date)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    MonthView(month: "October", year: 2026)
}

