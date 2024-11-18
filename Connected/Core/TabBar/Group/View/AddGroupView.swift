//
//  AddGroupView.swift
//  Connected
//
//  Created by 정근호 on 11/14/24.
//

import SwiftUI


struct AddGroupView: View {
    @State private var locationText = ""
    @State private var groupName = ""
    @State private var theme = ""
    @State private var tagInput = ""
    @State private var groupDescription = ""
    @State private var groupImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCropView = false
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    
    @StateObject private var vm = GroupViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    // 이미지 추가
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .shadow(radius: 1)
                        
                        if let image = groupImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Rectangle())
                            
                        }
                        
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if groupImage == nil {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                        }
                        
                    }//ZStack
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePickerView(isPresented: $showingImagePicker, selectedImage: $groupImage, showCropView: $showingCropView)
                    }
                    .fullScreenCover(isPresented: $showingCropView) {
                        if let image = groupImage {
                            CropViewControllerWrapper(image: image, croppingShape: .default, croppedImage: $groupImage, isPresented: $showingCropView)
                        }
                    }
                    VStack {
                        HStack{
                            TextField("지역", text: $locationText)
                                .padding()
                                .frame(height: 36)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                        
                        
                        HStack{
                            TextField("모임 이름", text: $groupName)
                                .padding()
                                .frame(height: 36)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                        
                        HStack {
                            TextField("주제", text: $theme)
                                .padding()
                                .frame(height: 36)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
            
                        }
                        
                        
                        
                    }
                    
                }
                
                
                HStack {
                    
                    TextEditor(text: $groupDescription)
                        .frame(height: 350)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    
                }
                
                
                
                
                Spacer()
                
                // 오류 메시지 표시
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.bottom, 5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                errorMessage = ""
                            }
                        }
                }

                
                Button {
                    createGroup()
                } label: {
                    Text("모임 만들기")
                        .frame(width: 250)
                        .foregroundColor(.white)
                        .padding()
                        .background(isValidInput() ? Color.brand : Color.secondary)
                        .cornerRadius(30)
                }
                .disabled(!isValidInput())
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("모임 생성 완료"), message: Text("모임이 성공적으로 생성되었습니다."), dismissButton: .default(Text("확인")) {
                        // 네비게이션 또는 다른 동작
                    })
                }
                
                
                
            }
            .padding()
            .navigationTitle("모임 만들기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 입력 값 검증
    private func isValidInput() -> Bool {
        return !locationText.isEmpty && !groupName.isEmpty && !theme.isEmpty && !groupDescription.isEmpty
    }
    
    // 그룹 생성 함수
    private func createGroup() {
        vm.createGroup(name: groupName, description: groupDescription, theme: theme, location: locationText, image: groupImage) { success, error in
            if success {
                showAlert = true
                // 입력 필드 초기화
                locationText = ""
                groupName = ""
                theme = ""
                groupDescription = ""
                groupImage = nil
            } else if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
    
}

#Preview {
    AddGroupView()
}
