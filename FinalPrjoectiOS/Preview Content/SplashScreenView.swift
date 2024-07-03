//
//  SplashScreenView.swift
//  SplashActivity
//
//  Created by Admin on 6/5/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack{
            Text("Welcome to MediAppoint")
                    .font(.title)
                .bold()
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .frame(alignment: .topLeading)
                    .padding()
            Text("Your Health our Priority")
                    .italic()
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .frame(alignment: .topLeading)
                    .padding()
            Image(.doctor)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350,height: 350)
                    .padding()
            Text("Let's Go!! ")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .foregroundColor(.yellow)
                    .padding()
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
        }
    }
