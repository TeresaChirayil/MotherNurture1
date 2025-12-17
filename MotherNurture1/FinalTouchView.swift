
//////
//////  FinalTouchView.swift
//////  MotherNurture1
//////
//////  Created by 40 GO Participant on 11/4/25.
//////
////
////import SwiftUI
////
////struct FinalTouchView: View {
////    @Environment(\.dismiss) var dismiss
////    @EnvironmentObject var userDataManager: UserDataManager
////    @State private var description: String = ""
////////    @State private var isSaving = false
////    
////    var body: some View {
////        ZStack {
////                // Background color (beige to match other screens)
////                Color(hex: "F8F5EE")
////                    .ignoresSafeArea()
////                
////                VStack(spacing: 0) {
////                    Spacer()
////                    
////                    ScrollView {
////                        // Main Content
////                        VStack(alignment: .leading, spacing: 30) {
////                            // Instruction
////                            Text("Last step - add a quick intro or photo so others can get to know you!")
////                                .font(.system(size: 32, weight: .bold, design: .rounded))
////                                .foregroundColor(Color(hex: "5C3D2E"))
////                                .multilineTextAlignment(.center)
////                                .frame(maxWidth: .infinity)
////                                .padding(.horizontal, 40)
////                            
////                            // Photo Section
////                            VStack(alignment: .leading, spacing: 12) {
////                                Text("Photo:")
////                                    .font(.system(size: 16, weight: .medium, design: .rounded))
////                                    .foregroundColor(Color(hex: "5C3D2E"))
////                                
////                                Button(action: {
////                                    // Handle photo selection
////                                }) {
////                                    ZStack {
////                                        Circle()
////                                            .fill(Color(hex: "8B9A7E"))
////                                            .frame(width: 120, height: 120)
////                                        
////                                        Image(systemName: "mountain.2.fill")
////                                            .foregroundColor(.white)
////                                            .font(.system(size: 50))
////                                    }
////                                }
////                                .buttonStyle(PlainButtonStyle())
////                            }
////                            .padding(.horizontal, 40)
////                            
////                            // Short Description Section
////                            VStack(alignment: .leading, spacing: 12) {
////                                Text("Short Description:")
////                                    .font(.system(size: 16, weight: .medium, design: .rounded))
////                                    .foregroundColor(Color(hex: "5C3D2E"))
////                                
////                                TextField("Tell us about yourself", text: $description, axis: .vertical)
////                                    .textFieldStyle(FinalTouchTextFieldStyle())
////                                    .lineLimit(5...10)
////                            }
////                            .padding(.horizontal, 40)
////                        }
////                        .padding(.top, 60)
////                        .padding(.bottom, 40)
////                    }
////                    
////                    // Bottom Navigation
////                    HStack {
////                        // Previous Button
////                        Button(action: {
////                            dismiss()
////                        }) {
////                            HStack(spacing: 4) {
////                                Image(systemName: "chevron.left")
////                                    .font(.system(size: 14, weight: .medium))
////                                    .foregroundColor(Color(hex: "5C3D2E"))
////                                
////                                Text("Previous")
////                                    .font(.system(size: 16, weight: .medium, design: .rounded))
////                                    .foregroundColor(Color(hex: "5C3D2E"))
////                            }
////                        }
////                        .buttonStyle(PlainButtonStyle())
////                        
////                        Spacer()
////                        
////                        // Done Button
////                        Button(action: {
////                            // Save final touch data
////                            userDataManager.profile.shortDescription = description.isEmpty ? nil : description
////                            
////                            // Save to Firebase
////                            isSaving = true
////                            Task {
////                                do {
////                                    try await userDataManager.saveToFirebase()
////                                    isSaving = false
////                                    navigateToChannels = true
////                                } catch {
////                                    print("Error saving to Firebase: \(error)")
////                                    isSaving = false
////                                    // Still navigate even if save fails
////                                    navigateToChannels = true
////                                }
////                            }
////                        }) {
////                            if isSaving {
////                                ProgressView()
////                                    .tint(.white)
////                                    .padding(.horizontal, 32)
////                                    .padding(.vertical, 12)
////                                    .background(Color(hex: "8B9A7E"))
////                                    .cornerRadius(12)
////                            } else {
////                                Text("Done!")
////                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
////                                    .foregroundColor(.white)
////                                    .padding(.horizontal, 32)
////                                    .padding(.vertical, 12)
////                                    .background(Color(hex: "8B9A7E"))
////                                    .cornerRadius(12)
////                            }
////                        }
////                        .buttonStyle(PlainButtonStyle())
////                        .disabled(isSaving)
////                    }
////                    .padding(.horizontal, 40)
////                    .padding(.bottom, 40)
////                }
////                .navigationDestination(isPresented: $navigateToChannels) {
////                    ChannelsView()
////                        .environmentObject(userDataManager)
////                }
////            }
////            .toolbar(.hidden, for: .navigationBar)
////    }
////}
////
////// Custom TextField Style for Final Touch
////struct FinalTouchTextFieldStyle: TextFieldStyle {
////    func _body(configuration: TextField<Self._Label>) -> some View {
////        configuration
////            .padding()
////            .frame(minHeight: 120)
////            .background(Color(hex: "8B9A7E")) // Olive green background
////            .cornerRadius(12)
////            .foregroundColor(Color(hex: "5C3D2E"))
////            .font(.system(size: 16, design: .rounded))
////    }
////}
////
////#Preview {
////    FinalTouchView()
////}
////
//
////
////  FinalTouchView.swift
////  MotherNurture1
////
////  Created by 40 GO Participant on 11/4/25.
////
//
//import SwiftUI
//
//struct FinalTouchView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var userDataManager: UserDataManager
//    @State private var description: String = ""
////    @State private var isSaving = false
//    @State private var showingImagePicker = false
//    @State private var selectedImage: UIImage? = nil
//    
//    var body: some View {
//        ZStack {
//                // Background color (beige to match other screens)
//                Color(hex: "F8F5EE")
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    Spacer()
//                    
//                    ScrollView {
//                        // Main Content
//                        VStack(alignment: .leading, spacing: 30) {
//                            // Instruction
//                            Text("Last step - add a quick intro or photo so others can get to know you!")
//                                .font(.system(size: 32, weight: .bold, design: .rounded))
//                                .foregroundColor(Color(hex: "5C3D2E"))
//                                .multilineTextAlignment(.center)
//                                .frame(maxWidth: .infinity)
//                                .padding(.horizontal, 40)
//                            
//                            // Photo Section
//                            VStack(alignment: .leading, spacing: 12) {
//                                Text("Photo:")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                Button(action: {
//                                    showingImagePicker = true
//                                }) {
//                                    ZStack {
//                                        Circle()
//                                            .fill(Color(hex: "8B9A7E"))
//                                            .frame(width: 120, height: 120)
//                                        
//                                        if let selectedImage = selectedImage {
//                                            Image(uiImage: selectedImage)
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fill)
//                                                .frame(width: 120, height: 120)
//                                                .clipShape(Circle())
//                                        } else {
//                                            Image(systemName: "mountain.2.fill")
//                                                .foregroundColor(.white)
//                                                .font(.system(size: 50))
//                                        }
//                                    }
//                                }
//                                .buttonStyle(PlainButtonStyle())
//                            }
//                            .padding(.horizontal, 40)
//                            
//                            // Short Description Section
//                            VStack(alignment: .leading, spacing: 12) {
//                                Text("Short Description:")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                TextField("Tell us about yourself", text: $description, axis: .vertical)
//                                    .textFieldStyle(FinalTouchTextFieldStyle())
//                                    .lineLimit(5...10)
//                            }
//                            .padding(.horizontal, 40)
//                        }
//                        .padding(.top, 60)
//                        .padding(.bottom, 40)
//                    }
//                    
//                    // Bottom Navigation
//                    HStack {
//                        // Previous Button
//                        Button(action: {
//                            dismiss()
//                        }) {
//                            HStack(spacing: 4) {
//                                Image(systemName: "chevron.left")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                Text("Previous")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        Spacer()
//                        
//                        // Done Button
//                        Button(action: {
//                            // Save final touch data
//                            userDataManager.profile.shortDescription = description.isEmpty ? nil : description
//                            
//                            // Save to Firebase
//                            isSaving = true
//                            Task {
//                                do {
//                                    try await userDataManager.saveToFirebase()
//                                    isSaving = false
//                                    navigateToChannels = true
//                                } catch {
//                                    print("Error saving to Firebase: \(error)")
//                                    isSaving = false
//                                    // Still navigate even if save fails
//                                    navigateToChannels = true
//                                }
//                            }
//                        }) {
//                            if isSaving {
//                                ProgressView()
//                                    .tint(.white)
//                                    .padding(.horizontal, 32)
//                                    .padding(.vertical, 12)
//                                    .background(Color(hex: "8B9A7E"))
//                                    .cornerRadius(12)
//                            } else {
//                                Text("Done!")
//                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 32)
//                                    .padding(.vertical, 12)
//                                    .background(Color(hex: "8B9A7E"))
//                                    .cornerRadius(12)
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .disabled(isSaving)
//                    }
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 40)
//                }
//                .navigationDestination(isPresented: $navigateToChannels) {
//                    ChannelsView()
//                        .environmentObject(userDataManager)
//                }
//            }
//            .toolbar(.hidden, for: .navigationBar)
//            .sheet(isPresented: $showingImagePicker) {
//                ImagePicker(selectedImage: $selectedImage)
//            }
//    }
//}
//
//// Custom TextField Style for Final Touch
//struct FinalTouchTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding()
//            .frame(minHeight: 120)
//            .background(Color(hex: "8B9A7E")) // Olive green background
//            .cornerRadius(12)
//            .foregroundColor(Color(hex: "5C3D2E"))
//            .font(.system(size: 16, design: .rounded))
//    }
//}
//
//#Preview {
//    FinalTouchView()
//}
//
//


