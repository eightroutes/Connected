////
////  MainViewNew.swift
////  Connected
////
////  Created by 정근호 on 9/9/24.
////

import SwiftUI 
import FirebaseAuth


enum Tab {
    case home, feed, connect, message, setting
}

struct CustomTabView: View {
    
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(alignment: .center) {
    
            Button {
                selectedTab = .home
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                        .environment(\.symbolVariants, selectedTab == .home ?.fill: .none)
                    
                }
                .offset(x: -5)
            }
            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
            
           
            
            Button {
                selectedTab = .feed
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: selectedTab == .feed ? "magnifyingglass" : "magnifyingglass")
                        .environment(\.symbolVariants, selectedTab == .feed ?.fill: .none)
                    

                }
                .offset(x: 5)
            }
            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
            
            Button {
                selectedTab = .connect
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: selectedTab == .connect ? "center" : "centerGray")
                        .environment(\.symbolVariants, selectedTab == .connect ?.fill: .none)
                    

                }
                .offset(x: 5)
            }
            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
            
            
            Button {
                selectedTab = .message
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: selectedTab == .message ? "message.fill" : "message")
                        .environment(\.symbolVariants, selectedTab == .message ?.fill: .none)
                    

                }
                .offset(x: 5)
            }
            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
            
            Button {
                selectedTab = .setting
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: selectedTab == .setting ? "person.fill" : "person")
                        .environment(\.symbolVariants, selectedTab == .setting ?.fill: .none)
                    

                }
                .offset(x: 5)
            }
            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
        }
        .frame(width: UIScreen.main.bounds.width, height: 85)
    }
}

struct TabbarView: View {
    @State private var showProfileDetail = false
    @State private var userId: String?
    @EnvironmentObject var viewModel: SignInViewModel
    
    @State var selectedTab: Tab = .home
    
    var body: some View {
        
        VStack(spacing: 0) {
            switch selectedTab {
            case .home:
                MainView()
            case .feed:
                FeedView()
            case .connect:
                ConnectFriends(userId: $userId)
            case .message:
                MainMessagesView()
            case .setting:
                SettingsAndInfo()
            }
            CustomTabView(selectedTab: $selectedTab)
                .padding(.bottom, 15)
        }
        .edgesIgnoringSafeArea(.bottom)

    }
}

#Preview {
    TabbarView()
        .environmentObject(SignInViewModel())

}
//
//import SwiftUI
//import FirebaseAuth
//
//enum TabIndex{
//
//    case home, feed, connect, message, setting
//}
//
//struct MainViewCustom: View {
//    @State var tabIndex: TabIndex
//    
//    @State private var userId: String?
//
//    
//    
//    func changeMyView(tabIndex: TabIndex) ->  any View {
//        
//        switch tabIndex {
//        case .home:
//            return ZStack {
//                MainMap()
//                ProfileView(userId: $userId)
//                    .padding(.bottom, 650)
//            }
//        case .feed:
//            return FeedView()
//        case .connect:
//            return ConnectFriends(userId: $userId)
//
//        case .message:
//            return MainMessagesView()
//        case .setting:
//            return SettingsAndInfo()
//        }
//    }
//    
//    // x축 y축 등 모든 포지션은 CGFloat 자료형
//    func calcCircleBgPosition(tabIndex: TabIndex, geometry: GeometryProxy) -> CGFloat {
//        let tabWidth = geometry.size.width / 5
//        switch tabIndex {
//        case .home:
//            return -2 * tabWidth
//        case .feed:
//            return -tabWidth
//        case .connect:
//            return 0
//        case .message:
//            return tabWidth
//        case .setting:
//            return 2 * tabWidth
//        }
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .bottom) {
//                self.changeMyView(tabIndex: self.tabIndex)
//                
//            }
//        }
//    }
//}
//
//#Preview {
//    MainViewCustom(tabIndex: TabIndex.home)
//}
//
