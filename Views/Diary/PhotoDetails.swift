//
//  PhotoDetails.swift
//  MyApp
//
//  Created by Aseel2 on 11/05/1448 AH.
//

import SwiftUI

// لون من كود Hex، مثل 0xC7C7CC
extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// مربع "ما فيه صورة": خلفية + حدود منقطة + أيقونة
struct PhotoPlaceholder: View {
    let cornerRadius: CGFloat
    let iconSize: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(hex: 0xF2F2F7))

            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    Color(hex: 0xC7C7CC),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )

            Image(systemName: "photo")
                .font(.system(size: iconSize, weight: .regular))
                .foregroundStyle(Color(hex: 0xC7C7CC))
        }
    }
}

struct PhotoDetails: View {
    @State private var position: Int? = Calendar.current.component(.day, from: Date())
    @State private var showShare = false

    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
    }

    var body: some View {
        VStack(spacing: 0) {
            // صف الأزرار
            HStack {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                }
                .accessibilityLabel("Back")

                Spacer()

                Button { showShare = true } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                }
                .accessibilityLabel("Share")
            }
            .padding(.horizontal, 24)

            // الصورة الكبيرة
            PhotoPlaceholder(cornerRadius: 32, iconSize: 48)
                .frame(minHeight: 320, maxHeight: 448)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .accessibilityLabel("No photo yet")

            // النصوص
            Text("QUEST")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(Color(hex: 0x397964))
                .padding(.top, 24)

            Text("Find something red")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
                .padding(.top, 8)

            Text("12 Oct 2026")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: 0x8E8E93))
                .padding(.top, 8)

            // مسافة مرنة تدفع الشريط لتحت
            Spacer(minLength: 16)

            // شريط الحلقة
            GeometryReader { geo in
                let item: CGFloat = 104           // حجم المربع
                let gap: CGFloat = 16             // المسافة بين المربعات
                let pitch = item + gap            // مركز لمركز
                let center = geo.size.width / 2   // منتصف الشاشة
                let reach: CGFloat = 296          // المسافة الكلية للحلقة
                let ratio: CGFloat = 0.65         // توزيع المسافات

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: gap) {
                        ForEach(1...daysInMonth, id: \.self) { day in
                            PhotoPlaceholder(cornerRadius: 16, iconSize: 24)
                                .frame(width: item, height: item)
                                .visualEffect { content, proxy in
                                    let midX = proxy.frame(in: .named("strip")).midX
                                    let d = max(-3, min(3, (midX - center) / pitch))
                                    let a = abs(d)
                                    let sign: CGFloat = d < 0 ? -1 : 1
                                    let angle = d * 0.5

                                    let target = sign * reach * (1 - pow(ratio, a))
                                    let shift = target - d * pitch

                                    return content
                                        .rotation3DEffect(
                                            .radians(angle),
                                            axis: (x: 0, y: 1, z: 0),
                                            perspective: 0.3
                                        )
                                        .scaleEffect(1 - a * 0.14)
                                        .offset(x: shift)
                                        .opacity(cos(angle))
                                }
                                .id(day)
                        }
                    }
                    .padding(.vertical, 16)
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $position, anchor: .center)
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(.horizontal, (geo.size.width - item) / 2, for: .scrollContent)
                .coordinateSpace(.named("strip"))
            }
            .frame(height: 136)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showShare) {
            Shareview()
                .presentationDetents([.height(296)])
        }
    }
}

#Preview {
    PhotoDetails()
}
