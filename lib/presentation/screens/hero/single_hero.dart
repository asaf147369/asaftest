import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '/models/towers/common/upgrade_info_class.dart';
import '/models/towers/hero/hero_skins.dart';
import '/models/towers/hero/hero.dart';
import '/presentation/widgets/hero_stats.dart';
import '/presentation/widgets/hero_level.dart';
import '/analytics/analytics_constants.dart';
import '/analytics/analytics.dart';
import '/utilities/images_url.dart';
import '/utilities/constants.dart';
import '/utilities/utils.dart';

class SingleHero extends StatefulWidget {
  final AnalyticsHelper analyticsHelper;
  final String heroId;

  const SingleHero({
    super.key,
    required this.heroId,
    required this.analyticsHelper,
  });

  @override
  State<SingleHero> createState() => _SingleHeroState();
}

class _SingleHeroState extends State<SingleHero> {
  late final HeroModel singleHero;
  final controller = CarouselController();
  List<String> skinsFirstImages = [];
  List<String> skinsNames = [];
  int activeIndex = 0;
  bool loading = true;

  HeroLevel _buildHeroLevel(UpgradeInfo level) {
    List<String> skinsImages = [];
    bool shouldShowLevelImage = false;
    int indexOfLevel;

    if (singleHero.skinChange.contains(level.name)) {
      shouldShowLevelImage = true;
      indexOfLevel = singleHero.skinChange.indexOf(level.name);
      var skinNamesAndImages = getSkinNamesAndImages(indexOfLevel);
      skinsImages = skinNamesAndImages[1];
    }
    return HeroLevel(
      heroId: widget.heroId,
      level: level,
      shouldShowLevelImage: shouldShowLevelImage,
      heroImages: skinsImages,
      heroName: singleHero.name,
      analyticsHelper: widget.analyticsHelper,
    );
  }

  List<List<String>> getSkinNamesAndImages(int levelIndex) {
    List<String> names = [];
    List<String> images = [];
    for (var skin in singleHero.skins) {
      names.add(skin.name);
      images.add(skin.value[levelIndex]);
    }
    return [names, images];
  }

  void loadHero() async {
    var path = '${heroDataPath + widget.heroId}.json';
    final data = await rootBundle.loadString(path);
    var jsonData = json.decode(data);
    singleHero = HeroModel.fromJson(jsonData);
    setState(() {
      loading = false;
      var skinNamesAndImages = getSkinNamesAndImages(0);
      skinsNames = skinNamesAndImages[0];
      skinsFirstImages = skinNamesAndImages[1];
    });
  }

  @override
  void initState() {
    super.initState();
    widget.analyticsHelper.logScreenView(
      screenClass: kTowerPagesClass,
      screenName: widget.heroId,
    );
    loadHero();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(!loading ? singleHero.name : ''),
      ),
      body: !loading
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          CarouselSlider.builder(
                            carouselController: controller,
                            options: CarouselOptions(
                              viewportFraction: 0.64,
                              initialPage: 0,
                              height: MediaQuery.of(context).size.width * 0.5,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  activeIndex = index;
                                });
                              },
                            ),
                            itemCount: singleHero.skins.length,
                            itemBuilder: ((context, index, realIndex) => Image(
                                  image: AssetImage(
                                      heroImage(skinsFirstImages[index])),
                                  filterQuality: FilterQuality.high,
                                  width:
                                      MediaQuery.of(context).size.width * 0.56,
                                )),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            skinsNames[activeIndex],
                            style: smallTitleStyle,
                          ),
                          const SizedBox(height: 10),
                          AnimatedSmoothIndicator(
                            activeIndex: activeIndex,
                            count: singleHero.skins.length,
                            onDotClicked: (index) =>
                                controller.jumpToPage(index),
                            effect: const ScrollingDotsEffect(
                              activeDotScale: 1.25,
                              spacing: 11,
                              dotHeight: 9,
                              dotWidth: 9,
                              activeDotColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      // Image(
                      //   image: AssetImage(heroImage(singleHero.image)),
                      //   width: 200,
                      //   fit: BoxFit.fill,
                      //   semanticLabel: singleHero.name,
                      // ),
                      const SizedBox(height: 10),
                      Text(singleHero.inGameDesc,
                          textAlign: TextAlign.center, style: normalStyle),
                      const SizedBox(height: 10),
                      Text(costToString(singleHero.cost),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        title: const Text("Advanced Stats"),
                        onExpansionChanged: (bool value) {
                          widget.analyticsHelper.logEvent(
                            name: widgetEngagement,
                            parameters: {
                              'screen': singleHero.id,
                              'widget': expanstionTile,
                              'value': 'hero_stats_$value',
                            },
                          );
                        },
                        children: [
                          StatsList(
                            heroId: singleHero.id,
                            heroStats: singleHero.stats,
                            analyticsHelper: widget.analyticsHelper,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // if has skins, render a button that will take to a new page that shows the skins
                      // if (singleHero.skins.isNotEmpty)
                      //   ElevatedButton(
                      //     child: const Text("Skins"),
                      //     onPressed: () => Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => HeroSkins(
                      //           heroId: heroId,
                      //           heroSkins: singleHero.skins,
                      //           skinChange: singleHero.skinChange,
                      //           heroName: singleHero.name,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: singleHero.levels.length,
                        itemBuilder: (context, index) => _buildHeroLevel(
                          singleHero.levels[index],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
