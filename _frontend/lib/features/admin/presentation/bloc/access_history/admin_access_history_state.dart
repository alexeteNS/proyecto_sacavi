import 'package:equatable/equatable.dart';
import '../../../../../shared/models/access_history_model.dart';

class AdminAccessHistoryState extends Equatable {
  final List<AccessHistoryModel> history;
  final AccessStatsModel? stats;
  final bool isLoading;
  final bool isStatsLoading;
  final String? error;

  const AdminAccessHistoryState({
    this.history = const [],
    this.stats,
    this.isLoading = false,
    this.isStatsLoading = false,
    this.error,
  });

  AdminAccessHistoryState copyWith({
    List<AccessHistoryModel>? history,
    AccessStatsModel? stats,
    bool? isLoading,
    bool? isStatsLoading,
    String? error,
  }) {
    return AdminAccessHistoryState(
      history: history ?? this.history,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [history, stats, isLoading, isStatsLoading, error];
}
