import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'dart:html';
import 'dart:ui_web' as ui;

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final _textController = TextEditingController();
  final homecontroller = HomeController();
  
  void initState() {
    // assets/map.html에서 작성한 네이버 지도 API 호출 후 
    // 응답받은 iframe을 IFrameElement라는 Flutter Widget으로 등록
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'naver-map',
      (int viewId) => IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..src = 'assets/map.html'
        ..style.border = 'none',
    );
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return Scaffold(
      appBar: AppBar(
        title: Text('소캡디 데모'),
      ),
      body: Row(
        children : [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding (
                padding : EdgeInsets.only(left : 0),
                child : 
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 12,
                          bottom: 9),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                          ),
                        //margin: const EdgeInsets.only(left: 23),
                        width:  370,
                        height: 52,
                        child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 94, 169, 97)),
                                ),
                                hintText: '원하는 장소에 대해 물어보세요!',
                                hintStyle: TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 20,
                                  fontFamily: 'Noto Sans',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                  letterSpacing: -1,
                                ),
                              ),
                            controller: _textController,
                            onChanged: (val) {
                                homecontroller.userEnteredMessage.value = val;
                              },
                            ),
                      ),  
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: Transform.rotate(
                            angle: 0.8,
                            child: IconButton(
                                icon : Icon(Icons.heart_broken),
                                onPressed: () {
                                  homecontroller.handleSubmitted();
                                  _textController.clear();
                                  }
                              ),
                          )
                        ),
                      ],
                    )
              ),
              Obx(() => SizedBox(
                width: 300,
                child :Text(homecontroller.ragresponse.value)
                ) 
              ),
              Obx(
                () {
                  return 
                    SizedBox(
                    width: 400,
                    height: 300,
                    child : 
                      ListView.builder(
                      itemCount: homecontroller.userMessageList.length,
                      itemBuilder: (context, index) {
                        return Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(5),
                              child: GetX<HomeController>(
                                builder: (_) => Container(
                                  height: 120,
                                  child: Card(
                                    elevation: 1,
                                    margin: EdgeInsets.all(1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      leading : Text(
                                        "💬",
                                        style:TextStyle(
                                          fontSize: 20
                                        ),
                                      ),
                                      title: Text(
                                        "${homecontroller.userMessageList[index]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontFamily: 'Noto Sans',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "😃 : ${homecontroller.responseMessageList[index]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontFamily: 'Noto Sans',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),                               
                                    ),
                                  ),
                                ),
                              ),
                            );         
                          }
                        )
                     );
                  } 
              ),
              
            ]
          ),
          Padding(
                padding : EdgeInsets.only(left : 100),
                child : Center(
                  child: SizedBox(
                      height: 200,
                      width: 400,
                      // 등록된 IFrameElement Widget들 중 
                      //'naver-map'라는 이름을 가진 개체를 Widget으로 임베딩
                      child: HtmlElementView(viewType: 'naver-map'),
                    ),
                  ),
              )
        ]
      )
    );
  }
}
