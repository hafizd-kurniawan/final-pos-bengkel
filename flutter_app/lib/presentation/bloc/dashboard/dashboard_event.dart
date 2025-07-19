import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardDataRequested extends DashboardEvent {
  const DashboardDataRequested();
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

class DashboardAnalyticsRequested extends DashboardEvent {
  final String period;

  const DashboardAnalyticsRequested({
    this.period = 'month',
  });

  @override
  List<Object> get props => [period];
}