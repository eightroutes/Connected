import SwiftUI
import FirebaseAuth

struct mainView: View {
    @State private var selectedTab = 0
    @State private var showProfileDetail = false
    @State private var userId: String?
    
    var body: some View {
        TabView(selection: $selectedTab){
            ZStack {
                mainMap()
                ProfileView(userId: $userId)
                    .padding(.bottom, 650)
                    .onAppear{selectedTab = 0}
                    .tag(0)
                
            }
            .tabItem {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    .padding(.top, 10)
                    .environment(\.symbolVariants, selectedTab == 0 ?.fill: .none)
            }
            
            Text("Feed")
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass" : "magnifyingglass")
                        .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                }
                .onAppear { selectedTab = 1 }
                .tag(1)
            
            connectFriends(userId: $userId)
                .tabItem {
                    Image(selectedTab == 4 ? "center" : "centerGray")
                        .environment(\.symbolVariants, selectedTab == 4 ? .fill : .none)
                }
                .onAppear { selectedTab = 4 }
                .tag(4)
            
            message()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "message.fill" : "message")
                        .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                }
                .onAppear { selectedTab = 2 }
                .tag(2)
            
            SettingsAndInfo()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                }
                .onAppear { selectedTab = 3 }
                .tag(3)
        }
        .tint(.black)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = Auth.auth().currentUser {
                userId = user.uid
            }
        }
    }
}

struct message: View {
    var body: some View {
        Text("messages")
    }
}

#Preview {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/mainView.swift
    mainView()
========
    MainView()

>>>>>>>> Stashed changes:Connected/Core/TabBar/MainView.swift
}
