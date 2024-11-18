import Foundation
import FirebaseFirestore

struct Groups: Identifiable, Codable {
    @DocumentID var id: String? // Firestore 문서 ID
    var name: String
    var description: String
    var theme: String
    var location: String
    var memberCounts: Int
    var mainImageUrl: String
    var members: [String]
    @ServerTimestamp var createdAt: Timestamp? // 서버 타임스탬프

    // 테스트를 위한 MOCK 데이터
    static let MOCK_GROUPS = [
        Groups(
            id: UUID().uuidString,
            name: "러닝모임",
            description: "광안리 런닝",
            theme: "런닝",
            location: "남구",
            memberCounts: 10,
            mainImageUrl: "https://picsum.photos/200",
            members: [UUID().uuidString],
            createdAt: nil
        ),
        Groups(
            id: UUID().uuidString,
            name: "독서모임",
            description: "중도에서 독서하자",
            theme: "독서",
            location: "대연동",
            memberCounts: 8,
            mainImageUrl: "https://picsum.photos/300",
            members: [UUID().uuidString],
            createdAt: nil
        ),
    ]
}
