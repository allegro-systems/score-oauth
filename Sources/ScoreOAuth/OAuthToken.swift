import Foundation

/// The result of an OAuth token exchange.
public struct OAuthToken: Sendable, Codable {

    /// The access token.
    public let accessToken: String

    /// The token type (typically "Bearer").
    public let tokenType: String

    /// Seconds until the access token expires.
    public let expiresIn: Int?

    /// The refresh token, if issued.
    public let refreshToken: String?

    /// The granted scope.
    public let scope: String?

    /// The OpenID Connect ID token, if issued.
    public let idToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case idToken = "id_token"
    }
}

/// A user profile retrieved from an OAuth provider.
public struct OAuthUser: Sendable {

    /// The provider that authenticated this user.
    public let provider: String

    /// The provider-specific user identifier.
    public let id: String

    /// The user's email address, if available.
    public let email: String?

    /// The user's display name, if available.
    public let name: String?

    /// The user's avatar URL, if available.
    public let avatarURL: String?

    /// The raw JSON response from the user info endpoint.
    public let raw: [String: String]

    public init(
        provider: String,
        id: String,
        email: String? = nil,
        name: String? = nil,
        avatarURL: String? = nil,
        raw: [String: String] = [:]
    ) {
        self.provider = provider
        self.id = id
        self.email = email
        self.name = name
        self.avatarURL = avatarURL
        self.raw = raw
    }
}
