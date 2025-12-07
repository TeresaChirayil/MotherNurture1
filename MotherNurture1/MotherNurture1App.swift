//
//  MotherNurture1App.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI
import FirebaseCore

@main
struct MotherNurture1App: App {
    @StateObject private var userDataManager = UserDataManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userDataManager.isAuthenticated {
                    // Use NavigationStack only for authenticated views, not for login
                    NavigationStack {
                        MainTabView()
                            .environmentObject(userDataManager)
                    }
                    .navigationBarBackButtonHidden(true)
                } else {
                    // Login screen - no NavigationStack to prevent back navigation
                    ContentView()
                        .environmentObject(userDataManager)
                }
            }
            // Smoothen push/pop animations across the app
            .animation(.easeInOut(duration: 0.25), value: userDataManager.isAuthenticated)
        }
    }
}
