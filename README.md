# Authentication Flow with Dart Streams

Sometimes we need to call some functions after we called login or logout. For instance we can clear the cache or make some changes in Provider class.
If we use Streams, other classes(CacheService, AuthenticationProvider, etc) can listen the Authentication Stream and react to it.

![Authentication Flow with Streams](/auth_stream.png)

## Code Review

**MyAuth** class is our core class. When we can call **login** or **logout** functions, it will add a new data event to the stream and listeners will receive it.
**AuthenticationProvier** and **CacheService** listen the stream.

**MyAuth** class has a StreamController and login,logout functions. We use Singleton design pattern because we can have multiple subscribers and they all MUST listen the same stream.
```
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
```

**AuthenticationProvider** subscribes to the stream. Don't forget to cancel subscription when you are done.
```
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
```

**CacheService** subscribes to the stream. Don't forget to cancel subscription when you are done.
```
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
```

First we created **AuthenticationProvier** and **CacheService** instances then started to listen the stream. Now whenever we call **login** or **logout** functions, our subscribers will do their jobs :D
```
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
```

The result will be
```
User logged in -> Instance of 'UserModel'
Cached user data -> Instance of 'UserModel'
User logged out -> null
Removed user data -> null
```