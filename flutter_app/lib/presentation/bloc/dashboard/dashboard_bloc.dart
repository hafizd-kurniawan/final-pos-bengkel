import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/api_service_locator.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardDataRequested>(_onDashboardDataRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
    on<DashboardAnalyticsRequested>(_onDashboardAnalyticsRequested);
  }

  Future<void> _onDashboardDataRequested(
    DashboardDataRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    
    try {
      final dashboardData = await apiServices.dashboardService.getDashboard();
      
      emit(DashboardLoaded(dashboardData: dashboardData));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final dashboardData = await apiServices.dashboardService.getDashboard();
      
      // Preserve analytics if already loaded
      Map<String, dynamic>? analytics;
      if (state is DashboardLoaded) {
        analytics = (state as DashboardLoaded).analytics;
      }
      
      emit(DashboardLoaded(
        dashboardData: dashboardData,
        analytics: analytics,
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onDashboardAnalyticsRequested(
    DashboardAnalyticsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final analytics = await apiServices.dashboardService.getAnalytics(
        period: event.period,
      );
      
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(currentState.copyWith(analytics: analytics));
      } else {
        // Load dashboard data first
        final dashboardData = await apiServices.dashboardService.getDashboard();
        emit(DashboardLoaded(
          dashboardData: dashboardData,
          analytics: analytics,
        ));
      }
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}