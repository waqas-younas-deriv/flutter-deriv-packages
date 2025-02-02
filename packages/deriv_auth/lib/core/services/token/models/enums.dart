/// The selected parameter that should be highlighted when opening the Social login or signup
enum SocialAuthType {
  /// Login social type.
  login,

  /// Signup social type.
  signup
}

/// Auth type.
enum AuthType {
  /// Login using email and password.
  system,

  /// Login with social accounts with one-all service.
  social,

  /// Login with social accounts with in-house service.
  socialLogin,
}

/// Social auth provider.
enum SocialAuthProvider {
  /// Google.
  google,

  /// Facebook.
  facebook,

  /// Apple.
  apple
}
