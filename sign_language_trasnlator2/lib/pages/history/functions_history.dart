class ChatHistory {
  List<Map<String, String>> textHistory = [];

  List<Map<String, String>> getHistory() {
    textHistory = [
      {'date': '9/24', 'time': '8:00:00', 'message': 'Hi, how are you?'},
      {'date': '9/25', 'time': '8:00:05', 'message': 'Goodbye'},
      {'date': '9/26', 'time': '8:00:10', 'message': 'Goodbye'},
      //Messages goes here
    ];

    return textHistory;
  }

  void addHistory(String date, String message) {
    Map<String, String> newMessage = {'date': date, 'message': message};
    textHistory.add(newMessage);
  }
}
