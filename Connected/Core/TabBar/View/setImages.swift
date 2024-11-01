import SwiftUI
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import CropViewController


struct setImages: View {
    @State private var inputName = ""
    @State private var showNextScreen = false
    @State private var profileImages: [UIImage?] = Array(repeating: nil, count: 6)
    @State private var showImagePicker = false
    @State private var showCropView = false
    @State private var currentImageIndex = 0
    
    @StateObject var viewModel = LoginViewModel()
    
    let user: User
    
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/setImages.swift
                            .frame(width: UIScreen.main.bounds.width/7*6, height: 5)
                            .padding(.leading, -200)
========
                            .frame(width: UIScreen.main.bounds.width/7*7, height: 5)
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/SetImages.swift
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
                    
                    Spacer()
                    Text("사진을 추가하세요")
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
                        Task { try await viewModel.signIn() }
                        
                    }) {
                        Text("다음")
                            .frame(width: 250)
                            .foregroundColor(.white)
                            .padding()
                            .background(profileImages.contains(where: { $0 != nil }) ? Color.black : Color.unselectedButton)
                            .cornerRadius(30)
                    }
                    .disabled(!profileImages.contains(where: { $0 != nil }))
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/setImages.swift
                    .background(NavigationLink(destination: mainView(), isActive: $showNextScreen){})
                    //                    .hidden()
========
                    //                    NavigationLink(destination: MainView(), isActive: $showNextScreen){}
                    //                    //                    .hidden()
                    .navigationDestination(isPresented: $showNextScreen)
                    {
                        MainView(user: user)
                    }
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/SetImages.swift
                }
                
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(isPresented: $showImagePicker, selectedImage: $profileImages[currentImageIndex], showCropView: $showCropView)
                
            }
        }//NavigationStack
        .tint(.black)
    }
    
    func uploadImages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let group = DispatchGroup()
        var uploadedUrls: [String] = []
        
        for (index, image) in profileImages.enumerated() {
            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            
            group.enter()
            let imageName = "\(userId)_profile_\(index).jpg"
            let imageRef = storage.reference().child("other_images/\(imageName)")
            
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
        db.collection("users").document(userId).setData(["other_images": urls], merge: true) { error in
            if let error = error {
                print("Error saving profile URLs: \(error)")
            } else {
                print("Profile URLs saved successfully")
            }
        }
    }
}

struct ImagePickerViewS: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var showCropView: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerViewS
        
        init(_ parent: ImagePickerViewS) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                parent.showCropView = true
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct CropViewControllerWrapperS: UIViewControllerRepresentable {
    var image: UIImage
    @Binding var croppedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = context.coordinator
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: CropViewControllerWrapperS
        
        init(_ parent: CropViewControllerWrapperS) {
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.croppedImage = image
            parent.isPresented = false
        }
        
        func cropViewControllerDidCancel(_ cropViewController: CropViewController) {
            parent.isPresented = false
        }
    }
}


struct setImages_Previews: PreviewProvider {
    static var previews: some View {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/setImages.swift
        setImages()
========
        SetImages(user: User.MOCK_USERS[0])
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/SetImages.swift
    }
}


