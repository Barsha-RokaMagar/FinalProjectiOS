import SwiftUI
import Firebase

struct DermatologistView: View {
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedDermatologist: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var appointment: Appointment?
    @State private var dermatologists = [String]()
    @State private var showAppointmentDetails = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "smiley.fill")
                    .resizable()
                    .frame(width: 150, height: 100)
                    .padding(.top, 16)
                    .foregroundColor(.orange)
                
                Text("Doctor Selection and Appointment")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading) {
                    Text("Doctor List - Dermatologist")
                        .font(.subheadline)
                        .bold()
                        .padding(.bottom, 8)
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(dermatologists, id: \.self) { dermatologist in
                                RadioButtonView(
                                    text: dermatologist,
                                    isSelected: self.selectedDermatologist == dermatologist,
                                    action: {
                                        self.selectedDermatologist = dermatologist
                                    }
                                )
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                    }
                }
                .padding()
                
                VStack {
                    HStack {
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                    }
                    .padding(.top, 8)
                    
                    HStack {
                        DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                    }
                    .padding(.top, 8)
                }
                .padding()
                
                Button(action: bookAppointment) {
                    Text("Book an Appointment")
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 8)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .padding(.horizontal, 16)
                .background(
                    NavigationLink(
                        destination: AppointmentDetailsView(appointment: appointment),
                        isActive: $showAppointmentDetails,
                        label: { EmptyView() }
                    )
                )
                
                Spacer()
            }
            .onAppear(perform: loadDermatologists)
            .padding()
        }
    }
    
    private func loadDermatologists() {
        let dermatologistRef = Database.database().reference().child("users").queryOrdered(byChild: "specialty").queryEqual(toValue: "Dermatologist")
        dermatologistRef.observe(.value) { snapshot in
            var newDermatologists = [String]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let name = dict["name"] as? String {
                    newDermatologists.append(name)
                }
            }
            self.dermatologists = newDermatologists
        }
    }
    
    private func bookAppointment() {
        guard let selectedDermatologist = selectedDermatologist else {
            alertMessage = "Please select a dermatologist"
            showAlert = true
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        let date = dateFormatter.string(from: selectedDate)
        let time = timeFormatter.string(from: selectedTime)
        
        let patientId = Auth.auth().currentUser?.uid ?? ""
        let patientName = Auth.auth().currentUser?.displayName ?? "Unknown"
        
        let appointmentRef = Database.database().reference().child("appointments").childByAutoId()
        
        let appointmentData: [String: Any] = [
            "date": date,
            "time": time,
            "doctor": selectedDermatologist,
            "patientId": patientId,
            "patientName": patientName
        ]
        
        appointmentRef.setValue(appointmentData) { error, _ in
            if let error = error {
                self.alertMessage = "Failed to book appointment: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.appointment = Appointment(
                    id: appointmentRef.key ?? "",
                    date: date,
                    time: time,
                    doctor: selectedDermatologist,
                    patientId: patientId,
                    patientName: patientName
                )
                self.showAppointmentDetails = true
            }
        }
    }
}

struct DermatologistView_Previews: PreviewProvider {
    static var previews: some View {
        DermatologistView()
    }
}
