import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct ProfileDetail: View {
    @StateObject private var viewModel = ProfileDetailViewModel()
    @State private var selectedImageIndex = 0
    
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var navigationState: NavigationState
    @State private var navigationPath = NavigationPath()

    
    let userId: String

    
    var body: some View {
        NavigationStack(path: $navigationPath){
            ZStack{
                VStack {
                    // Swipeable Image Gallery
                    TabView(selection: $selectedImageIndex) {
                        ForEach(viewModel.userImages.indices, id: \.self) { index in
                            if let image = viewModel.userImages[index] {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 500)
                                    .clipped()
                                    .tag(index)
                            } else {
                                Rectangle()
                                    .fill(Color.brand)
                                    .overlay(
                                        Image(systemName: "rays")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing)
                                            .foregroundColor(.white)
                                    )
                                    .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 500)
                    
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Profile Photo and Name
                            HStack(spacing: 20) {
                                if let profileImage = viewModel.profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 1)
                                        .frame(width: 50, height: 50)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 1)
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }
                                
                                
                                Text(viewModel.userName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                if let userAge = viewModel.userAge {
                                    Text("\(userAge)")
                                        .font(.title)
                                }
                                
                                
                                if viewModel.userGender == "male" {
                                    Text("남")
                                        .foregroundColor(.blue)
                                        .font(.title)
                                } else {
                                    Text("여")
                                        .foregroundColor(.pink)
                                        .font(.title)
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
                .onAppear {
                    viewModel.fetchUserProfile(for: userId) // 전달받은 UID로 프로필 데이터 불러오기
                }
//                .ignoresSafeArea()
                
            }
        }
        .tint(.brand)
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
    ProfileDetail(userId: UserLocation.sampleUser.id)
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
