import SwiftUI

struct ProgressSegments: View {
    let completed: Int
    private let radii: [CGFloat] = [2, 0, 2]

    var body: some View {
        HStack(spacing: 13.4) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: radii[index], style: .continuous)
                    .fill(index < completed ? Palette.brandPrimary : Palette.progressTrack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
            }
        }
    }
}
