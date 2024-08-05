import SwiftUI

struct PatientView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Users")
                    .font(.largeTitle)
                    .padding()
                
                Text("\"Remember to take care of yourself along the way\"")
                    .italic()
                    .padding(.bottom, 20)
                
                Image(.patients)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150 ,height: 150)
                    .padding(.bottom, 20)
                
                Text("Select the specialist of your choice and proceed to schedule an appointment.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                VStack {
                    HStack {
                        NavigationLink(destination: CardiologistView()) {
                            SpecialistButton(icon: "heart.fill", title: "Cardiologist")
                        }
                        SpecialistButton(icon: "bandage.fill", title: "Dentist")
                        SpecialistButton(icon: "person.2.fill", title: "Psychologist")
                    }
                    HStack {
                        SpecialistButton(icon: "pills.fill", title: "Dermatologist")
                        SpecialistButton(icon: "person.fill", title: "Pediatrician")
                        SpecialistButton(icon: "eye.fill", title: "Ophthalmologist")
                    }
                    HStack {
                        SpecialistButton(icon: "brain.head.profile", title: "Neurologist")
                        SpecialistButton(icon: "staroflife.fill", title: "Gynecologist")
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                   
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            
        }
    }
}

struct SpecialistButton: View {
    var icon: String
    var title: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}



struct PatientView_Previews: PreviewProvider {
    static var previews: some View {
        PatientView()
    }
}
