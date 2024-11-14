import SwiftUI
import Kingfisher

struct FindGroup: View {
    @State private var searchText: String = ""
    
    let groups: Groups
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Search bar
                    HStack {
                        TextField("\(Image(systemName:"magnifyingglass")) 검색", text: $searchText)
                            .padding(.leading, 10)
                            .frame(height: 40)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    
                    // List of group cards
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(Groups.MOCK_GROUPS, id: \.name) { group in
                                GroupCardView(group: group)
                            }
                        }
                        .padding(.horizontal)
                        
                    }//ScrollView
                    Spacer()
                    
                }//VStack
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: AddGroupView()){
                            Image(systemName: "plus")
                                .foregroundStyle(.brand)
                                .font(.title)
                                .frame(width: 40, height: 40)
                                .padding(10)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 1)
                                .padding()
                        }
                    }
                }
            }//ZStack
 
        }
        .navigationTitle("모임 찾기")
        .navigationBarTitleDisplayMode(.large)
        .tint(.black)
    }
}



// Group card view
struct GroupCardView: View {
    let group: Groups
    
    var body: some View {
        HStack(alignment: .top) {
            KFImage(URL(string: group.mainImageUrl))
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.1)
//                )
                .shadow(radius: 1)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(group.name)
                    .font(.headline)
                
                Text(group.descriptions)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(group.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(group.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("멤버 \(group.memberCounts)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 5)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture {
            
        }
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
    FindGroup(groups: Groups.MOCK_GROUPS[0])
}
