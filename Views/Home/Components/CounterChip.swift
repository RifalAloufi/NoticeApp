import SwiftUI

struct CounterChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Palette.brandPrimary)
            .frame(width: 54, height: 23)
            .background(Palette.mint, in: RoundedRectangle(cornerRadius: 12, style: .circular))
    }
}
