// login exceptions
class EmailorpasswordincorrectAuthException implements Exception {}

// register exceptions

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class TooManyRequestsAuthException implements Exception {}

//generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class UsernotVerified implements Exception {}
