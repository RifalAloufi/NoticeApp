import SwiftUI

@main
struct MyApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeContainer()

                if showSplash {
                    SplashView {
                        showSplash = false
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
