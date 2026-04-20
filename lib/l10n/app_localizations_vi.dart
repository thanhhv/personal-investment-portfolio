// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'WealthLens';

  @override
  String get dashboard => 'Tổng quan';

  @override
  String get analytics => 'Phân tích';

  @override
  String get settings => 'Cài đặt';

  @override
  String get transactions => 'Giao dịch';

  @override
  String get totalPortfolioValue => 'Tổng giá trị danh mục';

  @override
  String get totalProfitLoss => 'Tổng lợi nhuận / Lỗ';

  @override
  String get totalInvested => 'Tổng đầu tư';

  @override
  String get currentValue => 'Giá trị hiện tại';

  @override
  String get profitLoss => 'Lợi nhuận / Lỗ';

  @override
  String get allTime => 'Tất cả';

  @override
  String get assets => 'Tài sản';

  @override
  String get addAsset => 'Thêm tài sản';

  @override
  String get editAsset => 'Chỉnh sửa tài sản';

  @override
  String get deleteAsset => 'Xóa tài sản';

  @override
  String get assetName => 'Tên tài sản';

  @override
  String get assetCategory => 'Danh mục';

  @override
  String get purchaseDate => 'Ngày mua';

  @override
  String get quantity => 'Số lượng';

  @override
  String get purchasePricePerUnit => 'Giá mua mỗi đơn vị';

  @override
  String get totalInvestedAmount => 'Tổng số tiền đầu tư';

  @override
  String get currentValueAmount => 'Giá trị hiện tại';

  @override
  String get notes => 'Ghi chú';

  @override
  String get tags => 'Thẻ';

  @override
  String get categoryCrypto => 'Tiền mã hóa';

  @override
  String get categoryStock => 'Cổ phiếu';

  @override
  String get categoryFund => 'Chứng chỉ quỹ';

  @override
  String get categoryGold => 'Vàng';

  @override
  String get categoryRealEstate => 'Bất động sản';

  @override
  String get categorySavings => 'Tiết kiệm';

  @override
  String get categoryLending => 'Cho vay';

  @override
  String get categoryOther => 'Khác';

  @override
  String get transactionType => 'Loại';

  @override
  String get transactionBuy => 'Mua';

  @override
  String get transactionSell => 'Bán';

  @override
  String get transactionUpdate => 'Cập nhật';

  @override
  String get transactionAmount => 'Số tiền';

  @override
  String get transactionDate => 'Ngày';

  @override
  String get transactionNote => 'Ghi chú';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get exportPortfolio => 'Xuất danh mục';

  @override
  String get importPortfolio => 'Nhập danh mục';

  @override
  String get exportSuccess => 'Xuất danh mục thành công';

  @override
  String get importSuccess => 'Nhập danh mục thành công';

  @override
  String get importMerge => 'Gộp với dữ liệu hiện có';

  @override
  String get importReplace => 'Thay thế tất cả';

  @override
  String get importConfirmTitle => 'Nhập danh mục';

  @override
  String importConfirmMessage(int count, String action) {
    return '$count tài sản sẽ được $action.';
  }

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get currency => 'Tiền tệ';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get about => 'Thông tin';

  @override
  String get version => 'Phiên bản';

  @override
  String confirmDelete(String name) {
    return 'Xóa $name?';
  }

  @override
  String get confirmDeleteMessage => 'Hành động này không thể hoàn tác.';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get save => 'Lưu';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get done => 'Xong';

  @override
  String get validationRequired => 'Trường này là bắt buộc';

  @override
  String get validationPositiveNumber => 'Phải là số dương';

  @override
  String get noAssetsYet => 'Chưa có tài sản';

  @override
  String get noAssetsMessage => 'Nhấn + để thêm khoản đầu tư đầu tiên';

  @override
  String get noTransactionsYet => 'Chưa có giao dịch';

  @override
  String get bestPerforming => 'Hiệu suất tốt nhất';

  @override
  String get worstPerforming => 'Hiệu suất kém nhất';

  @override
  String get categoryBreakdown => 'Phân tích danh mục';

  @override
  String get monthlySnapshot => 'Tổng quan hàng tháng';

  @override
  String get allocationByCategory => 'Phân bổ theo danh mục';

  @override
  String get profitLossByCategory => 'Lợi nhuận / Lỗ theo danh mục';
}
