import Foundation

actor OpenAIService {
    static let shared = OpenAIService()
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

    func summarize(transcript: String) async throws -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            return "[Demo mode] I’d say the team reviewed progress and adjusted medications."
        }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.3,
            "messages": [
                ["role": "system", "content": "You are Rounds AI, a calm and empathetic doctor-brother figure who summarizes hospital rounds in clear, plain English."],
                ["role": "user", "content": transcript]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, _) = try await URLSession.shared.data(for: request)
        struct Choice: Codable { struct Msg: Codable { let content: String }; let message: Msg }
        struct Resp: Codable { let choices: [Choice] }
        let resp = try JSONDecoder().decode(Resp.self, from: data)
        return resp.choices.first?.message.content ?? "[No summary returned.]"
    }
}