//
//  FinalTouchView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI
import UIKit

struct FinalTouchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var description: String = ""
    @State private var isSaving = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack {
            // Background color (beige to match other screens)
            Color(hex: "F8F5EE")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingCenteredScrollView {
                    VStack(spacing: 16) {
                        OnboardingCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Step 9")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))

                                Text("Last step")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                Text("Add a quick intro or photo so others can get to know you.")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.75))

                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Photo")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

                                    Button(action: {
                                        showingImagePicker = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: "9BA897"))
                                                .frame(width: 120, height: 120)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 3)
                                                )
                                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                                            if let selectedImage = selectedImage {
                                                Image(uiImage: selectedImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 120, height: 120)
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 34, weight: .semibold))
                                            }

                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(hex: "5C3D2E"))
                                                            .frame(width: 32, height: 32)
                                                        Image(systemName: "plus")
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 14, weight: .bold))
                                                    }
                                                }
                                            }
                                            .padding(8)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.top, 2)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Short Description")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

                                    TextField("Tell us about yourself", text: $description, axis: .vertical)
                                        .textFieldStyle(OnboardingTextFieldStyle())
                                        .lineLimit(4...10)
                                }
                                .padding(.top, 6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }

                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                    }
                    .buttonStyle(OnboardingSecondaryButtonStyle())
                    .disabled(isSaving)

                    Button(action: {
                        // Save final touch data
                        userDataManager.profile.shortDescription = description.isEmpty ? nil : description

                        // If image is selected, save it
                        // For now, we'll store a placeholder URL
                        // In production, you'd upload to Firebase Storage and get a URL
                        if selectedImage != nil {
                            userDataManager.profile.photoURL = "selected_image_\(UUID().uuidString)"
                            print("🔥 [FinalTouchView] Image selected, will save to profile")
                        }

                        // Save to Firebase and mark as authenticated (questionnaire complete)
                        isSaving = true
                        Task {
                            do {
                                // Set authenticated to true now that questionnaire is complete
                                // This will cause the app root to switch to MainTabView automatically
                                try await userDataManager.saveToFirebase(setAuthenticated: true)
                                await MainActor.run {
                                    isSaving = false
                                    // Don't navigate manually - let the app root handle the transition
                                    // The app will automatically switch to MainTabView when isAuthenticated becomes true
                                }
                            } catch {
                                print("Error saving to Firebase: \(error)")
                                await MainActor.run {
                                    isSaving = false
                                    // Still set authenticated even if save fails, so user can proceed
                                    userDataManager.isAuthenticated = true
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Done")
                            }
                        }
                    }
                    .buttonStyle(OnboardingPrimaryButtonStyle())
                    .disabled(isSaving)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    FinalTouchView()
}
