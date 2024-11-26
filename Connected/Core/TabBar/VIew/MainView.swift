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
                        NavigationView{
                            ZStack(alignment: .topLeading) {
                                MainMap()
                                ProfileView(user: user)
                                    .padding(.leading, 20)
                                    .padding(.top, 10)
                            }
                        }
                    case 1:
                        NavigationView {
                            GroupView()
                        }
                        
                    case 2:
                        NavigationView {
                            ConnectFriends()
                        }
                    case 3:
                        NavigationView {
                            MainMessagesView(user: user)
                        }
                    default:
                        NavigationView {
                            SettingsAndInfo(currentUser: user)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom TabBar view at the bottom
                CustomTabBar(selectedTab: $selectedTab)
                    .frame(height: 48)
                    .background(Color.white)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationBarHidden(true)
        .tint(.black)
        
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
