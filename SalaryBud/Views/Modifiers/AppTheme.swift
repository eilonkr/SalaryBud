//
//  AppTheme.swift
//  SalaryBud
//
//  Created by Eilon Krauthammer on 24/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import SwiftUI

struct AppTheme: ViewModifier {
    private var gradientStartColor: UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .light {
                return UIColor(red: 0.724, green: 1.000, blue: 0.710, alpha: 0.35)
            }
            
            return UIColor(red: 0.069, green: 0.325, blue: 0.538, alpha: 0.8)
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(gradientStartColor), Color(.systemBackground)]), startPoint: .bottom, endPoint: .top)
            content
        }
        .edgesIgnoringSafeArea([.horizontal, .bottom])
    }
}
