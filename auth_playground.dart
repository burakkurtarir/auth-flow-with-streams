import 'dart:async';

// We use Singleton design pattern
// Because we can have multiple subscribers
// And they all MUST listen the same stream
class MyAuth {
  MyAuth._();
  static MyAuth _instance = MyAuth._();
  factory MyAuth() => _instance;

  StreamController<UserModel?> _controller = StreamController.broadcast();
  Stream<UserModel?> get stream => _controller.stream;

  UserModel? user;

  void login(UserModel? userModel) {
    user = userModel;
    _controller.add(userModel);
  }

  void logout() {
    user = null;
    _controller.add(null);
  }
}

class UserModel {
  String? firstName;
  String? lastName;
  String? email;

  UserModel({
    this.firstName,
    this.lastName,
    this.email,
  });
}

class AuthenticationProvier {
  StreamSubscription<UserModel?>? subscription;
  void listenAuthStream() {
    subscription = MyAuth().stream.listen((user) {
      if (user != null) {
        print("User logged in -> $user");
      } else {
        print("User logged out -> $user");
      }
    });
  }

  void stopListeningAuthStream() {
    subscription?.cancel();
  }
}

class CacheService {
  StreamSubscription<UserModel?>? subscription;
  void listenAuthStream() {
    subscription = MyAuth().stream.listen((user) {
      if (user != null) {
        print("Cached user data -> $user");
      } else {
        print("Removed user data -> $user");
      }
    });
  }

  void stopListeningAuthStream() {
    subscription?.cancel();
  }
}

void main(List<String> args) async {
  final authProvider = AuthenticationProvier();
  final cacheService = CacheService();

  authProvider.listenAuthStream();
  cacheService.listenAuthStream();

  final user = UserModel(
      firstName: "Burak",
      lastName: "Kurtarir",
      email: "burak.kurtarir35@gmail.com");

  MyAuth().login(user);
  MyAuth().logout();
}
