import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeInitialLoadEvent extends HomeEvent {
  const HomeInitialLoadEvent();
}

class HomeRefreshDataEvent extends HomeEvent {
  const HomeRefreshDataEvent();
}

class GenerateNewMealPlanEvent extends HomeEvent {
  const GenerateNewMealPlanEvent();
}

class SwapMealEvent extends HomeEvent {
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final int? snackIndex; // Only needed for snacks

  const SwapMealEvent({required this.mealType, this.snackIndex});

  @override
  List<Object> get props => [mealType, if (snackIndex != null) snackIndex!];
}

class LogMealEvent extends HomeEvent {
  const LogMealEvent();
}

class AddActivityEvent extends HomeEvent {
  const AddActivityEvent();
}

class ViewProgressEvent extends HomeEvent {
  const ViewProgressEvent();
}

class NavigateToProfileEvent extends HomeEvent {
  const NavigateToProfileEvent();
}
