import SwiftUI
import Firebase

struct DoctorView: View {
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var existingAvailability: String = "No availability set"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToLogin: Bool = false
    
    var body: some View {
        VStack {
            Image("doctor")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding(.top, 16)
            
            Text("Healthy Life Clinic")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 8)
            
            Text("Welcome! Doctor")
                .font(.title2)
                .padding(.top, 4)
            
            VStack(alignment: .leading) {
                Text("Set your availability")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                HStack {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                }
                
                HStack {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                }
                .padding(.top, 8)
                
                HStack {
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                }
                .padding(.top, 8)
                
                Button(action: saveAvailability) {
                    Text("Save")
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.top, 8)
                }
                
                Button(action: clearInputs) {
                    Text("Clear")
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.top, 4)
                }
                
                Text("Existing availability")
                    .font(.subheadline)
                    .padding(.top, 8)
                
                Text(existingAvailability)
                    .italic()
                    .padding(.top, 4)
            }
            .padding(16)
            
            Button(action: logout) {
                Text("Logout")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView(isLoggedIn: .constant(false))
        }
    }
    
    private func saveAvailability() {
       
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let date = formatter.string(from: selectedDate)
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        
        existingAvailability = "Date: \(date), Start: \(start), End: \(end)"
        
        alertMessage = "Availability saved successfully."
        showAlert = true
    }
    
    private func clearInputs() {
        selectedDate = Date()
        startTime = Date()
        endTime = Date()
        existingAvailability = "No availability set"
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            navigateToLogin = true
        } catch let signOutError as NSError {
            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            showAlert = true
        }
    }
}

struct DoctorView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorView()
    }
}
