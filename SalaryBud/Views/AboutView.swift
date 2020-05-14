//
//  AboutView.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 28/04/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI
import StoreKit

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let socialsInfo: [SocialInfo] = [
        SocialInfo(iconName: "icnmail", openURL: "mailto:eilonkrauthammer@gmail.com"),
        SocialInfo(iconName: "icntwitter", openURL: "https://twitter.com/mitleyber"),
        SocialInfo(iconName: "icngithub", openURL: "https://github.com/eilonkr"),
    ]
    
    var body: some View {
        VStack(spacing: 100) {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(Color(.quaternarySystemFill))
                        .frame(width: 44, height: 44)
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 40.0)
            
            VStack(spacing: 20) {
                Image("eilon")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 4))
                
                Text("Hi, I'm Eilon.")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.systemIndigo))
                VStack(spacing: 4.0) {
                    Text("I'm the developer of the SalaryBud app!")
                        .fontWeight(.medium)
                    Text("You can reach out to me on socials for more information and inquiries.").multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .padding(.horizontal, 40.0)
                
                HStack {
                    ForEach(socialsInfo, id: \.self) { info in
                        SocialButton(socialInfo: info)
                    }
                }
                
                Button(action: {
                    SKStoreReviewController.requestReview()
                }) {
                    HStack {
                        Image(systemName: "star.circle.fill")
                        Text("Rate on the App Store").fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12.0)
                    .padding(.vertical, 8.0)
                    .background(Color(.systemIndigo).opacity(0.7))
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: .greatestFiniteMagnitude))
                }
                .padding(.top)
                
                Text("© Copyright Eilon Krauthammer 2020. All rights reserved")
                    .font(.footnote)
                    .foregroundColor(Color(.tertiaryLabel))
                    .padding(.top)
            }

            Spacer()
        }
        .modifier(AppTheme())
    }
}

struct SocialInfo: Hashable {
    let iconName: String
    let openURL: String
}

struct SocialButton: View {
    let socialInfo: SocialInfo
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(.quaternarySystemFill))
                .frame(width: 50, height: 50)
            Button(action: {
                if let url = URL(string: self.socialInfo.openURL) {
                    UIApplication.shared.open(url, options: [:])
                }
            }) {
                Image(socialInfo.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.pink)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
