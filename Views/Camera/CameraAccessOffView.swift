//
//  CameraAccessOffView.swift
//  MyApp
//
//  Created by Rifal  on 11/05/1448 AH.
//

import SwiftUI

struct CameraAccessOffView: View {
    var onBack: () -> Void = {}

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Palette.placeholderFill)
                    .frame(width: 120, height: 120)
                    .overlay(DashedOutline(cornerRadius: 28, dash: [6, 4]))
                    .overlay(
                        Image(systemName: "camera")
                            .font(.system(size: 48))
                            .foregroundStyle(Palette.secondaryLabel)
                    )

                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(.black, in: Circle())
                    .offset(x: 2, y: -14)
            }

            Text("Camera access is off")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(hex: 0x1C1C1E))
                .padding(.top, 24)

            Text("Turn it on in your iPhone Settings to take your daily photo. Your photos stay on this device.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.progressLabel)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 310)
                .padding(.top, 14)

            Spacer()

            VStack(spacing: 14) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Palette.brandPrimary, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: onBack) {
                    Text("Back to Home")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .strokeBorder(Palette.brandPrimary, lineWidth: 2)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

#Preview {
    CameraAccessOffView()
}
