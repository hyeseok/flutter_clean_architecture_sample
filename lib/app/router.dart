import 'package:go_router/go_router.dart';

import '../features/dogs/routes.dart';

GoRouter buildRouter() => GoRouter(
    initialLocation: DogsRoutes.breeds,
    routes: [
        ...DogsRoutes.routes
    ]
);