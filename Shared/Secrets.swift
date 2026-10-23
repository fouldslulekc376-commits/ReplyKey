import Foundation

// 这个文件会被 GitHub Actions 在构建时覆盖写入真实值。
// 本地留空也能编译，只是调用时会提示「还没配置 API Key」。
enum Secrets {
    static let apiKey = ""
    static let baseURL = "https://api.deepseek.com"
    static let model = "deepseek-chat"
}
