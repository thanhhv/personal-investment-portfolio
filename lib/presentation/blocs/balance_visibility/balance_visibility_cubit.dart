import 'package:flutter_bloc/flutter_bloc.dart';

class BalanceVisibilityCubit extends Cubit<bool> {
  BalanceVisibilityCubit() : super(true);

  void toggle() => emit(!state);
}
