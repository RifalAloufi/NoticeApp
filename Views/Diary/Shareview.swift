//
//  Shareview.swift
//  MyApp
//
//  Created by Rifal  on 11/05/1448 AH.
//

import SwiftUI

struct Shareview: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // العنوان وزر الإغلاق
            ZStack {
                Text("Share to...")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                HStack {
                    Spacer()

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(hex: 0x3A3A3C), in: Circle())
                    }
                    .accessibilityLabel("Close")
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // صف الأيقونات
            HStack(spacing: 0) {
                // زر Share يفتح شيت آبل
                ShareLink(
                    item: "Find something red",
                    preview: SharePreview("Quest from 12 Oct")
                ) {
                    ShareOptionLabel(
                        title: "Share",
                        symbol: "square.and.arrow.up",
                        fill: Color(hex: 0x3A3A3C),
                        ring: Color(hex: 0x4A4A4C)
                    )
                }
                .buttonStyle(.plain)

                ShareOptionButton(
                    title: "Messages",
                    symbol: "message.fill",
                    fill: Color(hex: 0x5CC96A),
                    ring: Color(hex: 0x2F6B3C)
                ) { }

                ShareOptionButton(
                    title: "Instagram",
                    symbol: "camera",
                    fill: Color(hex: 0xD6416C),
                    ring: Color(hex: 0x5A2E40)
                ) { }

                ShareOptionButton(
                    title: "Snapchat",
                    symbol: "face.smiling",
                    fill: Color(hex: 0xFFFC52),
                    ring: Color(hex: 0x8A8832),
                    symbolColor: .black
                ) { }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)

            // زرين Save و Delete
            HStack(spacing: 16) {
                ShareActionButton(title: "Save", symbol: "square.and.arrow.down") { }
                ShareActionButton(title: "Delete", symbol: "trash") { showDeleteAlert = true }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: 0x232325))
        .preferredColorScheme(.dark)
        .alert("Delete picture?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { dismiss() }
        } message: {
            Text("This will permanently delete your photo from your history")
        }
    }
}

// الشكل فقط: دائرة بحلقة + اسم تحتها
struct ShareOptionLabel: View {
    let title: String
    let symbol: String
    let fill: Color
    let ring: Color
    var symbolColor: Color = .white

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .strokeBorder(ring, lineWidth: 2)
                    .frame(width: 64, height: 64)

                Circle()
                    .fill(fill)
                    .frame(width: 56, height: 56)

                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(symbolColor)
            }

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

// نفس الشكل لكن كزر عادي
struct ShareOptionButton: View {
    let title: String
    let symbol: String
    let fill: Color
    let ring: Color
    var symbolColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ShareOptionLabel(
                title: title,
                symbol: symbol,
                fill: fill,
                ring: ring,
                symbolColor: symbolColor
            )
        }
        .buttonStyle(.plain)
    }
}

// زر عريض على شكل كبسولة: أيقونة + اسم
struct ShareActionButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .medium))

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(hex: 0x3A3A3C), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Shareview()
        .frame(height: 296)
}
