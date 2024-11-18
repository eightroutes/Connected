//
//  MyGroupView.swift
//  Connected
//
//  Created by 정근호 on 11/17/24.
//

import SwiftUI
import Kingfisher

struct MyGroupView: View {
    @StateObject private var viewModel = MyGroupViewModel()

    var body: some View {
        Group {
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
                        viewModel.fetchMyGroups()
                    }) {
                        Text("다시 시도")
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.myGroups.isEmpty {
                // 가입된 그룹이 없는 경우
                Text("가입된 모임이 없습니다.")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 가입된 그룹 목록 표시
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.myGroups) { group in
                            GroupCardView(group: group)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            viewModel.fetchMyGroups()
        }
    }
}



#Preview {
    MyGroupView()
}
