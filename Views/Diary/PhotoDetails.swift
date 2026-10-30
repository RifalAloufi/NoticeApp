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
    @Environment(\.dismiss) private var dismiss

    // الصورة اللي انفتحت من الدايري
    let photoID: UUID

    // صور نفس الشهر (الأقدم أول) تظهر في الشريط تحت
    @State private var monthPhotos: [SavedPhoto] = []
    // الصورة المعروضة حالياً (تتغير لما تسحبين الشريط)
    @State private var position: UUID?
    @State private var showShare = false
    @State private var showDeleteAlert = false
    @State private var deleteRequested = false

    private var current: SavedPhoto? {
        monthPhotos.first { $0.id == (position ?? photoID) }
    }

    // الصورة الكبيرة: تنقرأ مرة وحدة كل ما تتغير الصورة (مو كل ما تنعاد رسم الصفحة)
    @State private var currentImage: UIImage?

    private var dateText: String {
        guard let photo = current else { return "" }
        return photo.date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, calendar: diaryCalendar))
    }

    var body: some View {
        VStack(spacing: 0) {
            // صف الأزرار
            HStack {
                Button { dismiss() } label: {
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
                .disabled(current == nil)
            }
            .padding(.horizontal, 24)

            // الصورة الكبيرة
            Group {
                if let image = currentImage {
                    Color.clear
                        .overlay(
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .accessibilityLabel(current?.quest ?? "Photo")
                } else {
                    PhotoPlaceholder(cornerRadius: 32, iconSize: 48)
                        .accessibilityLabel("No photo yet")
                }
            }
            .frame(minHeight: 200, maxHeight: 448)
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // النصوص
            Text("QUEST")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(Color(hex: 0x397964))
                .padding(.top, 24)

            Text(current?.quest ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 8)

            Text(dateText)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: 0x8E8E93))
                .padding(.top, 8)

            // مسافة مرنة تدفع الشريط لتحت
            Spacer(minLength: 16)

            // شريط الحلقة: صور هذا الشهر
            GeometryReader { geo in
                let item: CGFloat = 104
                let gap: CGFloat = 16
                let pitch = item + gap
                let center = geo.size.width / 2
                let reach: CGFloat = 296
                let ratio: CGFloat = 0.65

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: gap) {
                        ForEach(monthPhotos) { photo in
                            StripThumbnail(photo: photo)
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
                                .onTapGesture {
                                    withAnimation { position = photo.id }
                                }
                                .id(photo.id)
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
        .readableWidth()
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: load)
        .onChange(of: position) { _, _ in refreshImage() }
        .sheet(isPresented: $showShare, onDismiss: {
            // بعد ما ينقفل الشيت، اعرض التنبيه
            if deleteRequested {
                deleteRequested = false
                showDeleteAlert = true
            }
        }) {
            ShareView(
                image: currentImage,
                quest: current?.quest ?? "",
                onDelete: { deleteRequested = true }
            )
            .presentationDetents([.height(296)])
        }
        .alert("Delete picture?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteCurrent() }
        } message: {
            Text("This will permanently delete your photo from your history")
        }
    }

    // يقرأ صور نفس شهر الصورة المفتوحة
    private func load() {
        let all = PhotoStorage.loadAll()
        guard let start = all.first(where: { $0.id == photoID }) else { return }
        monthPhotos = all
            .filter { diaryCalendar.isDate($0.date, equalTo: start.date, toGranularity: .month) }
            .sorted { $0.date < $1.date }
        refreshImage()

        // نحرك الشريط للصورة المفتوحة بعد ما ينرسم أول مرة (قبلها ما يعرف مكانها)
        if position == nil {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(80))
                position = start.id
            }
        }
    }

    private func refreshImage() {
        currentImage = current.flatMap { PhotoStorage.image(for: $0) }
    }

    // يحذف الصورة الحالية من الجهاز، ويعرض اللي بجنبها (أو يرجع لو ما بقي شي)
    private func deleteCurrent() {
        guard let photo = current else { return }
        let index = monthPhotos.firstIndex { $0.id == photo.id } ?? 0
        PhotoStorage.delete(photo)
        monthPhotos.removeAll { $0.id == photo.id }

        if monthPhotos.isEmpty {
            dismiss()
        } else {
            position = monthPhotos[min(index, monthPhotos.count - 1)].id
        }
    }
}

// صورة صغيرة في الشريط
struct StripThumbnail: View {
    let photo: SavedPhoto

    var body: some View {
        if let image = PhotoStorage.thumbnail(for: photo) {
            Color.clear
                .overlay(
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            PhotoPlaceholder(cornerRadius: 16, iconSize: 24)
        }
    }
}

#Preview {
    PhotoDetails(photoID: UUID())
}
