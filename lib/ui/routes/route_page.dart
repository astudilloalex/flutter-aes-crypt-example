import 'package:aes_screen/ui/pages/home/home_page.dart';
import 'package:aes_screen/ui/routes/route_name.dart';
import 'package:go_router/go_router.dart';

class RoutePage {
  const RoutePage._();

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: RouteName.home,
        name: RouteName.home,
        builder: (context, state) {
          return const HomePage();
        },
      ),
    ],
  );
}
