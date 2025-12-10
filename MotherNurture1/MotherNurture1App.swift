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
                    
                    // Authenticated area
                    NavigationStack {
                        MainTabView()
                            .environmentObject(userDataManager)
                            .navigationBarBackButtonHidden(true)   // ← moved HERE
                    }
                    
                } else {
                    
                    // Login Screen — NOT wrapped in NavigationStack
                    ContentView()
                        .environmentObject(userDataManager)
                }
            }
            .id(userDataManager.isAuthenticated ? "authenticated" : "notAuthenticated")
            .animation(.easeInOut(duration: 0.25),
                       value: userDataManager.isAuthenticated)
        }
    }
}
