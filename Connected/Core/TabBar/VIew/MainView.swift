import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    @StateObject var viewModel = MainViewModel()
    
    let user: User
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main content view
                ZStack {
                    switch selectedTab {
                    case 0:
                        ZStack(alignment: .topLeading) {
                            MainMap()
                                .ignoresSafeArea(edges: .all) // 전체 화면을 채우도록 설정
                            ProfileView(user: user)
                                .padding(.leading, 20) // 상단 패딩 제거
                        }
                    case 1:
                        FeedView()
                    case 2:
                        ConnectFriends()
                    case 3:
                        MainMessagesView()
                    default:
                        SettingsAndInfo(currentUser: user)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom TabBar view at the bottom
                CustomTabBar(selectedTab: $selectedTab)
                    .frame(height: 60)
                    .background(Color.white) // 배경색 추가
            }
            .ignoresSafeArea(edges: .top) // 상단 공백 제거
        }
        .tint(.black)
        .navigationBarBackButtonHidden(true)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            Button(action: {
                selectedTab = 0
            }) {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(selectedTab == 0 ? .black : .gray)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = 1
            }) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(selectedTab == 1 ? .black : .gray)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = 2
            }) {
                Image(selectedTab == 2 ? "cBlack" : "cGray")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = 3
            }) {
                Image(systemName: selectedTab == 3 ? "message.fill" : "message")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(selectedTab == 3 ? .black : .gray)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = 4
            }) {
                Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(selectedTab == 4 ? .black : .gray)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(Color.white) 
    }
}

#Preview {
    MainView(user: User.MOCK_USERS[0])
}