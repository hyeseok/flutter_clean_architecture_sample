sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class TimeoutFailure extends Failure { const TimeoutFailure(super.message); }
class AuthFailure extends Failure { const AuthFailure(super.message); }
class ForbiddenFailure extends Failure { const ForbiddenFailure(super.message); }
class NotFoundFailure extends Failure { const NotFoundFailure(super.message); }
class ServerFailure extends Failure { final int? status; const ServerFailure(super.message, {this.status}); }
class ValidationFailure extends Failure { const ValidationFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }