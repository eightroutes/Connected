import SwiftUI
import Kingfisher

struct GroupView: View {
    @State private var selectedTab: Int = 0
    @State private var groups: [Groups] = Groups.MOCK_GROUPS // 그룹 목록 관리
    
    var body: some View {
        VStack {
            CustomTopBar(selectedTab: $selectedTab)
            
            switch selectedTab {
            case 0:
                GroupSearchView() // 그룹 목록을 바인딩
            case 1:
                MyGroupView()
            default:
                GroupSearchView()
            }
        }
        .navigationTitle("모임")
        .navigationBarTitleDisplayMode(.large)
        .tint(.black)
    }
}






struct CustomTopBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            Button(action: {
                selectedTab = 0
            }) {
                VStack {
                    Text("검색")
                        .foregroundStyle(selectedTab == 0 ? .black : .gray)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(selectedTab == 0 ? .black : .gray.opacity(0.5))
                    
                }
            }
            
            
            Button(action: {
                selectedTab = 1
            }) {
                VStack {
                    Text("내 모임")
                        .foregroundStyle(selectedTab == 1 ? .black : .gray)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(selectedTab == 1 ? .black : .gray.opacity(0.5))
                    
                }
            }
            
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}
//// Empty group card for placeholder
//struct EmptyGroupCard: View {
//    var body: some View {
//        RoundedRectangle(cornerRadius: 12)
//            .fill(Color.white)
//            .frame(height: 80)
//            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//    }
//}

#Preview {
    GroupView()
}
