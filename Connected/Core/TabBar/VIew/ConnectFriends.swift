import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

struct ConnectFriends: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @StateObject private var friendsViewModel = FriendsViewModel()
    
    @State private var isLoading = true
    @State private var similarUsers: [User] = []
    @State private var currentUser: User?
    @State private var showProfileDetail = false
    @State private var selectedUser: User?
    @State private var showRays = true
    @State private var sentFriendRequests: Set<String> = []
    @State private var alreadyShownUserIds: Set<String> = []
    
    var body: some View {
        ZStack {
            VStack {
                if isLoading {
                    if showRays {
                        Image(systemName: "slowmo")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .symbolEffect(.variableColor)
                            .onAppear {
                                // loadUsers() 호출 제거
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation {
                                        self.showRays = false
                                        self.isLoading = false
                                    }
                                }
                            }
                    } 
                } else {
                    ZStack {
                        VStack {
                            Spacer()
                            ForEach(similarUsers) { user in
                                VStack {
                                    HStack(spacing: 15) {
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
                                        VStack(spacing: 4) {
                                            Text(user.name ?? "Unknown")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                        
                                        if friendsViewModel.sentFriendRequests.contains(user.id) {
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
                                                friendsViewModel.sendFriendRequest(to: user.id)
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
                            Spacer()
                        }//VStack
                        
                        VStack {
                            Spacer()
                            Divider().opacity(0)
                            Spacer()
                           
                            // "arrow.clockwise" 버튼 추가
                            Button {
                                reloadSimilarUsers()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(.black)
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 1)
                                    
                            }
                            .padding(.bottom, 80)
                        }
                        
                        
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
        }
    }
    
    private func loadUsers() {
        firestoreManager.fetchCurrentUser { fetchedUser in
            DispatchQueue.main.async {
                self.currentUser = fetchedUser
                firestoreManager.fetchUsers {
                    if let currentUser = self.currentUser {
                        let newSimilarUsers = findSimilarUsers(currentUser: currentUser, allUsers: firestoreManager.users, excludeUserIds: alreadyShownUserIds)
                        self.similarUsers = newSimilarUsers
                        let newUserIds = newSimilarUsers.compactMap { $0.id }
                        self.alreadyShownUserIds.formUnion(newUserIds)
                    }
                    friendsViewModel.loadSentFriendRequests() // loadSentFriendRequests 호출 추가
                }
            }
        }
    }
    
    private func reloadSimilarUsers() {
        guard let currentUser = self.currentUser else { return }
        let newSimilarUsers = findSimilarUsers(currentUser: currentUser, allUsers: firestoreManager.users, excludeUserIds: alreadyShownUserIds)
        if newSimilarUsers.isEmpty {
            print("No more similar users to load.")
            // Optionally, reset alreadyShownUserIds or provide feedback to user.
            alreadyShownUserIds.removeAll()
            
        } else {
            self.similarUsers = newSimilarUsers
            let newUserIds = newSimilarUsers.compactMap { $0.id }
            self.alreadyShownUserIds.formUnion(newUserIds)
        }
    }
    
    
    
    private func findSimilarUsers(currentUser: User, allUsers: [User], excludeUserIds: Set<String> = []) -> [User] {
        let sortedUsers = allUsers.filter { user in
            return user.id != currentUser.id && !excludeUserIds.contains(user.id)
        }.sorted { user1, user2 in
            let score1 = calculateSimilarityScore(currentUser: currentUser, otherUser: user1)
            let score2 = calculateSimilarityScore(currentUser: currentUser, otherUser: user2)
            return score1 > score2
        }
        
        return Array(sortedUsers.prefix(3))
    }
    
    private func calculateSimilarityScore(currentUser: User, otherUser: User) -> Double {
        let mbtiScore = (currentUser.selectedMBTI == otherUser.selectedMBTI) ? 1.0 : 0.0
        
        let interestsScore: Double = {
            let currentInterests = Set(currentUser.interests ?? [])
            let otherInterests = Set(otherUser.interests ?? [])
            let intersectionCount = Double(currentInterests.intersection(otherInterests).count)
            let maxCount = Double(max(currentInterests.count, otherInterests.count))
            return maxCount > 0 ? intersectionCount / maxCount : 0.0
        }()
        
        let colorScore = (currentUser.selectedColor == otherUser.selectedColor) ? 1.0 : 0.0
        
        let musicScore: Double = {
            let currentMusic = Set(currentUser.musicGenres ?? [])
            let otherMusic = Set(otherUser.musicGenres ?? [])
            let intersectionCount = Double(currentMusic.intersection(otherMusic).count)
            let maxCount = Double(max(currentMusic.count, otherMusic.count))
            return maxCount > 0 ? intersectionCount / maxCount : 0.0
        }()
        
        let movieScore: Double = {
            let currentMovies = Set(currentUser.movieGenres ?? [])
            let otherMovies = Set(otherUser.movieGenres ?? [])
            let intersectionCount = Double(currentMovies.intersection(otherMovies).count)
            let maxCount = Double(max(currentMovies.count, otherMovies.count))
            return maxCount > 0 ? intersectionCount / maxCount : 0.0
        }()
        
        return (mbtiScore * 0.4) + (interestsScore * 0.35) + (colorScore * 0.1) + (musicScore * 0.15) + (movieScore * 0.15)
    }
}

#Preview {
    ConnectFriends()
}
