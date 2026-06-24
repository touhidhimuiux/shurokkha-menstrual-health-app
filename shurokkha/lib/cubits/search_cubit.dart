import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'search_state.dart';
import '../models/message.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitialState());

  List<Message> messages = [];

  Future<void> getSearchResponse({required String query}) async {
    // Add user message
    messages.add(Message(
      text: query,
      isUser: true,
      time: DateTime.now(),
    ));

    // Emit loading state with updated messages
    emit(SearchChatState(messages: messages, isLoading: true));

    String apiKey = "GEMINI_API_KEY";

    String url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$apiKey";

    // Determine the prompt based on the query category
    String systemPrompt = _getSystemPrompt(query);

    Map<String, dynamic> bodyParams = {
      "contents": [
        {
          "parts": [
            {
              "text": "$systemPrompt\n\nUser question: $query",
            }
          ]
        }
      ]
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyParams),
      );

      print(response.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        String result =
            data["candidates"][0]["content"]["parts"][0]["text"];

        // Clean up the response - remove extra formatting
        result = result.trim();

        // Add AI message
        messages.add(Message(
          text: result,
          isUser: false,
          time: DateTime.now(),
        ));

        emit(SearchChatState(messages: messages, isLoading: false));
      } else {
        messages.add(Message(
          text: "Sorry, I couldn't understand that. Please try again.",
          isUser: false,
          time: DateTime.now(),
        ));
        emit(SearchChatState(messages: messages, isLoading: false));
      }
    } catch (e) {
      messages.add(Message(
        text: "I'm having trouble connecting. Please try again.",
        isUser: false,
        time: DateTime.now(),
      ));
      emit(SearchChatState(messages: messages, isLoading: false));
    }
  }

  String _getSystemPrompt(String query) {
    if (query.toLowerCase().contains('menstrual') ||
        query.toLowerCase().contains('period') ||
        query.toLowerCase().contains('cycle')) {
      return "You are a friendly health assistant specializing in women's health. Keep your answer SHORT and simple (2-3 sentences max). Use simple English. Focus on period and menstrual cycle information.";
    } else if (query.toLowerCase().contains('pain') ||
        query.toLowerCase().contains('relief')) {
      return "You are a health assistant. Keep your answer SHORT and simple (2-3 sentences max). Focus on pain relief and pain management tips.";
    } else if (query.toLowerCase().contains('nutrition') ||
        query.toLowerCase().contains('food') ||
        query.toLowerCase().contains('eat')) {
      return "You are a nutrition expert. Keep your answer SHORT and simple (2-3 sentences max). Focus on nutritional advice and what foods are good.";
    } else if (query.toLowerCase().contains('mood') ||
        query.toLowerCase().contains('emotion') ||
        query.toLowerCase().contains('stress')) {
      return "You are a wellness expert. Keep your answer SHORT and simple (2-3 sentences max). Focus on mood management and emotional wellness.";
    } else if (query.toLowerCase().contains('product') ||
        query.toLowerCase().contains('pad') ||
        query.toLowerCase().contains('tampon')) {
      return "You are a health product advisor. Keep your answer SHORT and simple (2-3 sentences max). Focus on period products and safety.";
    } else {
      return "You are a helpful health assistant. Keep your answer SHORT and simple (2-3 sentences max). Use simple English.";
    }
  }
}