import '../models/message.dart';

abstract class SearchState {}

class SearchInitialState extends SearchState {}

class SearchLoadingState extends SearchState {}

class SearchLoadedState extends SearchState {
  final String res;
  final List<Message> messages;

  SearchLoadedState({required this.res, required this.messages});
}

class SearchErrorState extends SearchState {
  final String errorMessage;

  SearchErrorState(this.errorMessage);
}

class SearchChatState extends SearchState {
  final List<Message> messages;
  final bool isLoading;

  SearchChatState({required this.messages, this.isLoading = false});
}