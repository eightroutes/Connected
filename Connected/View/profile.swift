import SwiftUI

let profileName: String = "Name"
let creditAmount: String = "1000"

struct profile: View {
    @State private var showProfileDetail = false
    
    var body: some View {
        ZStack {
            HStack(spacing: -40) {
                Button(action: {
                    showProfileDetail = true
                }) {
                    Image("moon")
                        .resizable()
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(.white, lineWidth: 2)
                        }
                        .shadow(radius: 2)
                        .frame(width: 60, height: 60)
                }
                .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                .sheet(isPresented: $showProfileDetail) {
                    profileDetail()
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 110, height: 30)
                            .foregroundStyle(Color.black)
                        Text(profileName)
                            .font(.headline)
                            .padding(.leading, 20.0)
                            .foregroundStyle(.white)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 100, height: 20)
                            .foregroundStyle(Color.white)
                        HStack(spacing: 2) {
                            Image(systemName: "bitcoinsign.circle")
                                .resizable()
                                .frame(width: 13, height: 13)
                            Text(creditAmount)
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
}

#Preview {
    profile()
}
