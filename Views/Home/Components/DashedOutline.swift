import SwiftUI

struct DashedOutline: View {
    let cornerRadius: CGFloat
    let dash: [CGFloat]

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                Palette.placeholderStroke,
                style: StrokeStyle(lineWidth: 1.5, dash: dash)
            )
    }
}
