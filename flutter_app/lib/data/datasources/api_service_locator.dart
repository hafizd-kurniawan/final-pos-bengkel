import '../../core/network/network_service.dart';
import 'auth_remote_datasource.dart';
import 'vehicle_remote_datasource.dart';
import 'sale_api_service.dart';
import 'test_drive_api_service.dart';
import 'lead_api_service.dart';
import 'transaction_api_service.dart';
import 'dashboard_api_service.dart';
import 'user_api_service.dart';

class ApiServiceLocator {
  static final ApiServiceLocator _instance = ApiServiceLocator._internal();
  factory ApiServiceLocator() => _instance;
  ApiServiceLocator._internal();

  late final NetworkService _networkService;
  
  // API Services
  late final AuthRemoteDataSource authService;
  late final VehicleRemoteDataSource vehicleService;
  late final SaleApiService saleService;
  late final TestDriveApiService testDriveService;
  late final LeadApiService leadService;
  late final TransactionApiService transactionService;
  late final DashboardApiService dashboardService;
  late final UserApiService userService;

  void initialize() {
    _networkService = NetworkService();
    _networkService.initialize();

    // Initialize all API services
    authService = AuthRemoteDataSourceImpl(networkService: _networkService);
    vehicleService = VehicleRemoteDataSource(_networkService);
    saleService = SaleApiService(_networkService);
    testDriveService = TestDriveApiService(_networkService);
    leadService = LeadApiService(_networkService);
    transactionService = TransactionApiService(_networkService);
    dashboardService = DashboardApiService(_networkService);
    userService = UserApiService(_networkService);
  }

  void setAuthToken(String? token) {
    _networkService.setAuthToken(token);
  }

  void clearAuthToken() {
    _networkService.clearAuthToken();
  }

  NetworkService get networkService => _networkService;
}

// Global instance for easy access
final apiServices = ApiServiceLocator();