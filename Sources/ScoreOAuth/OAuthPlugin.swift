import Score

/// A Score plugin that provides OAuth authentication with popular providers.
///
/// Register this plugin in your application to add OAuth sign-in:
///
/// ```swift
/// @main
/// struct MySite: Application {
///     var plugins: [any ScorePlugin] {
///         [
///             OAuthPlugin(providers: [
///                 .google(clientId: "...", clientSecret: "..."),
///                 .apple(clientId: "...", teamId: "...", keyId: "...", privateKey: "..."),
///                 .github(clientId: "...", clientSecret: "..."),
///             ])
///         ]
///     }
/// }
/// ```
///
/// The plugin registers routes at `/auth/oauth/{provider}/login` and
/// `/auth/oauth/{provider}/callback` for each configured provider.
public struct OAuthPlugin: ScorePlugin {
    public let name = "OAuth"

    private let config: OAuthConfig

    /// Creates an OAuth plugin with provider configurations.
    ///
    /// - Parameters:
    ///   - providers: The OAuth providers to register.
    ///   - callbackBaseURL: A shared base URL for all OAuth callbacks.
    ///     When set, all redirect URIs use this domain instead of the
    ///     request's `Host` header. The originating host is encoded in the
    ///     OAuth state so the callback can redirect back to the right app.
    ///     This allows multiple apps (e.g. Libretto and Stage Dashboard)
    ///     to share a single OAuth app registration.
    public init(providers: [OAuthProvider], callbackBaseURL: String? = nil) {
        self.config = OAuthConfig(providers: providers, callbackBaseURL: callbackBaseURL)
    }

    public var controllers: [any Controller] {
        [OAuthController(config: config)]
    }
}
