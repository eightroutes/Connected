import SwiftUI
import FirebaseAuth

struct SplashScreenView: View {
    @State private var isActive = false
    
    // 초기값 설정
    @State private var size = 0.8
    @State private var opacity = 0.1

    @StateObject private var viewModel = ProfileDetailViewModel()

    var body: some View {
        if isActive {
            if viewModel.isSignedIn && !viewModel.userImagesUrl.isEmpty {
                if let user = viewModel.user {
                    MainView(user: user)
                }
            } else {
                LoginView()
            }
        } else {
            VStack {
                VStack {
                    Image("SplashLogo")
                }
                .scaleEffect(size)
            }
            .tint(.black)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        self.isActive = true
                    }
                    if let userId = Auth.auth().currentUser?.uid {
                        viewModel.fetchUserProfile(for: userId)
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
