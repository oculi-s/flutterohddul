import 'package:flutter/material.dart';
import 'package:flutterohddul/data/user.dart';

class ProfileScreen extends StatefulWidget {
  final bool mine;
  final User user; // 변경된 부분: User 클래스로 대체

  ProfileScreen({
    required this.mine,
    required this.user,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> userPred;
  late List<dynamic> userHist;
  late Map<String, dynamic> userMeta;
  late Map<String, bool> loadUser;

  @override
  void initState() {
    super.initState();
    userPred = {'queue': [], 'data': []};
    userHist = [];
    userMeta = {'rank': 1000};
    loadUser = {'meta': true, 'pred': true, 'hist': true};
    fetchData();
  }

  Future<void> fetchData() async {
    if (widget.user.uid.isNotEmpty) {
      // TODO: API 호출을 통해 데이터 가져오기
      // 예시: api.json.read(url: dir.user.meta(widget.user.uid))
      // 그리고 가져온 데이터를 userMeta, userPred, userHist에 할당하고 loadUser 값을 업데이트
      // 예시: setMeta(newMeta); setLoad((e) { e['meta'] = false; return e; });
      // 위와 같은 방식으로 userPred, userHist에 대해서도 동일하게 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.id),
      ),
      body: Column(
        children: [
          // TODO: Profile 화면의 구성을 여기에 추가
          // 예시: HeaderWidget(meta: widget.user.meta, favs: widget.user.favs),
          // 나머지 화면의 구성도 동일한 방식으로 추가
        ],
      ),
    );
  }
}
