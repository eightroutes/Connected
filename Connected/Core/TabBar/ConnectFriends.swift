////
////  searchNewFriends.swift
////  Connected
////
////  Created by 정근호 on 7/31/24.
////
//
//
//
//
//import SwiftUI
//import Firebase
//import FirebaseFirestore
//import FirebaseAuth
//import Kingfisher
//
//struct ConnectFriends: View {
//    @StateObject private var firestoreManager = FirestoreManager()
//    @State private var isLoading = true
//    @State private var similarUsers: [User] = []
//    @State private var currentUser: User?
//    @State private var showProfileDetail = false
//    @State private var selectedUserId: String?
//    @State private var showRays = true
//    @State private var sentFriendRequests: Set<String> = []
//    
//    @Binding var userId: String?
//    
//    
//    var body: some View {
//        ZStack {
//            
//            VStack {
//                if isLoading {
//                    if showRays {
//                        Image(systemName: "slowmo")
//                            .resizable()
//                            .frame(width: 50, height: 50)
//                            .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
//                            .onAppear {
//                                loadUsers()
//                                // 2초 후에 rays를 숨기고 isLoading을 false로 설정
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                                    withAnimation {
//                                        self.showRays = false
//                                        self.isLoading = false
//                                    }
//                                }
//                            }
//                    } else {
//                        ProgressView()  // rays가 사라진 후 표시할 로딩 인디케이터
//                    }
//                } else {
//                    ForEach(similarUsers) { user in
//                        VStack {
//                            HStack(spacing: 15) {
//                                KFImage(url: URL(string: user.profileImageURL ?? nil)) { image in
//                                    image.resizable()
//                                } placeholder: {
//                                    Image(systemName: "person.circle.fill")
//                                        .resizable()
//                                }
//                                .frame(width: 50, height: 50)
//                                .clipShape(Circle())
//                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
//                                .shadow(radius: 1)
//                                .onTapGesture {
//                                    selectedUserId = user.id
//                                    showProfileDetail = true
//                                }
//                                
//                                VStack(spacing: 4) {
//                                    Text(user.name)
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                }
//                                
//                                Spacer()
//                                
//                                if sentFriendRequests.contains(user.id) {
//                                    Text("요청됨")
//                                        .font(.subheadline)
//                                        .fontWeight(.medium)
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 8)
//                                        .background(Color.gray)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(10)
//                                } else {
//                                    Button(action: {
//                                        sendFriendRequest(to: user.id)
//                                    }) {
//                                        Text("친구추가")
//                                            .font(.subheadline)
//                                            .fontWeight(.medium)
//                                            .padding(.horizontal, 12)
//                                            .padding(.vertical, 8)
//                                            .background(Color.brand)
//                                            .foregroundColor(.white)
//                                            .cornerRadius(10)
//                                    }
//                                }
//                            }
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(12)
//                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
//                    }
//                }
//            }
//            
//            .navigationDestination(isPresented: $showProfileDetail) {
//                if let userId = selectedUserId {
//                    ProfileDetail(userId: userId)
//                }
//            }
//        }
//        .onAppear {
//            loadUsers()
//            loadSentFriendRequests()
//        }
//    }
//    private func loadUsers() {
//        firestoreManager.fetchCurrentUser { fetchedUser in
//            self.currentUser = fetchedUser
//            firestoreManager.fetchUsers {
//                if let currentUser = self.currentUser {
//                    self.similarUsers = findSimilarUsers(currentUser: currentUser, allUsers: firestoreManager.users)
//                }
//            }
//        }
//    }
//    
//    
//    private func sendFriendRequest(to userId: String) {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        let db = Firestore.firestore()
//        
//        db.collection("friendRequests").addDocument(data: [
//            "fromUserId": currentUserId,
//            "toUserId": userId,
//            "status": "pending",
//            "timestamp": FieldValue.serverTimestamp()
//        ]) { error in
//            if let error = error {
//                print("Error sending friend request: \(error.localizedDescription)")
//            } else {
//                print("Friend request sent successfully")
//                DispatchQueue.main.async {
//                    self.sentFriendRequests.insert(userId)
//                }
//                
//                // 알림 생성
//                db.collection("notifications").addDocument(data: [
//                    "type": "friendRequest",
//                    "fromUserId": currentUserId,
//                    "toUserId": userId,
//                    "status": "pending",
//                    "timestamp": FieldValue.serverTimestamp()
//                ])
//            }
//        }
//    }
//    
//    private func loadSentFriendRequests() {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        let db = Firestore.firestore()
//        
//        db.collection("friendRequests")
//            .whereField("fromUserId", isEqualTo: currentUserId)
//            .getDocuments { querySnapshot, error in
//                if let error = error {
//                    print("Error fetching sent friend requests: \(error.localizedDescription)")
//                    return
//                }
//                
//                let sentRequests = querySnapshot?.documents.compactMap { $0.data()["toUserId"] as? String } ?? []
//                DispatchQueue.main.async {
//                    self.sentFriendRequests = Set(sentRequests)
//                }
//            }
//    }
//    
//    
//    struct searchingNewFriends_Previews: PreviewProvider {
//        @State static var userId: String? = nil
//        
//        static var previews: some View {
//            ConnectFriends(userId: $userId)
//                .environmentObject(FirestoreManager())
//        }
//    }
//    
//    private func findSimilarUsers(currentUser: User, allUsers: [User]) -> [User] {
//        //        let weightMBTI = 0.3
//        //        let weightInterests = 0.3
//        //        let weightColor = 0.1
//        //        let weightMusic = 0.15
//        //        let weightMovie = 0.15
//        
//        let sortedUsers = allUsers.filter { $0.id != currentUser.id }.sorted { user1, user2 in
//            let score1 = calculateSimilarityScore(currentUser: currentUser, otherUser: user1)
//            let score2 = calculateSimilarityScore(currentUser: currentUser, otherUser: user2)
//            return score1 > score2
//        }
//        
//        return Array(sortedUsers.prefix(3))
//    }
//    
//    private func calculateSimilarityScore(currentUser: User, otherUser: User) -> Double {
//        let mbtiScore = (currentUser.selectedMBTI == otherUser.selectedMBTI) ? 1.0 : 0.0
//        
//        let interestsScore = Double(Set(currentUser.interests).intersection(Set(otherUser.interests)).count) / Double(max(currentUser.interests.count, otherUser.interests.count))
//        
//        let colorScore = (currentUser.selectedColor == otherUser.selectedColor) ? 1.0 : 0.0
//        
//        let musicScore = Double(Set(currentUser.musicGenres).intersection(Set(otherUser.musicGenres)).count) / Double(max(currentUser.musicGenres.count, otherUser.musicGenres.count))
//        
//        let movieScore = Double(Set(currentUser.movieGenres).intersection(Set(otherUser.movieGenres)).count) / Double(max(currentUser.movieGenres.count, otherUser.movieGenres.count))
//        
//        return (mbtiScore * 0.3) + (interestsScore * 0.3) + (colorScore * 0.1) + (musicScore * 0.15) + (movieScore * 0.15)
//    }
//}
//
//
//
//struct searchingNewFriends_Previews: PreviewProvider {
//    @State static var userId: String? = nil
//    
//    static var previews: some View {
//        ConnectFriends(userId: $userId)
////            .environmentObject(FirestoreManager())
//    }
//}
