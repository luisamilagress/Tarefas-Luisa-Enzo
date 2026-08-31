import SwiftUI

struct LoginView: View {
    @State private var selectedUser = "Luisa"
    @State private var password = ""
    @State private var loading = false
    @State private var error = ""
    let onLogin: (String) -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 62))
            Text("DUO Task")
                .font(.largeTitle.bold())
            Text("Tarefas de hoje na tela do iPhone")
                .foregroundStyle(.secondary)

            Picker("Usuário", selection: $selectedUser) {
                Text("Luisa").tag("Luisa")
                Text("Enzo").tag("Enzo")
            }
            .pickerStyle(.segmented)

            SecureField("Senha", text: $password)
                .textFieldStyle(.roundedBorder)

            if !error.isEmpty {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Button {
                Task { await login() }
            } label: {
                if loading { ProgressView().tint(.white) }
                else { Text("Entrar").fontWeight(.semibold) }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.black)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(password.isEmpty || loading)

            Spacer()
        }
        .padding(24)
    }

    private func login() async {
        loading = true
        error = ""
        do {
            let result = try await DuoAPI.login(user: selectedUser, password: password)
            SharedSession.token = result.token
            SharedSession.user = result.user
            onLogin(result.user)
        } catch {
            self.error = "Usuário ou senha incorretos."
        }
        loading = false
    }
}
