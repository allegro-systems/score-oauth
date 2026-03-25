import Testing

@testable import ScoreOAuth

@Suite("OAuthProvider")
struct OAuthProviderTests {

    @Test("Google provider has correct endpoints")
    func googleEndpoints() {
        let provider = OAuthProvider.google(clientId: "test-id", clientSecret: "test-secret")
        #expect(provider.id == "google")
        #expect(provider.authorizeURL.contains("accounts.google.com"))
        #expect(provider.tokenURL.contains("googleapis.com"))
        #expect(provider.scopes.contains("openid"))
    }

    @Test("GitHub provider has correct endpoints")
    func githubEndpoints() {
        let provider = OAuthProvider.github(clientId: "test-id", clientSecret: "test-secret")
        #expect(provider.id == "github")
        #expect(provider.authorizeURL.contains("github.com"))
        #expect(provider.scopes.contains("read:user"))
    }

    @Test("Apple provider includes extra parameters")
    func appleExtraParams() {
        let provider = OAuthProvider.apple(
            clientId: "com.test", teamId: "TEAM", keyId: "KEY", privateKey: "pk")
        #expect(provider.id == "apple")
        #expect(provider.extraParameters["response_mode"] == "form_post")
        #expect(provider.extraParameters["team_id"] == "TEAM")
    }

    @Test("Discord provider has correct endpoints")
    func discordEndpoints() {
        let provider = OAuthProvider.discord(clientId: "test-id", clientSecret: "test-secret")
        #expect(provider.id == "discord")
        #expect(provider.authorizeURL.contains("discord.com"))
    }

    @Test("Microsoft provider supports tenant configuration")
    func microsoftTenant() {
        let provider = OAuthProvider.microsoft(
            clientId: "test-id", clientSecret: "test-secret", tenant: "my-tenant")
        #expect(provider.authorizeURL.contains("my-tenant"))
        #expect(provider.tokenURL.contains("my-tenant"))
    }
}

@Suite("OAuthConfig")
struct OAuthConfigTests {

    @Test("Config indexes providers by ID")
    func indexesByID() {
        let config = OAuthConfig(providers: [
            .google(clientId: "g", clientSecret: "gs"),
            .github(clientId: "h", clientSecret: "hs"),
        ])
        #expect(config.providers["google"] != nil)
        #expect(config.providers["github"] != nil)
        #expect(config.providers["apple"] == nil)
    }

    @Test("Callback URL is constructed correctly")
    func callbackURL() {
        let config = OAuthConfig(providers: [])
        let url = config.callbackURL(for: "google", baseURL: "https://example.com")
        #expect(url == "https://example.com/auth/oauth/google/callback")
    }

    @Test("Login URL contains required parameters")
    func loginURL() {
        let provider = OAuthProvider.google(clientId: "test-id", clientSecret: "test-secret")
        let config = OAuthConfig(providers: [provider])
        let url = config.loginURL(for: provider, baseURL: "https://example.com", state: "abc123")
        #expect(url.contains("client_id=test-id"))
        #expect(url.contains("state=abc123"))
        #expect(url.contains("response_type=code"))
    }
}

@Suite("OAuthPlugin")
struct OAuthPluginTests {

    @Test("Plugin registers controllers")
    func registersControllers() {
        let plugin = OAuthPlugin(providers: [
            .google(clientId: "g", clientSecret: "gs")
        ])
        #expect(plugin.name == "OAuth")
        #expect(!plugin.controllers.isEmpty)
    }
}
