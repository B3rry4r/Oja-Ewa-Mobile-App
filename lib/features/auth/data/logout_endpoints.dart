/// Candidate user logout endpoints.
///
/// Docs currently do not define a user logout endpoint, but the backend may still
/// expose one depending on Laravel auth setup.
const userLogoutCandidates = <String>[
  '/api/logout',
  '/api/auth/logout',
  '/api/user/logout',
];
