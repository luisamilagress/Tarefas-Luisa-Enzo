import Foundation

enum DuoConfig {
    static let baseURL = URL(string: "https://wjtgijnkksxgvsyohypk.supabase.co/functions/v1/tarefas-luisa-enzo")!
    static let siteURL = URL(string: "https://luisamilagress.github.io/Tarefas-Luisa-Enzo/")!
    static let appGroup = "group.com.duotask.shared"
}

struct LoginResponse: Codable {
    let token: String
    let user: String
}

struct DuoTask: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let assignee: String
    let due_date: String?
    let priority: String
    let status: String
    let created_by: String?
    let created_at: String?
    let client: String?
}

enum DuoAPI {
    static func login(user: String, password: String) async throws -> LoginResponse {
        var request = URLRequest(url: DuoConfig.baseURL.appending(path: "login"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["user": user, "password": password])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.userAuthenticationRequired)
        }
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    static func fetchTasks(token: String) async throws -> [DuoTask] {
        var request = URLRequest(url: DuoConfig.baseURL.appending(path: "tasks"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.userAuthenticationRequired)
        }
        return try JSONDecoder().decode([DuoTask].self, from: data)
    }
}

enum SharedSession {
    static var defaults: UserDefaults? { UserDefaults(suiteName: DuoConfig.appGroup) }

    static var token: String? {
        get { defaults?.string(forKey: "token") }
        set { defaults?.set(newValue, forKey: "token") }
    }
    static var user: String? {
        get { defaults?.string(forKey: "user") }
        set { defaults?.set(newValue, forKey: "user") }
    }
}
