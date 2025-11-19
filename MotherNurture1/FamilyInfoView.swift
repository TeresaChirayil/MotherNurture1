//
//  FamilyInfoView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct FamilyInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var numberOfChildren: Int = 1
    @State private var childAges: [Int] = [1]
    @State private var navigateToAboutYou = false
    
    var body: some View {
        ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    ScrollView {
                        // Main Content
                        VStack(alignment: .leading, spacing: 30) {
                            // Question
                            Text("Tell us about your family: How many children do you have, and how old are they?")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                            
                            // Number of Children
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Number of Children:")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                HStack {
                                    Button(action: {
                                        if numberOfChildren > 1 {
                                            numberOfChildren -= 1
                                            // Remove the last child's age from the array
                                            if childAges.count >= numberOfChildren {
                                                childAges = Array(childAges.prefix(numberOfChildren))
                                            }
                                        }
                                    }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .frame(width: 44, height: 44)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Spacer()
                                    
                                    Text("\(numberOfChildren)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        numberOfChildren += 1
                                        // Add a new child age if needed
                                        if childAges.count < numberOfChildren {
                                            childAges.append(1)
                                        }
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .frame(width: 44, height: 44)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding()
                                .background(Color(hex: "8B6F47"))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                            
                            // Their Ages
                            if numberOfChildren > 0 {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Their ages:")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                    
                                    ForEach(0..<numberOfChildren, id: \.self) { index in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Child \(index + 1)")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                            
                                            HStack {
                                                Text("0")
                                                    .font(.system(size: 14, design: .rounded))
                                                    .foregroundColor(Color(hex: "5C3D2E"))
                                                
                                                Slider(value: Binding(
                                                    get: { 
                                                        let age = index < childAges.count ? childAges[index] : 1
                                                        return Double(age)
                                                    },
                                                    set: { 
                                                        while childAges.count <= index {
                                                            childAges.append(1)
                                                        }
                                                        childAges[index] = Int($0)
                                                    }
                                                ), in: 0...18, step: 1)
                                                .accentColor(Color(hex: "8B9A7E"))
                                                
                                                Text("18")
                                                    .font(.system(size: 14, design: .rounded))
                                                    .foregroundColor(Color(hex: "5C3D2E"))
                                                
                                                Text("\(index < childAges.count ? childAges[index] : 1)")
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                    .foregroundColor(Color(hex: "5C3D2E"))
                                                    .frame(width: 30)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                    }
                    
                    // Bottom Navigation
                    HStack {
                        // Previous Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("Previous")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Next Button
                        Button(action: {
                            // Save family info
                            userDataManager.profile.numberOfChildren = numberOfChildren
                            userDataManager.profile.childAges = childAges
                            
                            navigateToAboutYou = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Next")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                        .navigationDestination(isPresented: $navigateToAboutYou) {
                            AboutYouView()
                                .environmentObject(userDataManager)
                        }
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}


#Preview {
    FamilyInfoView()
}

