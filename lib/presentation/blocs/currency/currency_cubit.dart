import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_lens/core/constants/app_constants.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';

class CurrencyCubit extends Cubit<AppCurrency> {
  CurrencyCubit() : super(AppCurrency.usd);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.currencyKey);
    emit(stored == 'vnd' ? AppCurrency.vnd : AppCurrency.usd);
  }

  Future<void> setCurrency(AppCurrency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currencyKey, currency.name);
    emit(currency);
  }
}
