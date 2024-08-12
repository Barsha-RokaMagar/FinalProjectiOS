import SwiftUI
import Firebase

struct DoctorView: View {
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var existingAvailability: String = "No availability set"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var appointments: [Appointment] = []
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingLoginView = false

    var body: some View {
        NavigationView {
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
                    
                    Text("Appointments")
                        .font(.headline)
                        .padding(.top, 16)
                    
                    List(appointments) { appointment in
                        VStack(alignment: .leading) {
                            Text("Date: \(appointment.date)")
                            Text("Time: \(appointment.time)")
                            Text("Patient: \(appointment.patientName)")
                        }
                        .padding()
                    }
                    
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
            .background(
                NavigationLink(destination: LoginView(isLoggedIn: .constant(false)), isActive: $isShowingLoginView) {
                    EmptyView()
                }
            )
            .onAppear(perform: loadAppointments)
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
        
        // Save availability to Firebase
        guard let doctorId = Auth.auth().currentUser?.uid else {
            alertMessage = "No user logged in."
            showAlert = true
            return
        }
        
        let availabilityRef = Database.database().reference().child("doctors").child(doctorId).child("availability")
        
        let availabilityData: [String: Any] = [
            "date": date,
            "start": start,
            "end": end
        ]
        
        availabilityRef.setValue(availabilityData) { error, _ in
            if let error = error {
                self.alertMessage = "Failed to save availability: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.alertMessage = "Availability saved successfully."
                self.showAlert = true
            }
        }
    }
    
    private func clearInputs() {
        selectedDate = Date()
        startTime = Date()
        endTime = Date()
        existingAvailability = "No availability set"
    }
    
    private func loadAppointments() {
        guard let doctorId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        let appointmentsRef = Database.database().reference().child("appointments").queryOrdered(byChild: "doctorId").queryEqual(toValue: doctorId)
        
        appointmentsRef.observe(.value) { snapshot in
            var loadedAppointments = [Appointment]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let date = dict["date"] as? String,
                   let time = dict["time"] as? String,
                   let patientId = dict["patientId"] as? String,
                   let patientName = dict["patientName"] as? String {
                    let appointment = Appointment(
                        id: snapshot.key,
                        date: date,
                        time: time,
                        doctor: "", // Doctor field not used here but can be updated if needed
                        patientId: patientId,
                        patientName: patientName
                    )
                    loadedAppointments.append(appointment)
                }
            }
            self.appointments = loadedAppointments
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            print("Sign out successful")
            isShowingLoginView = true
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
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
