//
//  searchNewFriends.swift
//  Connected
//
//  Created by 정근호 on 7/31/24.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth


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


struct connectFriends: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var isLoading = true
    @State private var similarUsers: [User] = []
    @State private var currentUser: User?

    
    var body: some View {
        VStack {
            if isLoading {
                Image(systemName: "rays")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
                    .onAppear {
                        firestoreManager.fetchCurrentUser { fetchedUser in
                            self.currentUser = fetchedUser
                            firestoreManager.fetchUsers {
                                if let currentUser = self.currentUser {
                                    self.similarUsers = findSimilarUsers(currentUser: currentUser, allUsers: firestoreManager.users)
                                }
                                self.isLoading = false
                            }
                        }
                    }
                
            } else {
                ForEach(similarUsers) { user in
                    HStack {
                        Image(user.profileImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        Text(user.name)
                        Text("Interests: \(user.interests.joined(separator: ", "))")
                        Text("Color: \(user.selectedColor)")
                        Text("MBTI: \(user.selectedMBTI)")
                        Text("Music: \(user.musicGenres.joined(separator: ", "))")
                        Text("Movie: \(user.movieGenres.joined(separator: ", "))")
                        Button(action: {
                            // Add friend action
                        }) {
                            Text("Add Friend")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
    }
    
    private func findSimilarUsers(currentUser: User, allUsers: [User]) -> [User] {
//        let weightMBTI = 0.3
//        let weightInterests = 0.3
//        let weightColor = 0.1
//        let weightMusic = 0.15
//        let weightMovie = 0.15
        
        let sortedUsers = allUsers.filter { $0.id != currentUser.id }.sorted { user1, user2 in
            let score1 = calculateSimilarityScore(currentUser: currentUser, otherUser: user1)
            let score2 = calculateSimilarityScore(currentUser: currentUser, otherUser: user2)
            return score1 > score2
        }
        
        return Array(sortedUsers.prefix(3))
    }
    
    private func calculateSimilarityScore(currentUser: User, otherUser: User) -> Double {
        let mbtiScore = (currentUser.selectedMBTI == otherUser.selectedMBTI) ? 1.0 : 0.0
        
        let interestsScore = Double(Set(currentUser.interests).intersection(Set(otherUser.interests)).count) / Double(max(currentUser.interests.count, otherUser.interests.count))
        
        let colorScore = (currentUser.selectedColor == otherUser.selectedColor) ? 1.0 : 0.0
        
        let musicScore = Double(Set(currentUser.musicGenres).intersection(Set(otherUser.musicGenres)).count) / Double(max(currentUser.musicGenres.count, otherUser.musicGenres.count))
        
        let movieScore = Double(Set(currentUser.movieGenres).intersection(Set(otherUser.movieGenres)).count) / Double(max(currentUser.movieGenres.count, otherUser.movieGenres.count))
        
        return (mbtiScore * 0.3) + (interestsScore * 0.3) + (colorScore * 0.1) + (musicScore * 0.15) + (movieScore * 0.15)
    }
}

struct searchingNewFriends_Previews: PreviewProvider {
    static var previews: some View {
        connectFriends()
    }
}
