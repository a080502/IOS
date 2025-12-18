import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appSession: AppSession
    @StateObject private var viewModel: LoginViewModel

    @State private var navigateToServerSetup = false
    @State private var showPinEntry = false
    @State private var showPinSetup = false

    init(appSession: AppSession) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appSession: appSession))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Accesso")
                    .font(.largeTitle.bold())

                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Accedi")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                // Quick login options
                if viewModel.hasSavedCredentials {
                    VStack(spacing: 12) {
                        if viewModel.canUseBiometric {
                            Button {
                                viewModel.performBiometricLogin()
                            } label: {
                                Label("Accedi con Face ID", systemImage: "faceid")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if viewModel.canUsePin {
                            Button {
                                showPinEntry = true
                            } label: {
                                Label("Accedi con PIN", systemImage: "lock.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Button {
                            showPinSetup = true
                        } label: {
                            Text("Configura accesso rapido")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                }

                Button("Configura server") {
                    navigateToServerSetup = true
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToServerSetup) {
                ServerSetupView()
            }
            .sheet(isPresented: $showPinEntry) {
                PinEntryView(
                    isPresented: $showPinEntry,
                    onPinEntered: { pin in
                        return viewModel.performPinLogin(pin: pin)
                    },
                    onCancel: {}
                )
            }
            .sheet(isPresented: $showPinSetup) {
                PinSetupView(
                    isPresented: $showPinSetup,
                    onPinSet: { pin in
                        let secureStorage = SecureStorageManager()
                        secureStorage.savePin(pin)
                        secureStorage.setPinEnabled(true)
                        secureStorage.setQuickLoginEnabled(true)
                    }
                )
            }
        }
        .onAppear {
            // Try auto-login with biometric if available
            if viewModel.canUseBiometric {
                viewModel.performBiometricLogin()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(appSession: AppSession())
    }
}


