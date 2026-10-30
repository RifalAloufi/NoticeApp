import SwiftUI

let deepGreen = Color(red: 16/255, green: 58/255, blue: 44/255)

// The diary shows Gregorian months and years (January ... December), whatever the phone's calendar is
let diaryCalendar = Calendar(identifier: .gregorian)

struct DiaryView: View {

    // أمر الرجوع للصفحة اللي قبل
    @Environment(\.dismiss) private var dismiss

    // السنة المختارة، تبدأ بالسنة الحالية
    @State private var selectedYear = diaryCalendar.component(.year, from: Date())

    // كل الصور المحفوظة (نعرض منها صور كل شهر على بطاقته)
    @State private var allPhotos: [SavedPhoto] = PhotoStorage.loadAll()

    // السنة اللي بدأ فيها المستخدم يستخدم التطبيق = سنة أقدم صورة محفوظة
    // (لو ما فيه صور: السنة الحالية)
    let startYear: Int = {
        let current = diaryCalendar.component(.year, from: Date())
        let oldest = PhotoStorage.loadAll()
            .map { diaryCalendar.component(.year, from: $0.date) }
            .min()
        return min(oldest ?? current, current)
    }()

    // السنوات اللي تظهر في القايمة (من سنة البداية لين الحين)
    var years: [Int] {
        let current = diaryCalendar.component(.year, from: Date())
        return Array(startYear...current).reversed()
    }

    let months = ["January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "October", "November", "December"]

    // 3 columns on iPhone, more on wider screens
    let columns = [GridItem(.adaptive(minimum: 90), spacing: 16)]

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(months, id: \.self) { month in
                        // لما تضغطين على الشهر يفتح صفحته
                        NavigationLink(value: DiaryRoute.month(name: month, year: selectedYear)) {
                            MonthCard(name: month, photos: photos(in: month))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .readableWidth(900)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { allPhotos = PhotoStorage.loadAll() }
        // نخفي شريط الرجوع الجاهز لأن عندنا زرنا الخاص
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // صور شهر معيّن في السنة المختارة (الأحدث أول)
    func photos(in month: String) -> [SavedPhoto] {
        guard let index = months.firstIndex(of: month) else { return [] }
        return allPhotos.filter {
            diaryCalendar.component(.year, from: $0.date) == selectedYear &&
            diaryCalendar.component(.month, from: $0.date) == index + 1
        }
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
    // صور هذا الشهر (الأحدث أول). لو ما فيه صور تظهر المربعات الرمادية
    var photos: [SavedPhoto] = []

    // مربع صورة (أو رمادي لو ما فيه صورة بهذا المكان)
    private func square(_ index: Int, gray: Double) -> some View {
        Color(white: gray)
            .frame(width: 80, height: 80)
            .overlay(
                Group {
                    if index < photos.count, let image = PhotoStorage.thumbnail(for: photos[index]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // الصورة الخلفية (فوق)
                square(2, gray: 0.94)
                    .rotationEffect(.degrees(-3))
                    .offset(x: 0, y: -8)

                // الصورة الوسطى (يمين)
                square(1, gray: 0.88)
                    .rotationEffect(.degrees(5))
                    .offset(x: 12, y: -4)

                // الصورة الأمامية (يسار): الأحدث
                square(0, gray: 0.82)
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

