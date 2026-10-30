import SwiftUI

// Helpers that keep the layout comfortable on every iPhone and iPad size.
// On iPhone the content already fills the screen; on wider screens (iPad, landscape)
// it stays in a centered column instead of stretching edge to edge.
enum Layout {
    // Widest column used for normal screens (Home, Diary, Photo)
    static let readableWidth: CGFloat = 640
    // Narrower column for focused screens (camera, sheets)
    static let focusedWidth: CGFloat = 520
}

extension View {
    /// Limits the width to `maxWidth` and centers the view in the space it's given.
    func readableWidth(_ maxWidth: CGFloat = Layout.readableWidth) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}
