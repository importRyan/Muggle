import Foundation

public extension URL {
  init?(email: String, subject: String, body: String) {
    let format: (String) -> String = { $0 }
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = email
    components.queryItems = [
      URLQueryItem(name: "subject", value: format(subject)),
      URLQueryItem(name: "body", value: format(body))
    ]
    guard let url = components.url else { return nil }
    self = url
  }
}
