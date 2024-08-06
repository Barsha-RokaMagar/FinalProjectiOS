import SwiftUI
import Firebase

struct NeurologistView: View {
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedNeurologist: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var appointment: Appointment?
    @State private var neurologists = [String]()
    @State private var showAppointmentDetails = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .frame(width: 150, height: 100)
                    .padding(.top, 16)
                    .foregroundColor(.blue)
                
                Text("Doctor Selection and Appointment")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading) {
                    Text("Doctor List - Neurologist")
                        .font(.subheadline)
                        .bold()
                        .padding(.bottom, 8)
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(neurologists, id: \.self) { neurologist in
                                RadioButtonView(
                                    text: neurologist,
                                    isSelected: self.selectedNeurologist == neurologist,
                                    action: {
                                        self.selectedNeurologist = neurologist
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
            .onAppear(perform: loadNeurologists)
            .padding()
        }
    }
    
    private func loadNeurologists() {
        let neurologistRef = Database.database().reference().child("users").queryOrdered(byChild: "specialty").queryEqual(toValue: "Neurologist")
        neurologistRef.observe(.value) { snapshot in
            var newNeurologists = [String]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let name = dict["name"] as? String {
                    newNeurologists.append(name)
                }
            }
            self.neurologists = newNeurologists
        }
    }
    
    private func bookAppointment() {
        guard let selectedNeurologist = selectedNeurologist else {
            alertMessage = "Please select a neurologist"
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
            "doctor": selectedNeurologist,
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
                    doctor: selectedNeurologist,
                    patientId: patientId,
                    patientName: patientName
                )
                self.showAppointmentDetails = true
            }
        }
    }
}

struct NeurologistView_Previews: PreviewProvider {
    static var previews: some View {
        NeurologistView()
    }
}
