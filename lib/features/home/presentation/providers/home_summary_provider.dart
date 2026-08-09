import 'package:delivo/features/home/domain/entities/home_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeSummaryProvider = Provider<HomeSummary>((ref) => HomeSummary.empty);
