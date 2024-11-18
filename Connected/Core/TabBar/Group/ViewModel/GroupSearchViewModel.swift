//
//  GroupSearchViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/18/24.
//

import Foundation
import FirebaseFirestore
import Combine

class GroupSearchViewModel: ObservableObject {
    @Published var allGroups: [Groups] = []
    @Published var filteredGroups: [Groups] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchGroups()
        setupSearch()
    }

    func fetchGroups() {
        isLoading = true
        errorMessage = nil

        db.collection("groups")
            .order(by: "memberCounts", descending: true) // 멤버 수에 따른 내림차순 정렬
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = "그룹을 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
                        return
                    }

                    self?.allGroups = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Groups.self)
                    } ?? []

                    self?.applySearch() // 검색어에 따른 필터링 적용
                }
            }
    }

    private func setupSearch() {
        // searchText의 변화를 관찰하여 필터링 적용
        $searchText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySearch()
            }
            .store(in: &cancellables)
    }

    private func applySearch() {
        if searchText.isEmpty {
            filteredGroups = allGroups
        } else {
            let lowercasedSearchText = searchText.lowercased()
            filteredGroups = allGroups.filter { group in
                group.name.lowercased().contains(lowercasedSearchText) ||
                group.location.lowercased().contains(lowercasedSearchText) ||
                group.theme.contains(where: { $0.lowercased().contains(lowercasedSearchText) })
            }
        }
    }
}
