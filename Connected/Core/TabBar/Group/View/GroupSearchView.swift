import SwiftUI

struct GroupSearchView: View {
    @StateObject private var viewModel = GroupSearchViewModel()
    
    @State private var showGroupDetail = false
    
    var body: some View {
        ZStack {
            VStack {
                // Search bar
                HStack {
                    TextField("검색", text: $viewModel.searchText)
                        .padding(.leading, 40)
                        .frame(height: 40)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 30)
                                Spacer()
                            }
                        )
                }
                .padding(.top, 14)
                .padding(.bottom, 8)

                if viewModel.isLoading {
                    // 로딩 상태 표시
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    // 에러 메시지 표시
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button(action: {
                            viewModel.fetchGroups()
                        }) {
                            Text("다시 시도")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredGroups.isEmpty {
                    // 검색 결과 없음
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // List of group cards
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(viewModel.filteredGroups) { group in
                                NavigationLink(destination: GroupDetailView(group: group)) {
                                    GroupCardView(group: group)
                                }
                            }

                        }
                        .padding(.horizontal)
                    }
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: AddGroupView()) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.brand)
                            .font(.title)
                            .frame(width: 40, height: 40)
                            .padding(10)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 1)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchGroups()
        }
    }
}

#Preview {
    GroupSearchView()
}
