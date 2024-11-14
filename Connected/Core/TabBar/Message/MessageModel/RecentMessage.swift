import Foundation
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let text: String
    let fromId: String
    let toId: String
    let timestamp: Date
    let user: UserBrief

    struct UserBrief: Codable, Identifiable {
        var id: String
        var name: String
        var email: String
        var profile_image: String

        enum CodingKeys: String, CodingKey {
            case id
            case name = "Name"
            case email
            case profile_image = "profile_image"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case fromId
        case toId
        case timestamp
        case user
    }
}
