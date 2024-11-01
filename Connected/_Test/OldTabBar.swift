//MARK: - Old TabBar
//import SwiftUI
//import FirebaseAuth
//
//struct MainView: View {
//    @State private var selectedTab = 0
//    @State private var showProfileDetail = false
//
//    let user: User
//
//    var body: some View {
//        TabView(selection: $selectedTab){
//            ZStack {
//                MainMap()
//                ProfileView(user: user)
//                    .padding(.bottom, 650)
//            }
//            .tabItem {
//                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
//                    .environment(\.symbolVariants, selectedTab == 0 ?.fill: .none)
//            }
//            .onAppear{selectedTab = 0}
//            .tag(0)
//
//            FeedView()
//                .tabItem {
//                    Image(systemName: selectedTab == 1 ? "magnifyingglass" : "magnifyingglass")
//                        .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
//                }
//                .onAppear { selectedTab = 1 }
//                .tag(1)
//
//            ConnectFriends()
//                .tabItem {
//                    Image(selectedTab == 4 ? "center" : "centerGray")
//                        .environment(\.symbolVariants, selectedTab == 4 ? .fill : .none)
//
//                }
//                .onAppear { selectedTab = 4 }
//                .tag(4)
//
//            MainMessagesView()
//                .tabItem {
//                    Image(systemName: selectedTab == 2 ? "message.fill" : "message")
//                        .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
//                }
//                .onAppear { selectedTab = 2 }
//                .tag(2)
//
////            SettingsAndInfo()
//            Text("Settings")
//                .tabItem {
//                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
//                        .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
//                }
//                .onAppear { selectedTab = 3 }
//                .tag(3)
//        }
//        .tint(.black)
//        .ignoresSafeArea()
//        .navigationBarBackButtonHidden(true)
////        .onAppear {
////            if let user = Auth.auth().currentUser {
////                user
////            }
////        }
//    }
//}
//
//
//
//#Preview {
//    MainView(user: User.MOCK_USERS[0])
//
//}
