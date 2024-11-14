//
//  FriendsListView.swift
//  Connected
//
//  Created by 정근호 on 11/8/24.
//

import SwiftUI

struct FriendsListView: View {
    @StateObject private var friendsViewModel = FriendsViewModel()
    
    @State private var selectedFriend: User?
    @State private var showActionSheet = false
    @State private var showMessageView = false
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 4){
                ScrollView {
                    VStack(alignment: .leading){
                        if (friendsViewModel.friends.isEmpty) {
                            Text("친구를 추가해보세요.")
                        }
                    }
                    ForEach(friendsViewModel.friends) { friend in
                        HStack{
                            NavigationLink(destination: ProfileDetail(user: friend)){
                                ProfileView(user: friend, radius: 40)
                            }
                            Text(friend.name ?? "UserName")
                            
                            Spacer()
                            
                            // 메시지 버튼
                            Button(action: {
                                showMessageView = true
                            }) {
                                Image(systemName: "plus.message")
                                    .font(.title3)
                            }
                            .navigationDestination(isPresented: $showMessageView){
                                ChatLogView(user: friend)
                            }
                            Button(action: {
                                selectedFriend = friend
                                showActionSheet = true
                            }) {
                                Image(systemName: "ellipsis")
                            }
                            .confirmationDialog("친구 삭제", isPresented: $showActionSheet, titleVisibility: .visible) {
                                Button("친구 삭제", role: .destructive){
                                    if let friend = selectedFriend {
                                        friendsViewModel.removeFriend(friend)
                                    }
                                }
                                Button("취소", role: .cancel) {}
                            } message: {
                                if let friend = selectedFriend {
                                    Text("\(friend.name ?? "이 친구를") 삭제하시겠습니까?")
                                } else {
                                    Text("친구를 삭제하시겠습니까?")
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    }//ForEach
                }//ScrollView
            }//VStack
            .listStyle(GroupedListStyle())
            .navigationTitle("친구")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                friendsViewModel.fetchFriends()
            }
            
            
        }//NavigationStack
        
        
    }
    
}

#Preview {
    FriendsListView()
}
