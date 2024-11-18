//
//  MyGroupViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/17/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class MyGroupViewModel: ObservableObject {
    @Published var myGroups: [Groups] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchMyGroups()
    }

    func fetchMyGroups() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "사용자가 인증되지 않았습니다."
            return
        }

        isLoading = true
        errorMessage = nil

        db.collection("groups")
            .whereField("members", arrayContains: currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = "그룹을 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
                        return
                    }

                    self?.myGroups = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Groups.self)
                    } ?? []
                }
            }
    }
}

