import Foundation

/// Exchanges an authorization code for an access token.
///
/// This type handles the server-side token exchange step of the OAuth flow.
public struct OAuthTokenExchanger: Sendable {

    public init() {}

    /// Exchanges an authorization code for an OAuth token.
    public static func exchange(
        code: String,
        provider: OAuthProvider,
        redirectURI: String
    ) async throws -> OAuthToken {
        let body = [
            "grant_type=authorization_code",
            "code=\(code)",
            "redirect_uri=\(redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? redirectURI)",
            "client_id=\(provider.clientId)",
            "client_secret=\(provider.clientSecret)",
        ].joined(separator: "&")

        guard let tokenURL = URL(string: provider.tokenURL) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = Data(body.utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(OAuthToken.self, from: data)
    }
}
