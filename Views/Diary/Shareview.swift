//
//  Shareview.swift
//  MyApp
//
//  Created by Rifal  on 11/05/1448 AH.
//

import SwiftUI


struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    // الصورة الحقيقية واسم التحدي
    var image: UIImage? = nil
    var quest: String = ""
    var onDelete: () -> Void = { }

    var body: some View {
        VStack(spacing: 0) {
            // العنوان وزر الإغلاق
            ZStack {
                Text("Share to...")
                    .font(.system(size: 17, weight: .semibold))

                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .background(Color(hex: 0x3A3A3C), in: Circle())
                    }
                    .accessibilityLabel("Close")
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // صف التطبيقات
            HStack(spacing: 0) {
                if let image {
                    ShareLink(item: Image(uiImage: image), preview: SharePreview(quest, image: Image(uiImage: image))) {
                        ShareOptionLabel(title: "Share", symbol: "square.and.arrow.up",
                                         fill: Color(hex: 0x3A3A3C), ring: Color(hex: 0x4A4A4C))
                    }
                } else {
                    ShareLink(item: quest) {
                        ShareOptionLabel(title: "Share", symbol: "square.and.arrow.up",
                                         fill: Color(hex: 0x3A3A3C), ring: Color(hex: 0x4A4A4C))
                    }
                }

                Button { } label: {
                    ShareOptionLabel(title: "Messages", symbol: "message.fill",
                                     fill: Color(hex: 0x5CC96A), ring: Color(hex: 0x2F6B3C))
                }

                Button { } label: {
                    ShareOptionLabel(title: "Instagram", assetName: "instagram-logo",
                                     ring: Color(hex: 0x5A2E40))
                }

                Button { } label: {
                    ShareOptionLabel(title: "Snapchat", assetName: "snapchat-logo",
                                     ring: Color(hex: 0x8A8832))
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 24)

            // Save و Delete
            HStack(spacing: 16) {
                ShareActionButton(title: "Save", symbol: "square.and.arrow.down") {
                    // يحفظ الصورة الحقيقية في مكتبة الصور
                    if let image {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }

                ShareActionButton(title: "Delete", symbol: "trash") {
                    onDelete()
                    dismiss()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer()
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: 0x232325))
        .preferredColorScheme(.dark)
    }
}

// دائرة بحلقة + اسم تحتها (أيقونة SF أو شعار من Assets)
struct ShareOptionLabel: View {
    let title: String
    var symbol: String? = nil
    var assetName: String? = nil
    var fill: Color = .clear
    let ring: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .strokeBorder(ring, lineWidth: 2)
                    .frame(width: 64, height: 64)

                if let assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                } else {
                    Circle().fill(fill).frame(width: 56, height: 56)
                    if let symbol {
                        Image(systemName: symbol)
                            .font(.system(size: 22, weight: .medium))
                    }
                }
            }

            Text(title)
                .font(.system(size: 13, weight: .medium))
        }
        .frame(maxWidth: .infinity)
    }
}

// زر عريض على شكل كبسولة
struct ShareActionButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(hex: 0x3A3A3C), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShareView()
        .frame(height: 296)
}
