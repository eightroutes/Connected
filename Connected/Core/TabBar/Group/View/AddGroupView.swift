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
    @State private var groupDescription = ""
    @State private var groupImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCropView = false

    
    
    @StateObject private var vm = GroupViewModel();

    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .shadow(radius: 1)
                        
                        if let image = groupImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        
                    }//ZStack
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePickerView(isPresented: $showingImagePicker, selectedImage: $groupImage, showCropView: $showingCropView)
                    }
                    .fullScreenCover(isPresented: $showingCropView) {
                        if let image = groupImage {
                            CropViewControllerWrapper(image: image, croppedImage: $groupImage, isPresented: $showingCropView)
                        }
                    }
                        
                
                    
                    
                    VStack {
                        HStack{
                            Text("지역")
                            TextField("지역", text: $locationText)
                        }
                        
                        
                        HStack{
                            Text("이름")
                            TextField("모임 이름", text: $groupName)
                        }
                        
                        HStack {
                            Text("주제")
                            TextField("주제 이름", text: $theme)
                            
                        }
                    }
                    
                }
                
                
                HStack {
                    TextField("모임에 대해 설명해주세요", text: $groupDescription)
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("모임 만들기")
                        .frame(width: 250)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.brand)
                        .cornerRadius(30)
                }
                
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    AddGroupView()
}
