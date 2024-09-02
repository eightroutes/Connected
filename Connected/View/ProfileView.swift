import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase
import FirebaseCore


struct ProfileView: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var showNotifications = false
    @Binding var userId: String?



    var body: some View {
            ZStack {
                if let userProfile = firestoreManager.userProfile {
                    HStack(spacing: -40) {
                        Button(action: {
                            showNotifications = true
                        }) {
                            if let profileImage = userProfile.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle().stroke(.white, lineWidth: 2)
                                    }
                                    .shadow(radius: 2)
                                    .frame(width: 60, height: 60)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle().stroke(.white, lineWidth: 2)
                                    }
                                    .shadow(radius: 1)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            }
                        }
                        .zIndex(1.0)
                        .navigationDestination(isPresented: $showNotifications) {
                            NotificationView()
                                .tint(.brand)
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 110, height: 30)
                                    .foregroundStyle(Color.black)
                                Text(userProfile.name)
                                    .font(.headline)
                                    .padding(.leading, 20.0)
                                    .foregroundStyle(.white)
                                    .truncationMode(.tail)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 100, height: 20)
                                    .foregroundStyle(Color.white)
                                HStack(spacing: 2) {
                                    Image(systemName: "bitcoinsign.circle")
                                        .resizable()
                                        .frame(width: 13, height: 13)
                                    Text(userProfile.creditAmount)
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                                .padding(.leading, 20.0)
                            }
                        }
                        .padding(.leading, 16)
                        Spacer()
                    }
                    .padding(.leading)
                }
            }
            .onAppear {
                if let userId = userId {
                    firestoreManager.fetchUserProfile(userId: userId)
                }
            }
        }
    
}


#Preview {
    @State var showProfileDetail = false
    @State var userId: String? = "sampleUserId"
    
    return ProfileView(userId: $userId)
        .environmentObject(FirestoreManager()) // FirestoreManager가 @EnvironmentObject로 사용되는 경우
}

//struct ProfileView: View {
//    @StateObject private var firestoreManager = FirestoreManager()
////    @State private var showProfileDetail = false
//    @State var showNextScreen: Bool
//    @Binding var userId: String?
//
//    var body: some View {
//        ZStack {
//            Color.brandBack
//                .ignoresSafeArea()
//            if let userProfile = firestoreManager.userProfile {
//                HStack(spacing: -40) {
//                    Button(action: {
//                        showNextScreen = true
//                    }) {
//                        if let profileImage = userProfile.profileImage {
//                            Image(uiImage: profileImage)
//                                .resizable()
//                                .clipShape(Circle())
//                                .overlay {
//                                    Circle().stroke(.white, lineWidth: 2)
//                                }
//                                .shadow(radius: 2)
//                                .frame(width: 60, height: 60)
//                        } else {
//                            Image(systemName: "person.circle.fill")
//                                .resizable()
//                                .clipShape(Circle())
//                                .overlay {
//                                    Circle().stroke(.white, lineWidth: 2)
//                                }
//                                .shadow(radius: 1)
//                                .frame(width: 60, height: 60)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .background(
//                        NavigationLink(destination: notificationView(), isActive: $showNextScreen) {
//                        })
//                    .zIndex(1.0)
////                    .sheet(isPresented: $showProfileDetail) {
////                        if let userId = userId {
////                            ProfileDetail(userId: userId)
////                        }
////                         본인 프로필 클릭 시 notifications 뷰 보이기, 본인 프로필 디테일은 설정에서
////                        Notifications(isPresented: $showProfileDetail)
////                    }
////                    
//                    VStack(alignment: .leading, spacing: 1) {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 8)
//                                .frame(width: 110, height: 30)
//                                .foregroundStyle(Color.black)
//                            Text(userProfile.name)
//                                .font(.headline)
//                                .padding(.leading, 20.0)
//                                .foregroundStyle(.white)
//                                .truncationMode(.tail)
//                        }
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 8)
//                                .frame(width: 100, height: 20)
//                                .foregroundStyle(Color.white)
//                            HStack(spacing: 2) {
//                                Image(systemName: "bitcoinsign.circle")
//                                    .resizable()
//                                    .frame(width: 13, height: 13)
//                                Text(userProfile.creditAmount)
//                                    .font(.caption)
//                                    .foregroundColor(.black)
//                            }
//                            .padding(.leading, 20.0)
//                        }
//                    }
//                    .padding(.leading, 16)
//                    Spacer()
//                }
//                .padding(.leading)
//            }
////            else {
////                Text("Loading...")
////            }
//        }
//    
//        .onAppear {
//            if let userId = userId {
//                firestoreManager.fetchUserProfile(userId: userId)
//            }
//        }
//        //        .onAppear {
//        //            if let user = Auth.auth().currentUser {
//        //                userId = user.uid
//        //                firestoreManager.fetchUserProfile(userId: userId!)
//        //            } else {
//        //                print("User is not logged in.")
//        //            }
//        //        }
//    }
//}
//
////#Preview {
////    @State var showProfileDetail = false
////    @State var userId: String? = "sampleUserId"
////    
////    return ProfileView(showNextScreen: $showProfileDetail, userId: $userId)
////        .environmentObject(FirestoreManager()) // FirestoreManager가 @EnvironmentObject로 사용되는 경우
////}
//
//#Preview {
//    ProfileView(showNextScreen: $showNextScreen, userId: $userId)
//}
