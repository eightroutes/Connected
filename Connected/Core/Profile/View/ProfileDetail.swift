import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

struct ProfileDetail: View {
    @StateObject private var viewModel = ProfileDetailViewModel()
    @StateObject private var friendViewModel = FriendsViewModel()
    @StateObject private var notificationManager = NotificationManager()
    
    @State private var selectedImageIndex = 0
    @State private var showMessageView = false
    @State private var showAlert = false
    
    let user: User
    
    // 현재 유저의 UID를 가져옴
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Swipeable Image Gallery
                TabView(selection: $selectedImageIndex) {
                    ForEach(viewModel.userImagesUrl, id: \.self) { imageUrl in
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(height: 500)
                            .clipped()
                            .tag(imageUrl)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 500)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 20) {
                            
                            Text(viewModel.userName)
                                .font(.title)
                                .fontWeight(.bold)
                                .lineLimit(1)
                            
                            if let userAge = viewModel.userAge {
                                Text("\(userAge)")
                                    .font(.title3)
                            }
                            
                            if viewModel.userGender == "male" {
                                Text("남")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            } else {
                                Text("여")
                                    .foregroundColor(.pink)
                                    .font(.title3)
                            }
                            
                            if user.id != currentUserId {
                                Spacer()
                                
                                
                                switch friendViewModel.friendStatus {
                                case .notFriends:
                                    // 친구추가 버튼 (활성화 상태)
                                    Button(action: {
                                        friendViewModel.sendFriendRequest(to: user.id)
                                        showAlert = true
                                           
                                        
                                        
                                    }) {
                                        Image(systemName: "person.badge.plus")
                                            .font(.title)
                                    }
                                    .alert("친구 추가", isPresented: $showAlert) {

                                    } message: {
                                        Text("친구추가 요청을 보냈습니다.")
                                    }
                                case .requestSent:
                                    // 친구추가 버튼 (비활성화 및 회색)
                                    Button(action: {}) {
                                        Image(systemName: "person.badge.plus")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                    .disabled(true)
                                case .friends:
                                    // 이미 친구인 경우 다른 표시를 할 수 있습니다.
                                    Text("친구입니다")
                                        .font(.title)
                                        .foregroundColor(.green)
                                }
                                
                                // 메시지 버튼
                                Button(action: {
                                    showMessageView = true
                                }) {
                                    Image(systemName: "plus.message")
                                        .font(.title)
                                }
                                
                            }
                            
                        }
                        .padding(.bottom, 10)
                        
                        // User's Details and Preferences
                        if !viewModel.userMBTI.isEmpty {
                            tagView(title: "MBTI", items: [viewModel.userMBTI])
                        }
                        
                        tagView(title: "Music", items: viewModel.userMusic)
                        tagView(title: "Movie", items: viewModel.userMovie)
                        tagView(title: "Interests", items: viewModel.userInterests)
                    }
                    .padding(25)
                }
            }
            
        }//NavigationStack
        .onAppear {
            viewModel.fetchUserProfile(for: user.id)
            friendViewModel.checkFriendStatus(currentUserId: currentUserId, profileUserId: user.id)
        }
        .navigationDestination(isPresented: $showMessageView){
            ChatLogView(user: user)
        }
    }
    
    func tagView(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            FlexibleView(data: items) { item in
                if title == "MBTI" {
                    Text(item.uppercased())
                        .fontWeight(.bold)
                        .font(.body)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(.brand)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.brand, lineWidth: 1)
                        )
                } else {
                    Text(item)
                        .fontWeight(.bold)
                        .font(.body)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(.brand)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.brand, lineWidth: 1)
                        )
                }
            }
        }
    }
}


#Preview {
    ProfileDetail(user: User.MOCK_USERS[0])
}



struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0
    
    init(data: Data, spacing: CGFloat = 10, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            FlexibleInnerView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

struct FlexibleInnerView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
