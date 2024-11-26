//
//  GroupCardView.swift
//  Connected
//
//  Created by 정근호 on 11/17/24.
//

import SwiftUI
import Kingfisher

struct GroupCardView: View {
    let group: Groups
    
    var body: some View {
                HStack(alignment: .top) {
                    KFImage(URL(string: group.mainImageUrl))
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    //                .overlay(
                    //                    RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 0.1)
                    //                )
                        .shadow(radius: 1)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(group.name)
                            .font(.headline)
                        
                        Text(group.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("#\(group.theme)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            
                            Text(group.location)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("멤버 \(group.memberCounts)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    

#Preview {
    GroupCardView(group: Groups.MOCK_GROUPS[0])
}
