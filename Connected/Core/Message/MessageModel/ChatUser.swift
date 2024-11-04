import Foundation

struct ChatUser: Identifiable {
    
    var id: String { uid }
    
    let uid, email, profileImageUrl, name: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.name = data["name"] as? String ?? ""  // Initialize name
    }
    
    // New initializer that accepts a User instance
    init(user: User) {
        self.uid = user.id
        self.email = user.email ?? ""
        self.profileImageUrl = user.profileImageUrl ?? ""
        self.name = user.name ?? ""
    }
}
