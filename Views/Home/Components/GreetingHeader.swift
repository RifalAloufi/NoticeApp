import SwiftUI

struct GreetingHeader: View {
    let date: String
    let greeting: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(date)
                .font(Typography.inter(13, semibold: true))
                .foregroundStyle(Palette.brandPrimary)
                .frame(height: 16)

            Text(greeting)
                .font(Typography.helveticaBold(38.9))
                .foregroundStyle(Palette.brandPrimary)
                .frame(height: 46)
        }
    }
}
