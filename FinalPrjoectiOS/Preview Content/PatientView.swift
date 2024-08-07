import SwiftUI

struct PatientView: View {
    var body: some View {
        VStack {
            Text("Welcome Users")
                .font(.largeTitle)
                .padding()
            
            Text("\"Remember to take care of yourself along the way\"")
                .italic()
                .padding(.bottom, 20)
            
            Image(systemName: "person.circle.fill") // You can replace this with your actual image
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
            
            Text("Select the specialist of your choice and proceed to schedule an appointment.")
                .padding()
                .multilineTextAlignment(.center)
            
        }

    }
     
      
}
        
