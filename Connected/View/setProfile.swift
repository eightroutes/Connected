import SwiftUI
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct setProfile: View {
    @State private var inputName = ""
    @State private var showNextScreen = false
    @State private var navigationPath = NavigationPath()
    @State private var profileImages: [UIImage?] = Array(repeating: nil, count: 6)
    @State private var showImagePicker = false
    @State private var currentImageIndex = 0
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width/7*6, height: 5)
                            .padding(.leading, -200)
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    Text("프로필을 설정해주세요")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    
                    HStack(spacing: 10) {
                        ForEach(0..<3) { index in
                            ZStack {
                                if let image = profileImages[index] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 110, height: 200)
                                        .clipped()
                                }
                                else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 110, height: 200)
                                    Image(systemName: "plus")
                                        .foregroundColor(.gray)
                                }
                            }
                            .onTapGesture {
                                currentImageIndex = index
                                showImagePicker = true
                            }
                        }
                    }
                    HStack(spacing: 10) {
                        ForEach(3..<6) { index in
                            ZStack {
                                if let image = profileImages[index] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 110, height: 200)
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 110, height: 200)
                                    Image(systemName: "plus")
                                        .foregroundColor(.gray)
                                }
                            }
                            .onTapGesture {
                                currentImageIndex = index
                                showImagePicker = true
                            }
                        }
                    }
                    
                    
                    .padding()
                    
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        uploadImages()
                    }) {
                        Text("다음")
                            .frame(width: 250)
                            .foregroundColor(.white)
                            .padding()
                            .background(profileImages.contains(where: { $0 != nil }) ? Color.black : Color.unselectedButton)
                            .cornerRadius(30)
                    }
                    .disabled(!profileImages.contains(where: { $0 != nil }))
                    .background(
                        NavigationLink(destination: mainView(), isActive: $showNextScreen) {
                             mainView()
                        }
                        .hidden()
                    )
                }
            }
            .ignoresSafeArea(.keyboard)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImages[currentImageIndex])
            }
        }
        .accentColor(.black)
    }
    
    func uploadImages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let group = DispatchGroup()
        var uploadedUrls: [String] = []
        
        for (index, image) in profileImages.enumerated() {
            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            
            group.enter()
            let imageName = "\(userId)_profile_\(index).jpg"
            let imageRef = storage.reference().child("profile_images/\(imageName)")
            
            imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error)")
                } else {
                    imageRef.downloadURL { (url, error) in
                        if let downloadURL = url?.absoluteString {
                            uploadedUrls.append(downloadURL)
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            saveProfileUrlsToFirestore(urls: uploadedUrls)
            showNextScreen = true
        }
    }
    
    func saveProfileUrlsToFirestore(urls: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).setData(["profile_images": urls], merge: true) { error in
            if let error = error {
                print("Error saving profile URLs: \(error)")
            } else {
                print("Profile URLs saved successfully")
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    setProfile()
}
