/// An OAuth provider configuration.
///
/// Each provider specifies its authorization and token endpoints,
/// client credentials, and requested scopes.
public struct OAuthProvider: Sendable {

    /// The provider identifier (e.g. "google", "github", "apple").
    public let id: String

    /// Human-readable display name.
    public let displayName: String

    /// The OAuth authorization endpoint URL.
    public let authorizeURL: String

    /// The OAuth token exchange endpoint URL.
    public let tokenURL: String

    /// The user info endpoint URL (for fetching profile after token exchange).
    public let userInfoURL: String?

    /// The OAuth client ID.
    public let clientId: String

    /// The OAuth client secret.
    public let clientSecret: String

    /// The requested OAuth scopes.
    public let scopes: [String]

    /// Additional provider-specific parameters.
    public let extraParameters: [String: String]

    public init(
        id: String,
        displayName: String,
        authorizeURL: String,
        tokenURL: String,
        userInfoURL: String? = nil,
        clientId: String,
        clientSecret: String,
        scopes: [String] = [],
        extraParameters: [String: String] = [:]
    ) {
        self.id = id
        self.displayName = displayName
        self.authorizeURL = authorizeURL
        self.tokenURL = tokenURL
        self.userInfoURL = userInfoURL
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.scopes = scopes
        self.extraParameters = extraParameters
    }
}

// MARK: - Built-in Providers

extension OAuthProvider {

    /// Google OAuth 2.0 provider.
    public static func google(
        clientId: String,
        clientSecret: String,
        scopes: [String] = ["openid", "email", "profile"]
    ) -> OAuthProvider {
        OAuthProvider(
            id: "google",
            displayName: "Google",
            authorizeURL: "https://accounts.google.com/o/oauth2/v2/auth",
            tokenURL: "https://oauth2.googleapis.com/token",
            userInfoURL: "https://openidconnect.googleapis.com/v1/userinfo",
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        )
    }

    /// Sign in with Apple OAuth provider.
    public static func apple(
        clientId: String,
        teamId: String,
        keyId: String,
        privateKey: String,
        scopes: [String] = ["name", "email"]
    ) -> OAuthProvider {
        OAuthProvider(
            id: "apple",
            displayName: "Apple",
            authorizeURL: "https://appleid.apple.com/auth/authorize",
            tokenURL: "https://appleid.apple.com/auth/token",
            clientId: clientId,
            clientSecret: privateKey,
            scopes: scopes,
            extraParameters: [
                "response_mode": "form_post",
                "team_id": teamId,
                "key_id": keyId,
            ]
        )
    }

    /// GitHub OAuth provider.
    public static func github(
        clientId: String,
        clientSecret: String,
        scopes: [String] = ["read:user", "user:email"]
    ) -> OAuthProvider {
        OAuthProvider(
            id: "github",
            displayName: "GitHub",
            authorizeURL: "https://github.com/login/oauth/authorize",
            tokenURL: "https://github.com/login/oauth/access_token",
            userInfoURL: "https://api.github.com/user",
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        )
    }

    /// Discord OAuth provider.
    public static func discord(
        clientId: String,
        clientSecret: String,
        scopes: [String] = ["identify", "email"]
    ) -> OAuthProvider {
        OAuthProvider(
            id: "discord",
            displayName: "Discord",
            authorizeURL: "https://discord.com/api/oauth2/authorize",
            tokenURL: "https://discord.com/api/oauth2/token",
            userInfoURL: "https://discord.com/api/users/@me",
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        )
    }

    /// Microsoft (Entra ID) OAuth provider.
    public static func microsoft(
        clientId: String,
        clientSecret: String,
        tenant: String = "common",
        scopes: [String] = ["openid", "email", "profile"]
    ) -> OAuthProvider {
        OAuthProvider(
            id: "microsoft",
            displayName: "Microsoft",
            authorizeURL: "https://login.microsoftonline.com/\(tenant)/oauth2/v2.0/authorize",
            tokenURL: "https://login.microsoftonline.com/\(tenant)/oauth2/v2.0/token",
            userInfoURL: "https://graph.microsoft.com/oidc/userinfo",
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: scopes
        )
    }
}
