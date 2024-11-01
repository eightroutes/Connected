//////
//////  MainViewNew.swift
//////  Connected
//////
//////  Created by 정근호 on 9/9/24.
//////
//
//import SwiftUI 
//import FirebaseAuth
//
//
//enum Tab {
//    case home, feed, connect, message, setting
//}
//
//struct CustomTabView: View {
//    
//    @Binding var selectedTab: Tab
//
//    var body: some View {
//        HStack(alignment: .center) {
//    
//            Button {
//                selectedTab = .home
//            } label: {
//                VStack(spacing: 8) {
//                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
//                        .environment(\.symbolVariants, selectedTab == .home ?.fill: .none)
//                    
//                }
//                .offset(x: -5)
//            }
//            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
//            
//           
//            
//            Button {
//                selectedTab = .feed
//            } label: {
//                VStack(spacing: 8) {
//                    Image(systemName: selectedTab == .feed ? "magnifyingglass" : "magnifyingglass")
//                        .environment(\.symbolVariants, selectedTab == .feed ?.fill: .none)
//                    
//
//                }
//                .offset(x: 5)
//            }
//            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
//            
//            Button {
//                selectedTab = .connect
//            } label: {
//                VStack(spacing: 8) {
//                    Image(systemName: selectedTab == .connect ? "center" : "centerGray")
//                        .environment(\.symbolVariants, selectedTab == .connect ?.fill: .none)
//                    
//
//                }
//                .offset(x: 5)
//            }
//            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
//            
//            
//            Button {
//                selectedTab = .message
//            } label: {
//                VStack(spacing: 8) {
//                    Image(systemName: selectedTab == .message ? "message.fill" : "message")
//                        .environment(\.symbolVariants, selectedTab == .message ?.fill: .none)
//                    
//
//                }
//                .offset(x: 5)
//            }
//            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
//            
//            Button {
//                selectedTab = .setting
//            } label: {
//                VStack(spacing: 8) {
//                    Image(systemName: selectedTab == .setting ? "person.fill" : "person")
//                        .environment(\.symbolVariants, selectedTab == .setting ?.fill: .none)
//                    
//
//                }
//                .offset(x: 5)
//            }
//            .padding(.horizontal, UIScreen.main.bounds.width/4 - 30)
//        }
//        .frame(width: UIScreen.main.bounds.width, height: 85)
//    }
//}
//
//struct TabbarView: View {
//    @State private var showProfileDetail = false
//    @State private var userId: String?
//    @EnvironmentObject var viewModel: SignInViewModel
//    
//    @State var selectedTab: Tab = .home
//    
//    var body: some View {
//        
//        VStack(spacing: 0) {
//            switch selectedTab {
//            case .home:
//                MainView()
//            case .feed:
//                FeedView()
//            case .connect:
//                ConnectFriends(userId: $userId)
//            case .message:
//                MainMessagesView()
//            case .setting:
//                SettingsAndInfo()
//            }
//            CustomTabView(selectedTab: $selectedTab)
//                .padding(.bottom, 15)
//        }
//        .edgesIgnoringSafeArea(.bottom)
//
//    }
//}
//
//#Preview {
//    TabbarView()
//
//
//}
//
//import SwiftUI
//import FirebaseAuth
//
//enum TabIndex{
//
//    case home, feed, connect, message, setting
//}
//
//struct MainViewCustom: View {
//    @State var tabIndex: TabIndex
//    
//    @State private var userId: String?
//
//    
//    
//    func changeMyView(tabIndex: TabIndex) ->  any View {
//        
//        switch tabIndex {
//        case .home:
//            return ZStack {
//                MainMap()
//                ProfileView(userId: $userId)
//                    .padding(.bottom, 650)
//            }
//        case .feed:
//            return FeedView()
//        case .connect:
//            return ConnectFriends(userId: $userId)
//
//        case .message:
//            return MainMessagesView()
//        case .setting:
//            return SettingsAndInfo()
//        }
//    }
//    
//    // x축 y축 등 모든 포지션은 CGFloat 자료형
//    func calcCircleBgPosition(tabIndex: TabIndex, geometry: GeometryProxy) -> CGFloat {
//        let tabWidth = geometry.size.width / 5
//        switch tabIndex {
//        case .home:
//            return -2 * tabWidth
//        case .feed:
//            return -tabWidth
//        case .connect:
//            return 0
//        case .message:
//            return tabWidth
//        case .setting:
//            return 2 * tabWidth
//        }
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .bottom) {
//                self.changeMyView(tabIndex: self.tabIndex)
//                
//            }
//        }
//    }
//}
//
//#Preview {
//    MainViewCustom(tabIndex: TabIndex.home)
//}
//


// MARK: - OLD
//import FirebaseFirestore
//import Combine
//import UIKit
//import FirebaseStorage
//import FirebaseAuth
//
//class FirestoreManager: ObservableObject {
//    @Published var usersLoc: [UserLocation] = []
//    @Published var users: [User] = []
//
//    private var db = Firestore.firestore()
//    private var listenerRegistration: ListenerRegistration?
//    private let storageHelper = FirebaseStorageHelper()
//
//    init() {
//        // 필요한 초기화 작업
//    }
//
//    // MARK: -- Mark Users Locations
//    func updateUserLocation(userId: String, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
//        db.collection("users").document(userId).updateData([
//            "latitude": latitude,
//            "longitude": longitude
//        ]) { error in
//            if let error = error {
//                print("Error updating user location: \(error)")
//                completion(false)
//            } else {
//                completion(true)
//            }
//        }
//    }
//
//    func fetchUserLocations() {
//        db.collection("users").addSnapshotListener { [weak self] (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//
//            self?.usersLoc = documents.compactMap { document -> UserLocation? in
//                let data = document.data()
//                guard let name = data["Name"] as? String,
//                      let latitude = data["latitude"] as? Double,
//                      let longitude = data["longitude"] as? Double else {
//                    return nil
//                }
//
//                let profileImageURL = data["profile_image"] as? String
//                let user = UserLocation(id: document.documentID,
//                                        name: name,
//                                        latitude: latitude,
//                                        longitude: longitude,
//                                        profileImageURL: profileImageURL ?? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png")
//
//                if let url = profileImageURL {
//                    self?.downloadImage(for: user, from: url)
//                }
//
//                return user
//            }
//        }
//    }
//
//    func downloadImage(for user: UserLocation, from url: String) {
//        storageHelper.downloadImage(from: url) { [weak self] image in
//            DispatchQueue.main.async {
//                if let index = self?.usersLoc.firstIndex(where: { $0.id == user.id }) {
//                    self?.usersLoc[index].profileImage = image
//                }
//            }
//        }
//    }
//
//    // deinit 메서드를 통해 Firestore의 리스너를 제거합니다.
//    deinit {
//        listenerRegistration?.remove()
//    }
//
//    // 유저 목록 Fetch 로직
//    func fetchUsers(completion: @escaping () -> Void) {
//        db.collection("users").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error fetching users: \(error)")
//                return
//            }
//
//            guard let documents = snapshot?.documents else {
//                print("No documents found")
//                return
//            }
//
//            self.users = documents.compactMap { doc -> User? in
//                let data = doc.data()
//                let id = doc.documentID
//                let name = data["Name"] as? String ?? ""
//                let profileImage = data["profile_image"] as? String ?? ""
//                let interests = data["Interests"] as? [String] ?? []
//                let selectedColor = data["Color"] as? String ?? ""
//                let selectedMBTI = data["MBTI"] as? String ?? ""
//                let musicGenres = data["Music"] as? [String] ?? []
//                let movieGenres = data["Movie"] as? [String] ?? []
//
//                return User
//            }
//
//            completion()
//        }
//    }
//}
//
//
//class FirebaseStorageHelper {
//    private let storage = Storage.storage()
//
//    func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
//        let storageRef = storage.reference(forURL: url)
//        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
//            if let error = error {
//                print("Error downloading image: \(error)")
//                completion(nil)
//            } else {
//                if let data = data {
//                    let image = UIImage(data: data)
//                    completion(image)
//                } else {
//                    completion(nil)
//                }
//            }
//        }
//    }
//}
