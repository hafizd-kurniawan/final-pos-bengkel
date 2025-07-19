import 'package:equatable/equatable.dart';
import '../../../data/models/dashboard.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;
  final Map<String, dynamic>? analytics;

  const DashboardLoaded({
    required this.dashboardData,
    this.analytics,
  });

  @override
  List<Object?> get props => [dashboardData, analytics];

  DashboardLoaded copyWith({
    DashboardData? dashboardData,
    Map<String, dynamic>? analytics,
  }) {
    return DashboardLoaded(
      dashboardData: dashboardData ?? this.dashboardData,
      analytics: analytics ?? this.analytics,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}