//
//  MainTabView.swift
//  MotherNurture1
//
//  Main tab view that manages all tabs and prevents navigation back to login
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var currentTab: TabDestination = .channels
    
    var body: some View {
        ZStack {
            // Show the appropriate view based on current tab
            Group {
                switch currentTab {
                case .channels:
                    ChannelsView()
                        .environmentObject(userDataManager)
                case .links:
                    MatchmakingView()
                        .environmentObject(userDataManager)
                case .forum:
                    ForumView()
                        .environmentObject(userDataManager)
                case .map:
                    MapView()
                        .environmentObject(userDataManager)
                case .profile:
                    ProfileView()
                        .environmentObject(userDataManager)
                }
            }
            
            // Bottom navigation bar overlay
            VStack {
                Spacer()
                BottomNavBar(currentTab: $currentTab)
                    .environmentObject(userDataManager)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Ensure we start on channels tab
            currentTab = .channels
        }
    }
}






