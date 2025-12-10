//
//  BottomNavBar.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/05/25.
//

import SwiftUI

/// Enum representing the different tabs in the app
enum TabDestination {
    case channels
    case links
    case forum
    case map
    case profile
}

/// Reusable bottom navigation bar for all screens
struct BottomNavBar: View {
    @Binding var currentTab: TabDestination
    @EnvironmentObject private var userDataManager: UserDataManager
    
    var body: some View {
        HStack {
            Spacer()
            
            // 💬 Channels
            Button(action: { currentTab = .channels }) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .channels ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 🔗 Links
            Button(action: { currentTab = .links }) {
                Image(systemName: "link")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .links ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 📖 Forum
            Button(action: { currentTab = .forum }) {
                Image(systemName: "book")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .forum ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 📍 Map
            Button(action: { currentTab = .map }) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .map ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
            
            // 👤 Profile
            Button(action: { currentTab = .profile }) {
                Image(systemName: "person")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .profile ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.vertical, 16)
        .background(Color(hex: "F8F5EE"))
        .shadow(color: .black.opacity(0.15), radius: 5, y: -3)
    }
}
