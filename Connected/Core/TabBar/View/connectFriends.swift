<<<<<<<< Updated upstream:Connected/Core/TabBar/View/connectFriends.swift
//
//  searchNewFriends.swift
//  Connected
//
//  Created by 정근호 on 7/31/24.
//



struct User: Identifiable {
    let id: String
    let name: String
    let profileImage: String
    let interests: [String]
    let selectedColor: String
    let selectedMBTI: String
    let musicGenres: [String]
    let movieGenres: [String]
}


========
>>>>>>>> Stashed changes:Connected/Core/TabBar/View/ConnectFriends.swift
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/connectFriends.swift
========
import Kingfisher
>>>>>>>> Stashed changes:Connected/Core/TabBar/View/ConnectFriends.swift

struct connectFriends: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var isLoading = true
    @State private var similarUsers: [User] = []
    @State private var currentUser: User?
    @State private var showProfileDetail = false
    @State private var selectedUser: User?
    @State private var showRays = true
    @State private var sentFriendRequests: Set<String> = []

    var body: some View {
        ZStack {
            VStack {
                if isLoading {
                    if showRays {
                        Image(systemName: "slowmo")
                            .resizable()
                            .frame(width: 50, height: 50)
                            // 필요한 애니메이션 설정 추가
                            .symbolEffect(.variableColor)
                            .onAppear {
                                loadUsers()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation {
                                        self.showRays = false
                                        self.isLoading = false
                                    }
                                }
                            }
                    } else {
                        ProgressView()
                    }
                } else {
                    ForEach(similarUsers) { user in
                        VStack {
                            HStack(spacing: 15) {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/connectFriends.swift
                                AsyncImage(url: URL(string: user.profileImage)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .shadow(radius: 1)
                                .onTapGesture {
                                    selectedUserId = user.id
                                    showProfileDetail = true
                                }
                                
========
                                KFImage(URL(string: user.profileImageUrl ?? ""))
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    .shadow(radius: 1)
                                    .onTapGesture {
                                        selectedUser = user
                                        showProfileDetail = true
                                    }

>>>>>>>> Stashed changes:Connected/Core/TabBar/View/ConnectFriends.swift
                                VStack(spacing: 4) {
                                    Text(user.name ?? "Unknown")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }

                                Spacer()

                                if sentFriendRequests.contains(user.id) {
                                    Text("요청됨")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                } else {
                                    Button(action: {
                                        sendFriendRequest(to: user.id)
                                    }) {
                                        Text("친구추가")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.brand)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationDestination(isPresented: $showProfileDetail) {
                if let user = selectedUser {
                    ProfileDetail(user: user)
                }
            }
        }
        .onAppear {
            loadUsers()
            loadSentFriendRequests()
        }
    }

    private func loadUsers() {
        firestoreManager.fetchCurrentUser { fetchedUser in
            DispatchQueue.main.async {
                self.currentUser = fetchedUser
                firestoreManager.fetchUsers {
                    if let currentUser = self.currentUser {
                        self.similarUsers = findSimilarUsers(currentUser: currentUser, allUsers: firestoreManager.users)
                    }
                }
            }
        }
    }

    private func sendFriendRequest(to userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("friendRequests").addDocument(data: [
            "fromUserId": currentUserId,
            "toUserId": userId,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
            } else {
                print("Friend request sent successfully")
                DispatchQueue.main.async {
                    self.sentFriendRequests.insert(userId)
                }

                // 알림 생성
                db.collection("notifications").addDocument(data: [
                    "type": "friendRequest",
                    "fromUserId": currentUserId,
                    "toUserId": userId,
                    "status": "pending",
                    "timestamp": FieldValue.serverTimestamp()
                ])
            }
        }
    }

    private func loadSentFriendRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching sent friend requests: \(error.localizedDescription)")
                    return
                }

                let sentRequests = querySnapshot?.documents.compactMap { $0.data()["toUserId"] as? String } ?? []
                DispatchQueue.main.async {
                    self.sentFriendRequests = Set(sentRequests)
                }
            }
    }
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/connectFriends.swift
    
    
    struct searchingNewFriends_Previews: PreviewProvider {
        @State static var userId: String? = nil
        
        static var previews: some View {
            connectFriends(userId: $userId)
                .environmentObject(FirestoreManager())
        }
    }
    
========

>>>>>>>> Stashed changes:Connected/Core/TabBar/View/ConnectFriends.swift
    private func findSimilarUsers(currentUser: User, allUsers: [User]) -> [User] {
        let sortedUsers = allUsers.filter { $0.id != currentUser.id }.sorted { user1, user2 in
            let score1 = calculateSimilarityScore(currentUser: currentUser, otherUser: user1)
            let score2 = calculateSimilarityScore(currentUser: currentUser, otherUser: user2)
            return score1 > score2
        }

        return Array(sortedUsers.prefix(3))
    }

    private func calculateSimilarityScore(currentUser: User, otherUser: User) -> Double {
        let mbtiScore = (currentUser.selectedMBTI == otherUser.selectedMBTI) ? 1.0 : 0.0

        let interestsScore: Double = {
            let currentInterests = Set(arrayLiteral: currentUser.interests)
            let otherInterests = Set(arrayLiteral: otherUser.interests)
            let intersectionCount = Double(currentInterests.intersection(otherInterests).count)
            let maxCount = Double(max(currentInterests.count, otherInterests.count))
            return maxCount > 0 ? intersectionCount / maxCount : 0.0
        }()

        let colorScore = (currentUser.selectedColor == otherUser.selectedColor) ? 1.0 : 0.0

        let musicScore: Double = {
            let currentMusic = Set(arrayLiteral: currentUser.musicGenres)
            let otherMusic = Set(arrayLiteral: otherUser.musicGenres)
            let intersectionCount = Double(currentMusic.intersection(otherMusic).count)
            let maxCount = Double(max(currentMusic.count, otherMusic.count))
            return maxCount > 0 ? intersectionCount / maxCount : 0.0
        }()

        let movieScore: Double = {
            let currentMovies = Set(arrayLiteral: currentUser.movieGenres)
            let otherMovies = Set(arrayLiteral: otherUser.movieGenres)
            let intersectionCount = Double(currentMovies.intersection(otherMovies).count)
            let maxCount = Double(max(currentMovies.count, otherMovies.count))
            return maxCount > 0 ? intersectionCount / maxCount : 0.0
        }()

        return (mbtiScore * 0.3) + (interestsScore * 0.3) + (colorScore * 0.1) + (musicScore * 0.15) + (movieScore * 0.15)
    }
}

<<<<<<<< Updated upstream:Connected/Core/TabBar/View/connectFriends.swift


struct searchingNewFriends_Previews: PreviewProvider {
    @State static var userId: String? = nil
    
    static var previews: some View {
        connectFriends(userId: $userId)
            .environmentObject(FirestoreManager())
    }
========
#Preview {
    ConnectFriends()
>>>>>>>> Stashed changes:Connected/Core/TabBar/View/ConnectFriends.swift
}
