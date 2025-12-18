import SwiftUI

struct PinEntryView: View {
    @Binding var isPresented: Bool
    let onPinEntered: (String) -> Bool  // Returns true if PIN is correct
    let onCancel: () -> Void
    
    @State private var pin: String = ""
    @State private var errorMessage: String?
    @FocusState private var isPinFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Inserisci PIN")
                    .font(.title2.bold())
                    .padding(.top)
                
                SecureField("PIN", text: $pin)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .focused($isPinFocused)
                    .padding(.horizontal)
                    .onChange(of: pin) { _, _ in
                        errorMessage = nil
                    }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 16) {
                    Button("Annulla") {
                        onCancel()
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Sblocca") {
                        if pin.isEmpty {
                            errorMessage = "Inserisci il PIN"
                        } else {
                            if onPinEntered(pin) {
                                isPresented = false
                            } else {
                                errorMessage = "PIN errato"
                                pin = ""
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(pin.isEmpty)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isPinFocused = true
            }
        }
    }
}

