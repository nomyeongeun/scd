import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomeController extends GetxController {

  HomeController();

  var userEnteredMessage = "".obs;
  var ragresponse = "".obs;
  var userMessageList = [].obs;
  var responseMessageList = [].obs;

  void handleSubmitted() async{
    
    final response = await http.post(
      Uri.parse('http://localhost:8000/rag'),
      body: utf8.encode(jsonEncode({'input' : userEnteredMessage.value})),
      headers: {'Content-Type': 'application/json'},
    );
    
    ragresponse.value = utf8.decode(response.bodyBytes);

    userMessageList.add(userEnteredMessage.value);
    responseMessageList.add(ragresponse.value);

    print(userEnteredMessage.value);
    print(ragresponse);
  }
}