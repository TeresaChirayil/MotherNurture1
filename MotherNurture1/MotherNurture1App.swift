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
            NavigationView {
                ContentView()
                    .environmentObject(userDataManager)
            }
        }
    }
}
