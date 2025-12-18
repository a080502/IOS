import SwiftUI

struct PinSetupView: View {
    @Binding var isPresented: Bool
    let onPinSet: (String) -> Void
    
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var isConfirmMode = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: PinField?
    
    enum PinField {
        case pin
        case confirmPin
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(isConfirmMode ? "Conferma il tuo PIN" : "Imposta PIN")
                    .font(.title2.bold())
                    .padding(.top)
                
                if !isConfirmMode {
                    SecureField("PIN (minimo 4 cifre)", text: $pin)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .pin)
                        .padding(.horizontal)
                        .onChange(of: pin) { _, newValue in
                            errorMessage = nil
                            // Only allow digits
                            if !newValue.allSatisfy(\.isNumber) {
                                pin = String(newValue.filter(\.isNumber))
                            }
                        }
                } else {
                    SecureField("PIN", text: $pin)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .disabled(true)
                        .padding(.horizontal)
                    
                    SecureField("Conferma PIN", text: $confirmPin)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .confirmPin)
                        .padding(.horizontal)
                        .onChange(of: confirmPin) { _, _ in
                            errorMessage = nil
                        }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 16) {
                    Button("Annulla") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button(isConfirmMode ? "Conferma" : "Continua") {
                        handleContinue()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isConfirmMode ? confirmPin.isEmpty : pin.isEmpty)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                focusedField = .pin
            }
        }
    }
    
    private func handleContinue() {
        if !isConfirmMode {
            // First step: validate PIN
            if pin.count < 4 {
                errorMessage = "Il PIN deve essere di almeno 4 cifre"
                return
            }
            
            // Move to confirmation
            isConfirmMode = true
            focusedField = .confirmPin
            errorMessage = nil
        } else {
            // Second step: confirm PIN
            if confirmPin != pin {
                errorMessage = "I PIN non corrispondono"
                return
            }
            
            // PIN confirmed, save it
            onPinSet(pin)
            isPresented = false
        }
    }
}

