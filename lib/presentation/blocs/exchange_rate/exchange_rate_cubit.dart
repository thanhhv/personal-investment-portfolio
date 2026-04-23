import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_lens/core/constants/app_constants.dart';

class ExchangeRateCubit extends Cubit<double> {
  ExchangeRateCubit() : super(25000);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(AppConstants.exchangeRateKey);
    emit(stored ?? 25000);
  }

  Future<void> setRate(double rate) async {
    if (rate <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.exchangeRateKey, rate);
    emit(rate);
  }
}
