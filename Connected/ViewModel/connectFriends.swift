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
    
    var body: some View {
        VStack {
            if isLoading {
                Image(systemName: "rays")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
                    .onAppear {
                        firestoreManager.fetchUsers {
                            self.similarUsers = findSimilarUsers(currentUser: firestoreManager.users.first!, allUsers: firestoreManager.users)
                            self.isLoading = false
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
                        Text("Favorite Color: \(user.selectedColor)")
                        Text("MBTI: \(user.selectedMBTI)")
                        Text("Music Genres: \(user.musicGenres.joined(separator: ", "))")
                        Text("Movie Genres: \(user.movieGenres.joined(separator: ", "))")
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
        // Dummy similarity calculation, replace with your own logic
        return allUsers.filter { $0.id != currentUser.id }.sorted { user1, user2 in
            // Implement actual similarity comparison here
            user1.interests.count > user2.interests.count
        }.prefix(3).map { $0 }
    }
}

struct searchingNewFriends_Previews: PreviewProvider {
    static var previews: some View {
        connectFriends()
    }
}
