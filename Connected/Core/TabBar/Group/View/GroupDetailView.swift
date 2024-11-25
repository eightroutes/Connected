import SwiftUI
import Kingfisher
import FirebaseAuth

struct GroupDetailView: View {
    let group: Groups
    
    @State private var showChatView = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    
    @StateObject private var viewModel = GroupDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                KFImage(URL(string: group.mainImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 400)
                    .clipped()
                    .padding(.top, 8)
                
                VStack(alignment: .leading){
                    Text(group.name)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    Text(group.description)
                        .font(.body)
                        .padding(.top, 5)
                    
                    Text("#\(group.theme)")
                        .padding(5)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    
                    
                    Text("위치: \(group.location)")
                        .font(.subheadline)
                        .padding(.top, 5)
                    
                    Text("멤버: \(group.memberCounts)명")
                        .font(.subheadline)
                        .padding(.top, 1)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    joinGroup()
                }) {
                    Text(viewModel.isMember ? "채팅방 입장" : "모임 참가")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.brand)
                        .cornerRadius(10)
                }
                .padding(.all)
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("오류"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("확인"))
                        
                    )
                }
                
                NavigationLink(destination: GroupChatView(group: group), isActive: $showChatView) {
                    EmptyView()
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.checkMembership(for: group)
        }
        .onReceive(viewModel.$isMember) { isMember in
            if isMember {
                // 이미 멤버인 경우 채팅방으로 이동할지 결정
                // showChatView = true
            }
        }
    }
    
    func joinGroup() {
        if viewModel.isMember {
            // 이미 멤버인 경우 채팅방으로 이동
            showChatView = true
        } else {
            // 그룹에 가입 요청
            viewModel.joinGroup(for: group) { success, error in
                if success {
                    showChatView = true
                } else if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(group: Groups.MOCK_GROUPS[0])
    }
}
