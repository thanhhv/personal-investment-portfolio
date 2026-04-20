// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:wealth_lens/data/datasources/hive_datasource.dart' as _i1054;
import 'package:wealth_lens/data/repositories/asset_repository_impl.dart'
    as _i415;
import 'package:wealth_lens/domain/repositories/asset_repository.dart' as _i629;
import 'package:wealth_lens/domain/usecases/add_transaction_usecase.dart'
    as _i376;
import 'package:wealth_lens/domain/usecases/delete_asset_usecase.dart' as _i158;
import 'package:wealth_lens/domain/usecases/delete_transaction_usecase.dart'
    as _i72;
import 'package:wealth_lens/domain/usecases/get_all_assets_usecase.dart'
    as _i485;
import 'package:wealth_lens/domain/usecases/get_asset_by_id_usecase.dart'
    as _i191;
import 'package:wealth_lens/domain/usecases/save_asset_usecase.dart' as _i926;
import 'package:wealth_lens/presentation/blocs/analytics/analytics_cubit.dart'
    as _i750;
import 'package:wealth_lens/presentation/blocs/asset_detail/asset_detail_cubit.dart'
    as _i450;
import 'package:wealth_lens/presentation/blocs/asset_form/asset_form_cubit.dart'
    as _i16;
import 'package:wealth_lens/presentation/blocs/dashboard/dashboard_cubit.dart'
    as _i206;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i629.AssetRepository>(
        () => _i415.AssetRepositoryImpl(gh<_i1054.HiveDatasource>()));
    gh.factory<_i926.SaveAssetUseCase>(
        () => _i926.SaveAssetUseCase(gh<_i629.AssetRepository>()));
    gh.factory<_i158.DeleteAssetUseCase>(
        () => _i158.DeleteAssetUseCase(gh<_i629.AssetRepository>()));
    gh.factory<_i191.GetAssetByIdUseCase>(
        () => _i191.GetAssetByIdUseCase(gh<_i629.AssetRepository>()));
    gh.factory<_i485.GetAllAssetsUseCase>(
        () => _i485.GetAllAssetsUseCase(gh<_i629.AssetRepository>()));
    gh.factory<_i376.AddTransactionUseCase>(
        () => _i376.AddTransactionUseCase(gh<_i629.AssetRepository>()));
    gh.factory<_i72.DeleteTransactionUseCase>(
        () => _i72.DeleteTransactionUseCase(gh<_i629.AssetRepository>()));
    gh.factory<_i16.AssetFormCubit>(
        () => _i16.AssetFormCubit(gh<_i926.SaveAssetUseCase>()));
    gh.factory<_i450.AssetDetailCubit>(() => _i450.AssetDetailCubit(
          gh<_i191.GetAssetByIdUseCase>(),
          gh<_i158.DeleteAssetUseCase>(),
          gh<_i72.DeleteTransactionUseCase>(),
        ));
    gh.factory<_i206.DashboardCubit>(
        () => _i206.DashboardCubit(gh<_i485.GetAllAssetsUseCase>()));
    gh.factory<_i750.AnalyticsCubit>(
        () => _i750.AnalyticsCubit(gh<_i485.GetAllAssetsUseCase>()));
    return this;
  }
}
