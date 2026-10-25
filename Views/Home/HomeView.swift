import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopPanel()

            Text("Your diary")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .frame(height: 20)
                .padding(.leading, 26)
                .padding(.top, 41)

            DiaryEmptyState()
                .padding(.horizontal, 20)
                .padding(.top, 22)
            //

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            CaptureButton()
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color.white)
        }
    }
}

#Preview {
    HomeView()
}
