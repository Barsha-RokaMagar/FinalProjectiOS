import SwiftUI

struct AppointmentDetailsView: View {
    var appointment: Appointment?

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Appointment Confirmation")
                .font(.largeTitle)
                .padding(.top)

            if let appointment = appointment {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Patient: \(appointment.patientName)")
                        .font(.title2)
                    Text("Doctor: \(appointment.doctor)") 
                        .font(.title2)
                    Text("Date: \(appointment.date)")
                        .font(.title2)
                    Text("Time: \(appointment.time)")
                        .font(.title2)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal)
            }

            Text("Your appointment has been successfully booked. Thank you.")
                .font(.title2)
                .padding(.top)

            Spacer()

            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Go Back")
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
        }
        .padding()
        .navigationTitle("Appointment Details")
    }
}

struct Appointment: Identifiable {
    var id: String
    var date: String
    var time: String
    var doctor: String
    var patientId: String
    var patientName: String
}

struct AppointmentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetailsView(appointment: Appointment(
            id: " ",
            date: " ",
            time: " ",
            doctor: " ",
            patientId: " ",
            patientName: " "
        ))
    }
}
