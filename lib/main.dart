import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:granio_flutter/core/config/env/env.dart';
import 'package:granio_flutter/core/di/application_binding.dart';
import 'package:granio_flutter/core/helpers/set_screen_mode.dart';
import 'package:granio_flutter/core/routes/app_router.dart';
import 'package:granio_flutter/core/ui/styles/theme/custom_theme_switcher.dart';
import 'package:granio_flutter/core/ui/widgets/feature_discovery/src/foundation/feature_discovery.dart';
import 'package:granio_flutter/core/ui/widgets/feature_discovery/src/foundation/persistence_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.i.load();
  // Tema salvo pelo usuário (Perfil → Tema escuro). Se o storage seguro não
  // responder (ex.: Linux sem keyring), segue no tema claro padrão.
  await CustomThemeSwitcher.initializeTheme()
      .timeout(const Duration(seconds: 2), onTimeout: () {});

  runApp(const ApplicationBinding(child: GranioApp()));
}

class GranioApp extends StatefulWidget {
  const GranioApp({super.key});

  @override
  State<GranioApp> createState() => _GranioAppState();
}

class _GranioAppState extends State<GranioApp> {
  // Criado uma vez: recriar o GoRouter num rebuild perderia a pilha de rotas.
  late final GoRouter _router = buildAppRouter(context.read());

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SetScreenMode.fullScreen();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => FeatureDiscovery.withProvider(
        persistenceProvider: const SharedPreferencesProvider(),
        child: ValueListenableBuilder<ThemeData>(
          valueListenable: CustomThemeSwitcher.themeNotifier,
          builder: (_, theme, __) => ThemeProvider(
            initTheme: CustomThemeSwitcher.themeType,
            child: MaterialApp.router(
              title: 'Granio',
              theme: theme,
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}
