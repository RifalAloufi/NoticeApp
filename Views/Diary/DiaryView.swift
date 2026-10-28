import SwiftUI

let deepGreen = Color(red: 16/255, green: 58/255, blue: 44/255)

struct DiaryView: View {

    // أمر الرجوع للصفحة اللي قبل
    @Environment(\.dismiss) private var dismiss

    // السنة المختارة، تبدأ بالسنة الحالية
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    // السنة اللي بدأ فيها المستخدم يستخدم التطبيق
    // مؤقتاً = السنة الحالية، وصفحة الـ logic بعدين تحددها
    let startYear = Calendar.current.component(.year, from: Date())

    // السنوات اللي تظهر في القايمة (من سنة البداية لين الحين)
    var years: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array(startYear...current).reversed()
    }

    let months = ["January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "October", "November", "December"]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(months, id: \.self) { month in
                        // لما تضغطين على الشهر يفتح صفحته
                        NavigationLink {
                            MonthView(month: month, year: selectedYear)
                        } label: {
                            MonthCard(name: month)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        // نخفي شريط الرجوع الجاهز لأن عندنا زرنا الخاص
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(deepGreen)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.5))
                        .clipShape(Circle())
                }

                Spacer()

                Text("Diary")
                    .font(.headline)
                    .foregroundColor(deepGreen)

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }

            // السنة + سهم تغيير السنة
            Menu {
                ForEach(years, id: \.self) { year in
                    Button(String(year)) {
                        selectedYear = year
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(String(selectedYear))
                        .font(.system(size: 52, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(deepGreen)
            }
            .padding(.top, 8)

            Text("your moments in your eyes")
                .font(.footnote)
                .foregroundColor(deepGreen)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
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

// بطاقة الشهر: 3 صور فوق بعض + اسم الشهر
struct MonthCard: View {
    let name: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // الصورة الخلفية (فوق)
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.94))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-3))
                    .offset(x: 0, y: -8)

                // الصورة الوسطى (يمين)
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.88))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(5))
                    .offset(x: 12, y: -4)

                // الصورة الأمامية (يسار)
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.82))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-4))
                    .offset(x: -8, y: 0)
            }
            .frame(width: 100, height: 96)

            Text(name)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    NavigationStack {
        DiaryView()
    }
}

