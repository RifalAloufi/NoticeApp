import SwiftUI
import UIKit

// Fine tick marks around a circle, like a lens ring
struct TickWheel: View {
    var count: Int
    var radius: CGFloat
    var color: Color

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let long = i % 5 == 0
                let length: CGFloat = long ? 13 : 7
                Capsule()
                    .fill(color)
                    .frame(width: long ? 2.4 : 1.6, height: length)
                    .offset(y: -(radius - length / 2))
                    .rotationEffect(.degrees(Double(i) * 360 / Double(count)))
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

struct SplashView: View {
    // Called when the splash has faded out
    var onFinish: () -> Void

    // ===== CRESCENT POSITION (tweak these) =====
    // Positive X = right, positive Y = down
    private let crescentX: CGFloat = 9.5
    private let crescentY: CGFloat = -5.1
    private let crescentScale: CGFloat = 2.0
    // ===========================================

    // Rotation values
    @State private var bigTurn: Double = 0      // big circle (left = negative)
    @State private var ringTurn: Double = 0     // small circle (right = positive)

    // Capture values
    @State private var shutter: CGFloat = 1
    @State private var flash: Double = 0

    // Fade out of the whole page
    @State private var pageOpacity: Double = 1

    // Real size and position of the shapes (measured from the images)
    @State private var ready = false
    @State private var bigRect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
    @State private var ringRect = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
    @State private var eyeRect = CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4)

    private let size: CGFloat = 250

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.91, green: 0.96, blue: 0.93), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Logo: layers in the original order (first = bottom)
                ZStack {
                    // Big circle: image stays still, ticks rotate left
                    Image("bigCircle").resizable().scaledToFit()
                    TickWheel(
                        count: 60,
                        radius: bigRect.width * size / 2 - 8,
                        color: .white.opacity(0.16)
                    )
                    .rotationEffect(.degrees(bigTurn))
                    .position(x: bigRect.midX * size, y: bigRect.midY * size)
                    .opacity(ready ? 1 : 0)

                    // Small circle: image stays still, ticks rotate right
                    Image("ring").resizable().scaledToFit()
                    TickWheel(
                        count: 40,
                        radius: ringRect.width * size / 2 - 6,
                        color: .white.opacity(0.14)
                    )
                    .rotationEffect(.degrees(ringTurn))
                    .position(x: ringRect.midX * size, y: ringRect.midY * size)
                    .opacity(ready ? 1 : 0)

                    // Crescent: static, clipped to the big circle
                    ZStack {
                        Image("crescent")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(crescentScale)
                            .offset(x: crescentX, y: crescentY)
                    }
                    .frame(width: size, height: size)
                    .mask(
                        Image("bigCircle")
                            .resizable()
                            .scaledToFit()
                    )

                    // Eye: closes only at the capture moment
                    ZStack {
                        Image("aperture").resizable().scaledToFit()
                        Image("pupil").resizable().scaledToFit()
                        Image("highlight").resizable().scaledToFit()
                    }
                    .scaleEffect(
                        shutter,
                        anchor: UnitPoint(x: eyeRect.midX, y: eyeRect.midY)
                    )

                    // Small dot: static
                    Image("smallDot").resizable().scaledToFit()
                }
                .frame(width: size, height: size)
                .drawingGroup()

                // Text: static from the first moment
                Text("NOTICE THE UNNOTICED")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.black)

                Spacer()
                Spacer()
            }

            // Flash
            Color.white
                .ignoresSafeArea()
                .opacity(flash)
                .allowsHitTesting(false)
        }
        .opacity(pageOpacity)
        .task {
            // Measure the real shapes first
            bigRect = solidBounds(of: "bigCircle")
            ringRect = solidBounds(of: "ring")
            eyeRect = solidBounds(of: "aperture")
            ready = true
            await runAnimation()
        }
    }

    // Finds the box around the solid (non-transparent) part of an image
    func solidBounds(of name: String) -> CGRect {
        let fallback = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
        guard let cg = UIImage(named: name)?.cgImage else { return fallback }
        let w = cg.width
        let h = cg.height
        var data = [UInt8](repeating: 0, count: w * h * 4)
        guard let ctx = CGContext(
            data: &data,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: w * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return fallback }

        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))

        var minX = w, maxX = 0, minY = h, maxY = 0
        for y in 0..<h {
            for x in 0..<w {
                if data[(y * w + x) * 4 + 3] > 230 {
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        if maxX <= minX || maxY <= minY { return fallback }

        return CGRect(
            x: CGFloat(minX) / CGFloat(w),
            y: CGFloat(minY) / CGFloat(h),
            width: CGFloat(maxX - minX) / CGFloat(w),
            height: CGFloat(maxY - minY) / CGFloat(h)
        )
    }

    // Animation sequence
    func runAnimation() async {
        // Hold the assembled logo
        try? await Task.sleep(for: .seconds(0.8))

        // Big circle rolls left, small circle rolls right
        withAnimation(.easeInOut(duration: 2.2)) {
            bigTurn = -180
            ringTurn = 180
        }
        try? await Task.sleep(for: .seconds(2.5))

        // Capture at the end: eye closes + soft flash
        withAnimation(.easeIn(duration: 0.12)) {
            shutter = 0.85
            flash = 0.55
        }
        try? await Task.sleep(for: .seconds(0.14))
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            shutter = 1
        }
        withAnimation(.easeOut(duration: 0.45)) { flash = 0 }

        // Stay on the logo for a moment, then fade the whole page out
        try? await Task.sleep(for: .seconds(1.0))
        withAnimation(.easeInOut(duration: 0.8)) { pageOpacity = 0 }
        try? await Task.sleep(for: .seconds(0.8))

        onFinish()
    }
}

#Preview {
    SplashView(onFinish: {})
}
