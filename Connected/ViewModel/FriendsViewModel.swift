import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel: ObservableObject {
    @Published var friends: [String] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    init() {
        fetchFriends()
    }

    // Fetch friends for the current user
    func fetchFriends() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not signed in"
            return
        }

        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let document = document, document.exists {
                self.friends = document.data()?["friends"] as? [String] ?? []
            } else {
                self.errorMessage = error?.localizedDescription ?? "Unknown error"
            }
        }
    }

    // Add a friend to both users' friends list
    func addFriend(userId1: String, userId2: String) {
        let group = DispatchGroup()
        var friendError: String?

        // Add user2 to user1's friends list
        group.enter()
        db.collection("users").document(userId1).updateData([
            "friends": FieldValue.arrayUnion([userId2])
        ]) { error in
            if let error = error {
                friendError = error.localizedDescription
            }
            group.leave()
        }

        // Add user1 to user2's friends list
        group.enter()
        db.collection("users").document(userId2).updateData([
            "friends": FieldValue.arrayUnion([userId1])
        ]) { error in
            if let error = error {
                friendError = error.localizedDescription
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let friendError = friendError {
                self.errorMessage = friendError
            } else {
                self.fetchFriends() // Refresh friends list after adding a friend
            }
        }
    }

    // Remove a friend from both users' friends list
    func removeFriend(userId1: String, userId2: String) {
        let group = DispatchGroup()
        var friendError: String?

        // Remove user2 from user1's friends list
        group.enter()
        db.collection("users").document(userId1).updateData([
            "friends": FieldValue.arrayRemove([userId2])
        ]) { error in
            if let error = error {
                friendError = error.localizedDescription
            }
            group.leave()
        }

        // Remove user1 from user2's friends list
        group.enter()
        db.collection("users").document(userId2).updateData([
            "friends": FieldValue.arrayRemove([userId1])
        ]) { error in
            if let error = error {
                friendError = error.localizedDescription
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let friendError = friendError {
                self.errorMessage = friendError
            } else {
                self.fetchFriends() // Refresh friends list after removing a friend
            }
        }
    }
}
