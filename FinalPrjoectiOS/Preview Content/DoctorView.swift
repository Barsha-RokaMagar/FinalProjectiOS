import SwiftUI
import Firebase

struct DoctorView: View {
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var currentAvailability: String = "No availability set"
    @State private var appointments: [Appointment] = []
    @State private var doctorName: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingLoginView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
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

                    Text("Welcome, Dr. \(doctorName)")
                        .font(.title2)
                        .padding(.top, 4)

                    VStack(alignment: .leading) {
                        Text("Set your availability")
                            .font(.headline)
                            .padding(.bottom, 8)

                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))

                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                            .padding(.top, 8)

                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
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

                        Text(currentAvailability)
                            .italic()
                            .padding(.top, 4)

                        Text("Appointments")
                            .font(.headline)
                            .padding(.top, 16)
                        HStack {
                            Text("Date")
                                 .bold()
                                 .frame(maxWidth: .infinity, alignment:
                                        .leading)
                            Text("Time")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Patient")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        
                        LazyVStack {
                            ForEach(appointments) { appointment in
                                AppointmentRow(appointment: appointment)
                            }
                        }
                        .padding(.bottom, 16) 
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
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarBackButtonHidden(true)
            .background(
                NavigationLink(destination: LoginView(isLoggedIn: .constant(false)), isActive: $isShowingLoginView) {
                    EmptyView()
                }
            )
            .onAppear(perform: loadPatientDetails)
        }
    }

    private func loadPatientDetails() {
        guard let doctorId = Auth.auth().currentUser?.uid else {
            alertMessage = "No user logged in."
            showAlert = true
            return
        }
        
        let userRef = Database.database().reference().child("users").child(doctorId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let name = snapshot.childSnapshot(forPath: "name").value as? String {
                self.doctorName = name
                loadAppointments()
            } else {
                alertMessage = "Doctor not found."
                showAlert = true
            }
        } withCancel: { error in
            alertMessage = "Failed to load doctor details: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func loadAppointments() {
        guard let doctorId = Auth.auth().currentUser?.uid else {
            alertMessage = "No user logged in."
            showAlert = true
            return
        }
        
        let appointmentsRef = Database.database().reference().child("appointments")
        appointmentsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let data = snapshot.value as? [String: Any] {
                    
                    let date = data["date"] as? String ?? ""
                    let time = data["time"] as? String ?? ""
                    let endTime = data["endTime"] as? String ?? ""
                    let patientId = data["patientId"] as? String ?? ""
                    let confirmed = data["confirmationMessage"] as? String ?? ""
                    let appointmentId = snapshot.key
                    
                    var isMatch = false
                    let specialties = ["cardiologist", "dentist", "dermatologist", "gynecologist", "neurologist", "ophthalmologist", "pediatrician", "psychologist"]
                    for specialty in specialties {
                        if let doctor = data[specialty] as? String, doctorName == doctor,confirmed.isEmpty {
                            isMatch = true
                            if isMatch {
                                let patientName = data["patientName"] as? String ?? "Unknown"
                                let appointment = Appointment(id: appointmentId, date: date, time: time, doctor: doctorName, patientId: patientId, patientName: patientName)
                                print("Match found for appointment: \(appointment.doctor)")
                                self.appointments.append(appointment)
                                print("self  appointment data: \(self.appointments[0].doctor)")
                                print("self  appointment data: \(self.appointments[0].doctor)")
                            }
                        }
                    }
                } else {
                    print("Failed to parse appointment: \(snapshot)")
                }
            }
            
            DispatchQueue.main.async {
                if self.appointments.isEmpty {
                    self.alertMessage = "No appointments found."
                    self.showAlert = true
                }
            }
        } withCancel: { error in
            self.alertMessage = "Failed to load appointments: \(error.localizedDescription)"
            self.showAlert = true
        }
    }

    private func saveAvailability() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let date = formatter.string(from: selectedDate)
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        
        currentAvailability = "Date: \(date), Start: \(start), End: \(end)"
        
        guard let doctorId = Auth.auth().currentUser?.uid else {
            alertMessage = "No user logged in."
            showAlert = true
            return
        }
        
        let availabilityRef = Database.database().reference().child("availability").child(doctorId).child(date)
        
        let availabilityData: [String: Any] = [
            "startTime": start,
            "endTime": end
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
        currentAvailability = "No availability set"
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            isShowingLoginView = true
        } catch let signOutError as NSError {
            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            showAlert = true
        }
    }
}


struct AppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        HStack {
            Text("Date: \(appointment.date)")
                .padding(.trailing, 8)
            Text("Time: \(appointment.time)")
                .padding(.trailing, 8)

            NavigationLink(destination: PatientDetailsView(
                patientId: appointment.patientId,
                appointmentId: appointment.id
            )) {
                Text("Patient: \(appointment.patientName)")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}



struct DoctorView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorView()
    }
}
