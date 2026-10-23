import Foundation

enum ReplyError: LocalizedError {
    case missingKey
    case badURL
    case http(Int, String)
    case empty
    case network(String)

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "还没配置 API Key"
        case .badURL:
            return "接口地址不对"
        case .http(let code, let body):
            let brief = body.prefix(80)
            return "接口返回 \(code)：\(brief)"
        case .empty:
            return "没生成出东西，再试一次"
        case .network(let msg):
            return msg
        }
    }
}

struct ReplyEngine {
    /// 把对方那条消息丢给模型，拿回 1~3 条候选回复。
    static func generate(for message: String) async throws -> [String] {
        let key = AppConfig.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { throw ReplyError.missingKey }

        let trimmedBase = AppConfig.apiBaseURL
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: trimmedBase + "/chat/completions") else {
            throw ReplyError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + key, forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "model": AppConfig.model,
            "temperature": 0.85,
            "max_tokens": 300,
            "messages": [
                ["role": "system", "content": AppConfig.systemPrompt],
                ["role": "user", "content": message]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])

        let data: Data
        let response: URLResponse
        do {
            let pair = try await URLSession.shared.data(for: request)
            data = pair.0
            response = pair.1
        } catch {
            throw ReplyError.network("连不上，检查网络或完全访问")
        }

        guard let http = response as? HTTPURLResponse else { throw ReplyError.empty }
        guard (200..<300).contains(http.statusCode) else {
            throw ReplyError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        return parse(data)
    }

    private static func parse(_ data: Data) -> [String] {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let root = object as? [String: Any],
            let choices = root["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { return [] }

        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 首选：模型老老实实给了 JSON 数组
        if let raw = cleaned.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: raw),
           let array = parsed as? [String] {
            let cleanedArray = array
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !cleanedArray.isEmpty { return Array(cleanedArray.prefix(3)) }
        }

        // 兜底：按行切，去掉 "1." "-" 这类前缀
        let lines = cleaned
            .components(separatedBy: .newlines)
            .map { line -> String in
                var s = line
                s = s.replacingOccurrences(of: #"^\s*[-*]\s*"#, with: "", options: .regularExpression)
                s = s.replacingOccurrences(of: #"^\s*\d+\s*[.、)]\s*"#, with: "", options: .regularExpression)
                return s.trimmingCharacters(in: CharacterSet(charactersIn: " \t\"',[]，。"))
            }
            .filter { !$0.isEmpty }

        return Array(lines.prefix(3))
    }
}
