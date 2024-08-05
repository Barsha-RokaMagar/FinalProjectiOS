import SwiftUI
import Firebase

struct CardiologistView: View {
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedCardiologist: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var cardiologists = [String]()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Image(systemName:"heart.fill")
                .resizable()
                .frame(width: 150, height: 100)
                .padding(.top, 16)
                .foregroundColor(.red)
            
            Text("Doctor Selection and Appointment")
                .font(.headline)
                .padding(.top, 8)
            
            VStack(alignment: .leading) {
                Text("Doctor List - Cardiologist")
                    .font(.subheadline)
                    .bold()
                    .padding(.bottom, 8)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(cardiologists, id: \.self) { cardiologist in
                            RadioButton(text: cardiologist, isSelected: self.selectedCardiologist == cardiologist) {
                                self.selectedCardiologist = cardiologist
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
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
            
            Button(action: goBack) {
                Text("Go Back")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .onAppear(perform: loadCardiologists)
        .padding()
    }
    
    private func loadCardiologists() {
        let cardiologistRef = Database.database().reference().child("cardiologists")
        cardiologistRef.observe(.value) { snapshot in
            var newCardiologists = [String]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let name = dict["name"] as? String {
                    newCardiologists.append(name)
                }
            }
            self.cardiologists = newCardiologists
        }
    }
    
    private func bookAppointment() {
        guard let selectedCardiologist = selectedCardiologist else {
            alertMessage = "Please select a cardiologist"
            showAlert = true
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let date = dateFormatter.string(from: selectedDate)
        let time = dateFormatter.string(from: selectedTime)
        
        let patientId = Auth.auth().currentUser?.uid ?? ""
        let appointmentRef = Database.database().reference().child("appointments").childByAutoId()
        
        let appointmentData: [String: Any] = [
            "date": date,
            "time": time,
            "cardiologist": selectedCardiologist,
            "patientId": patientId
        ]
        
        appointmentRef.setValue(appointmentData) { error, _ in
            if let error = error {
                self.alertMessage = "Failed to book appointment: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.alertMessage = "Appointment booked"
                self.showAlert = true
            }
        }
    }
    
    private func goBack() {
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct RadioButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .onTapGesture {
                    action()
                }
            Text(text)
                .onTapGesture {
                    action()
                }
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(10)
    }
}

struct CardiologistView_Previews: PreviewProvider {
    static var previews: some View {
        CardiologistView()
    }
}
