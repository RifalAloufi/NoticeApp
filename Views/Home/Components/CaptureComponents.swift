import SwiftUI

enum NTU {
    static let green = Color(red: 22 / 255, green: 79 / 255, blue: 60 / 255)   // الأخضر الغامق #164F3C
    static let mint = Color(red: 0.84, green: 0.92, blue: 0.87)       // الأخضر الفاتح (للتدرجات)
    static let background = Color.white
    static let ink = Color(red: 0.10, green: 0.12, blue: 0.11)        // النصوص الغامقة
    static let muted = Color(white: 0.55)                              // النصوص الثانوية
    static let cameraBlack = Color.black                               // خلفية الكاميرا
    static let glass = Color.white.opacity(0.12)                       // الكروت الشفافة فوق الأسود
    static let glassStroke = Color.white.opacity(0.22)
    static let corner: CGFloat = 12
    static let buttonCorner: CGFloat = 25                              // same as the Capture button
}

// MARK: - Quest card (dark glass, used on camera / after-capture)
struct CaptureQuestCard: View {
    let label: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .tracking(0.8)
                .foregroundStyle(Color.white.opacity(0.55))
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(NTU.glass)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(NTU.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Round close button (X) used on dark screens
struct CircleCloseButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
        .accessibilityLabel("Close")
    }
}

// MARK: - Buttons
// أخضر غامق بنص أبيض (Save to diary / Open Settings)
struct NTUPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(NTU.green.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: NTU.buttonCorner, style: .continuous))
    }
}

// أبيض بنص غامق (Retake / Back to Home)
struct NTUSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(NTU.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.white.opacity(configuration.isPressed ? 0.85 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: NTU.buttonCorner, style: .continuous)
                    .stroke(NTU.ink.opacity(0.7), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: NTU.buttonCorner, style: .continuous))
    }
}

// MARK: - Viewfinder helpers (corner brackets + thirds grid)
struct CornerBrackets: Shape {
    var length: CGFloat = 18
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // top-left
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))
        // top-right
        p.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))
        // bottom-right
        p.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
        // bottom-left
        p.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        return p
    }
}

struct ThirdsGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        for i in 1...2 {
            let x = rect.minX + rect.width * CGFloat(i) / 3
            p.move(to: CGPoint(x: x, y: rect.minY))
            p.addLine(to: CGPoint(x: x, y: rect.maxY))
            let y = rect.minY + rect.height * CGFloat(i) / 3
            p.move(to: CGPoint(x: rect.minX, y: y))
            p.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return p
    }
}
