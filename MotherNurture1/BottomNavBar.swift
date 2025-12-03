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
    
    var body: some View {
        HStack {
            Spacer()
            
            // 💬 Channels
            NavigationLink(destination: ChannelsView()) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .channels ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            
            Spacer()
            
            // 🔗 Links
            NavigationLink(destination: MatchmakingView()) {
                Image(systemName: "link")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .links ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            
            Spacer()
            
            // 📖 Forum
            NavigationLink(destination: ForumView()) {
                Image(systemName: "book")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .forum ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            
            Spacer()
            
            // 📍 Map
            NavigationLink(destination: MapView()) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .map ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }

            
            Spacer()
            
            // 👤 Profile
            NavigationLink(destination: ProfileView().environmentObject(UserDataManager.shared)) {
                Image(systemName: "person")
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == .profile ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
        .background(Color(hex: "F8F5EE"))
//        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 5, y: -3)
//        .padding(.horizontal, 20)
    }
}

//#Preview {
//    NavigationStack {
//        BottomNavBar(currentTab: .constant(.forum))
//    }
//}
