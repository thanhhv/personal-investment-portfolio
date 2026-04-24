import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wealth_lens/core/theme/app_theme.dart';
import 'package:wealth_lens/l10n/app_localizations.dart';
import 'package:wealth_lens/presentation/blocs/balance_visibility/balance_visibility_cubit.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';
import 'package:wealth_lens/presentation/blocs/locale/locale_cubit.dart';
import 'package:wealth_lens/presentation/blocs/theme/theme_cubit.dart';
import 'package:wealth_lens/presentation/routes/app_router.dart';

class WealthLensApp extends StatelessWidget {
  const WealthLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..load()),
        BlocProvider(create: (_) => LocaleCubit()..load()),
        BlocProvider(create: (_) => CurrencyCubit()..load()),
        BlocProvider(create: (_) => ExchangeRateCubit()..load()),
        BlocProvider(create: (_) => BalanceVisibilityCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'WealthLens',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                locale: locale,
                routerConfig: appRouter,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('vi'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
