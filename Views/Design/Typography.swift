import SwiftUI
import CoreText

enum Typography {
    // Registers the Inter fonts at runtime (the project has no Info.plist for UIAppFonts)
    private static let registerFonts: Void = {
        for name in ["Inter-Regular", "Inter-SemiBold"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }()

    static func inter(_ size: CGFloat, semibold: Bool = false) -> Font {
        _ = registerFonts
        return .custom(semibold ? "Inter-SemiBold" : "Inter-Regular", fixedSize: size)
    }

    static func helveticaBold(_ size: CGFloat) -> Font {
        .custom("Helvetica-Bold", fixedSize: size)
    }
}
