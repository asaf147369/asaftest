import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '/models/bloons/single_bloon.dart';

import '/presentation/screens/bloon/single_bloon.dart';
import '/presentation/screens/bloon/boss_bloon.dart';
import '/presentation/widgets/loader.dart';

import '/utilities/global_state.dart';
import '/utilities/images_url.dart';
import '/utilities/requests.dart';
import '/utilities/constants.dart';

class Bloons extends StatefulWidget {
  const Bloons({super.key});

  @override
  State<Bloons> createState() => _BloonsState();
}

class _BloonsState extends State<Bloons> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(children: [
        const Text(
          "Bloons",
          style: bigTitleStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        FutureBuilder(
          future: Future.value(GlobalState.bloons),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Loader();
            } else {
              return GridView.builder(
                  itemCount: snapshot.data.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    mainAxisExtent: 80,
                  ),
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            ListTile(
                              mouseCursor: SystemMouseCursors.click,
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Image(
                                  image: AssetImage(
                                    bloonImage(snapshot.data[index].image),
                                  ),
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                              title: Text(
                                snapshot.data[index].name,
                                style: smallTitleStyle,
                              ),
                              onTap: () async {
                                if (!GlobalState.isLoading) {
                                  var id = snapshot.data[index].id;
                                  var path = '${bloonsDataPath + id}.json';
                                  final data =
                                      await rootBundle.loadString(path);
                                  var jsonData = json.decode(data);
                                  SingleBloonModel bloonData =
                                      SingleBloonModel.fromJson(jsonData);
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SingleBloon(bloon: bloonData),
                                    ),
                                  );
                                  GlobalState.currentTitle = bloonData.name;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }
          },
        ),
        const SizedBox(height: 30),
        const Text(
          "Bosses",
          style: bigTitleStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        FutureBuilder(
          future: Future.value(GlobalState.bosses),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Loader();
            } else {
              return GridView.builder(
                  itemCount: snapshot.data.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1,
                    mainAxisExtent: 80,
                  ),
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        mouseCursor: SystemMouseCursors.click,
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              NetworkImage(bossImage(snapshot.data[index].id)),
                        ),
                        title: Text(snapshot.data[index].name,
                            style: smallTitleStyle),
                        subtitle: Text(
                          snapshot.data[index].type,
                          style: normalStyle,
                        ),
                        onTap: () {
                          if (!GlobalState.isLoading) {
                            getBloonData(snapshot.data[index].id)
                                .then((value) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BossBloon(
                                              bloon: value,
                                            ))));
                          }
                        },
                      ),
                    );
                  });
            }
          },
        ),
      ]),
    ));
  }
}
