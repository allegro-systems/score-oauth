/// Internal configuration holding all registered OAuth providers.
struct OAuthConfig: Sendable {

    /// The registered providers keyed by their identifier.
    let providers: [String: OAuthProvider]

    /// When set, all redirect URIs use this base URL instead of the
    /// request's `Host` header. The originating host is encoded in the
    /// OAuth state for redirect-back after callback.
    let callbackBaseURL: String?

    /// The base URL for callback routes.
    var callbackBasePath: String { "/auth/oauth" }

    init(providers: [OAuthProvider], callbackBaseURL: String? = nil) {
        var map: [String: OAuthProvider] = [:]
        for provider in providers {
            map[provider.id] = provider
        }
        self.providers = map
        self.callbackBaseURL = callbackBaseURL
    }

    /// Returns the callback URL for a provider given a base URL.
    func callbackURL(for providerId: String, baseURL: String) -> String {
        let base = callbackBaseURL ?? baseURL
        return "\(base)\(callbackBasePath)/\(providerId)/callback"
    }

    /// Returns the login URL for a provider given a base URL and state token.
    func loginURL(for provider: OAuthProvider, baseURL: String, state: String) -> String {
        let redirect = callbackURL(for: provider.id, baseURL: baseURL)
        var params = [
            "client_id=\(provider.clientId)",
            "redirect_uri=\(redirect.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? redirect)",
            "response_type=code",
            "state=\(state)",
        ]
        if !provider.scopes.isEmpty {
            let scopeValue = provider.scopes.joined(separator: " ")
            params.append(
                "scope=\(scopeValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? scopeValue)"
            )
        }
        for (key, value) in provider.extraParameters {
            params.append(
                "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)")
        }
        return "\(provider.authorizeURL)?\(params.joined(separator: "&"))"
    }
}
