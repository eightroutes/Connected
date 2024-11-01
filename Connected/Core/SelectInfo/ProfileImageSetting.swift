import SwiftUI
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import CropViewController

struct ProfileImageSetting: View {
    @State private var showNextScreen = false
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCropView = false
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    let user: User
    
    var body: some View {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/ProfileImageSetting.swift
        NavigationStack(path: $navigationPath){
========
        NavigationStack {
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/ProfileImageSetting.swift
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width / 7 * 6, height: 5)
                            .padding(.leading, -200)
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
                    
                    Text("프로필을 설정해주세요")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .padding(.bottom, 80)
                    
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 150, height: 150)
                            .overlay {
                                Circle().stroke(.white, lineWidth: 2)
                            }
                            .shadow(radius: 1)
                        
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 1)
                        }
                        .offset(x: 60, y: 60)
                    }
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
                            .background(profileImage == nil ? Color.unselectedButton : Color.brand)
                            .cornerRadius(30)
                    }
                    .disabled(profileImage == nil)
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/ProfileImageSetting.swift
                    .background(NavigationLink(destination: setImages(), isActive: $showNextScreen){})
                    //                    .hidden()
========
                    .navigationDestination(isPresented: $showNextScreen)
                    {
                        SetImages(user: user)
                    }                    //                    .hidden()
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/ProfileImageSetting.swift
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(isPresented: $showingImagePicker, selectedImage: $profileImage, showCropView: $showingCropView)
            }
            .fullScreenCover(isPresented: $showingCropView) {
                if let image = profileImage {
                    CropViewControllerWrapper(image: image, croppedImage: $profileImage, isPresented: $showingCropView)
                }
            }
        }
        .tint(.black)
    }
    
    
    func uploadImages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.8) else { return }
        
        let imageName = "\(userId)_profile.jpg"
        let imageRef = storage.reference().child("profile_images/\(imageName)")
        
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    return
                }
                
                guard let downloadURL = url?.absoluteString else { return }
                saveProfileUrlsToFirestore(url: downloadURL)
                showNextScreen = true
            }
        }
    }
    
    func saveProfileUrlsToFirestore(url: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).setData(["profile_image": url], merge: true) { error in
            if let error = error {
                print("Error saving profile URL: \(error)")
            } else {
                print("Profile URL saved successfully")
            }
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
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
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
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

struct CropViewControllerWrapper: UIViewControllerRepresentable {
    var image: UIImage
    @Binding var croppedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
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
        let parent: CropViewControllerWrapper
        
        init(_ parent: CropViewControllerWrapper) {
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

struct ProfileImageSetting_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageSetting(user: User.MOCK_USERS[0])
    }
}

