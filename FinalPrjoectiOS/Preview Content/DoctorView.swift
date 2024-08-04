//
//  DoctorView.swift
//  FinalPrjoectiOS
//
//  Created by ART on 2024-06-26.
//

import SwiftUI
import Firebase

struct DoctorView: View {
    @State private var dateInput: Date = Date()
    @State private var startTimeInput: Date = Date()
    @State private var endTimeInput: Date = Date()
    @State private var availabilityText: String = ""
    @State private var appointments: [Appointment] = []
    
    var body: some View {
        VStack(spacing: 16) {
            Image("doctor")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top, 16)
            
            Text("Healthy Life Clinic")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Welcome! Doctor")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Set your availability")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                DatePicker("Date", selection: $dateInput, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                
                DatePicker("Start Time", selection: $startTimeInput, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())
                
                DatePicker("End Time", selection: $endTimeInput, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())
                
                Button("Save", action: saveAvailability)
                    .buttonStyle(PrimaryButtonStyle())
                
                Button("Clear", action: clearAvailability)
                    .buttonStyle(SecondaryButtonStyle())
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Existing availability")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(availabilityText)
                    .italic()
            }
            .padding()
            
            List(appointments) { appointment in
                HStack {
                    Text(appointment.date)
                    Spacer()
                    Text(appointment.time)
                    Spacer()
                    Text(appointment.patient)
                    Spacer()
                    Button("View") {
                        
                    }
                }
            }
            
            Button("Logout", action: logout)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 16)
        }
        .onAppear(perform: loadInitialData)
    }
    
    private func saveAvailability() {
        
    }
    
    private func clearAvailability() {
        dateInput = Date()
        startTimeInput = Date()
        endTimeInput = Date()
    }
    
    private func logout() {
        
    }
    
    private func loadInitialData() {
    }
}

struct Appointment: Identifiable {
    var id = UUID()
    var date: String
    var time: String
    var patient: String
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

#Preview {
    DoctorView()
}
