//
//  ContentView.swift
//  Connected
//
//  Created by 정근호 on 4/9/24.
//

import SwiftUI

struct mainView: View {
    @State private var selectedTab = 0
    @State private var showProfileDetail = false
    
    
    var body: some View {
        TabView(selection: $selectedTab){
            ZStack {
                mainMap()
                ProfileView()
                    .padding(.bottom, 660)
                    .sheet(isPresented: $showProfileDetail) {
                        profileDetail()
                    }
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
                        .environment(\.symbolVariants, selectedTab == 1 ?.fill: .none)
                }
                .onAppear{selectedTab = 1}
                .tag(1)
            connectFriends()
                .tabItem {
                    Image(selectedTab == 4 ? "center" : "centerGray")
                        .environment(\.symbolVariants, selectedTab == 4 ?.fill: .none)
                }
                .onAppear{selectedTab = 4}
                .tag(4)
            
            message()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "message.fill" : "message")
                        .environment(\.symbolVariants, selectedTab == 2 ?.fill: .none)
                }
                .onAppear{selectedTab = 2}
                .tag(2)
            Text("Profile and Settings")
                .tabItem {
                    
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        .environment(\.symbolVariants, selectedTab == 3 ?.fill: .none)
                }
                .onAppear{selectedTab = 3}
                .tag(3)
        }
        .padding(.bottom, -10)
        .tint(.black)
        .shadow(radius: 10)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarBackButtonHidden(true)
        
    }
}


#Preview {
    mainView()
}



struct message: View {
    
    var body: some View {
        Text("messages")
        
        

    }
    
}








