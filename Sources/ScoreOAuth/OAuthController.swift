import Foundation
import Score

/// A controller that handles OAuth login and callback routes for all
/// configured providers.
///
/// Routes:
/// - `GET /auth/oauth/{provider}/login` — Redirects to the provider's authorization page.
/// - `GET /auth/oauth/{provider}/callback` — Handles the authorization code callback.
struct OAuthController: Controller {
    let config: OAuthConfig

    var base: String { "/auth/oauth" }

    var routes: [Route] {
        [
            Route(method: .get, path: "/:provider/login", handler: handleLogin),
            Route(method: .get, path: "/:provider/callback", handler: handleCallback),
            Route(method: .get, path: "/:provider/complete", handler: handleComplete),
        ]
    }

    private func handleLogin(_ request: RequestContext) async throws -> Response {
        let providerId = request.pathParameters["provider"] ?? ""
        guard let provider = config.providers[providerId] else {
            return Response.text("Unknown provider: \(providerId)", status: .notFound)
        }

        let csrfToken = generateState()
        let host = request.headers["host"] ?? "localhost:8080"
        let scheme = request.headers["x-forwarded-proto"] ?? "http"
        let originURL = "\(scheme)://\(host)"

        // Encode origin in state so the shared callback knows where to redirect
        let state: String
        if config.callbackBaseURL != nil {
            // Shared mode: encode origin|csrf
            state = "\(originURL)|\(csrfToken)"
        } else {
            state = csrfToken
        }

        let baseURL = originURL
        let url = config.loginURL(for: provider, baseURL: baseURL, state: state)

        return Response(
            status: .temporaryRedirect,
            headers: ["location": url],
            body: Data()
        )
    }

    private func handleCallback(_ request: RequestContext) async throws -> Response {
        let providerId = request.pathParameters["provider"] ?? ""
        guard config.providers[providerId] != nil else {
            return Response.text("Unknown provider: \(providerId)", status: .notFound)
        }

        guard let code = request.queryParameters["code"] else {
            let error = request.queryParameters["error"] ?? "missing_code"
            return Response.text("OAuth error: \(error)", status: .badRequest)
        }

        let stateParam = request.queryParameters["state"] ?? ""

        // If using shared callback, redirect the code back to the origin app
        if config.callbackBaseURL != nil, stateParam.contains("|") {
            let parts = stateParam.split(separator: "|", maxSplits: 1)
            if parts.count == 2 {
                let originURL = String(parts[0])
                let csrfToken = String(parts[1])
                let encodedCode = code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? code
                let redirectURL = "\(originURL)/auth/oauth/\(providerId)/complete?code=\(encodedCode)&state=\(csrfToken)"
                return Response(
                    status: .temporaryRedirect,
                    headers: ["location": redirectURL],
                    body: Data()
                )
            }
        }

        // Non-shared mode: return JSON directly
        let json = """
            {"provider":"\(providerId)","code":"\(code)","state":"\(stateParam)"}
            """
        return Response.json(Data(json.utf8))
    }

    /// Handles the redirect back from the shared callback.
    /// This is called on the origin app (e.g. Libretto) with the code.
    private func handleComplete(_ request: RequestContext) async throws -> Response {
        let providerId = request.pathParameters["provider"] ?? ""
        guard let provider = config.providers[providerId] else {
            return Response.text("Unknown provider: \(providerId)", status: .notFound)
        }

        guard let code = request.queryParameters["code"] else {
            return Response.text("Missing authorization code", status: .badRequest)
        }

        // Exchange the code for an access token
        let host = request.headers["host"] ?? "localhost:8080"
        let scheme = request.headers["x-forwarded-proto"] ?? "http"
        let redirectURI = config.callbackURL(for: providerId, baseURL: "\(scheme)://\(host)")

        let token = try await OAuthTokenExchanger.exchange(
            code: code,
            provider: provider,
            redirectURI: redirectURI
        )

        // Fetch user info if the provider has a userInfoURL
        var userInfo: [String: Any] = [
            "provider": providerId,
            "access_token": token.accessToken,
        ]

        if let userInfoURL = provider.userInfoURL {
            let (data, _) = try await fetchUserInfo(url: userInfoURL, accessToken: token.accessToken)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                userInfo["profile"] = json
            }
        }

        // Return the user info as JSON — the app's auth controller handles session creation
        let responseData = try JSONSerialization.data(withJSONObject: userInfo)
        return Response.json(responseData)
    }

    private func generateState() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private func fetchUserInfo(url: String, accessToken: String) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await URLSession.shared.data(for: request)
    }
}
