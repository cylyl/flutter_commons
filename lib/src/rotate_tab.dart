import 'package:flutter/material.dart';
import 'adaptive.dart';

const int turnsToRotateRight = 1;
const int turnsToRotateLeft = 3;

typedef void RotateTabCreatedCallback(TabController controller);

class RotateTab extends StatefulWidget {
  final bool isVertical;
  final List<TabView> tabviews;
  final int? maxWidth;
  final RotateTabCreatedCallback? onCreated;
  final ThemeData? theme;

  const RotateTab({Key? key,
    required this.tabviews,
      this.isVertical = true,
      this.maxWidth,
      this.onCreated,
      this.theme
  })
      : assert(tabviews.length > 0),
        super(key: key);

  @override
  _RotateTabState createState() => _RotateTabState();
}

class _RotateTabState extends State<RotateTab>
    with SingleTickerProviderStateMixin {
  ThemeData? theme;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabviews.length, vsync: this)
      ..addListener(() {
        // Set state to make sure that the [_Tab] widgets get updated when changing tabs.
        setState(() {});
      });
    if (widget.onCreated != null) {
      widget.onCreated!(_tabController!);
    }
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (theme == null) theme = Theme.of(context);
    final isDesktop = isDisplayDesktop(context);
    Widget tabBarView;
    if (isDesktop && widget.isVertical) {
      tabBarView = Row(
        children: [
          Container(
            width: (80.0),
            alignment: Alignment.topCenter,
            /*padding: const EdgeInsets.symmetric(vertical: 32),*/
            child: Column(
              children: [
                /*const SizedBox(height: 24),
                ExcludeSemantics(
                  child: SizedBox(
                    height: 40,
                    child: Image.asset(
                      'logo.png',
                    ),
                  ),
                ),*/
                /*const SizedBox(height: 24),*/
                // Rotate the tab bar, so the animation is vertical for desktops.
                RotatedBox(
                  quarterTurns: turnsToRotateRight,
                  child: RotateTabBar(
                    tabs: _buildTabs(context, theme!, isVertical: true).map(
                      (widget) {
                        // Revert the rotation on the tabs.
                        return RotatedBox(
                          quarterTurns: turnsToRotateLeft,
                          child: widget,
                        );
                      },
                    ).toList(),
                    tabController: _tabController!,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            // Rotate the tab views so we can swipe up and down.
            child: RotatedBox(
              quarterTurns: turnsToRotateRight,
              child: TabBarView(
                controller: _tabController,
                children: _buildTabViews().map(
                      (widget) {
                    // Revert the rotation on the tab views.
                    return RotatedBox(
                      quarterTurns: turnsToRotateLeft,
                      child: widget,
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ],
      );
    } else {
      tabBarView = Column(children: [
        RotateTabBar(
          tabs: _buildTabs(context, theme!),
          tabController: _tabController!,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
        ),
      ]);
    }
    return SafeArea(
      // For desktop layout we do not want to have SafeArea at the top and
      // bottom to display 100% height content on the accounts view.
      top: !isDesktop,
      bottom: !isDesktop,
      child: Theme(
        // This theme effectively removes the default visual touch
        // feedback for tapping a tab, which is replaced with a custom
        // animation.
        data: theme!.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: tabBarView,
        ),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context, ThemeData themeData,
      {isVertical = false}) {
    List<_Tab> list = [];
    int index = 0;
    widget.tabviews.forEach((tabview) {
      list.add(_Tab(
        theme: themeData,
        iconData: tabview.iconData,
        iconColor: tabview.iconColor,
        title: tabview.label,
        tabIndex: index++,
        tabController: _tabController,
        isVertical: isVertical,
        tabCount: widget.tabviews.length,
        maxWidth: widget.maxWidth ?? MediaQuery.of(context).size.width.toInt(),
      ));
    });
    return list;
  }

  List<Widget> _buildTabViews() {
    return [
      for (var tabview in widget.tabviews)
        TabWithSidebar(
            mainView: Center(child: tabview.view),
            sidebarItems: tabview.sideView!)
    ];
  }
}

class RotateTabBar extends StatelessWidget {
  const RotateTabBar(
      {Key? key, required this.tabs, required this.tabController})
      : super(key: key);

  final List<Widget> tabs;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: TabBar(
        // Setting isScrollable to true prevents the tabs from being
        // wrapped in [Expanded] widgets, which allows for more
        // flexible sizes and size animations among tabs.
        isScrollable: true,
        labelPadding: EdgeInsets.zero,
        tabs: tabs,
        controller: tabController,
        // This hides the tab indicator.
        indicatorColor: Colors.transparent,
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  _Tab({
    ThemeData? theme,
    IconData? iconData,
    Color? iconColor,
    String? title,
    required int tabIndex,
    TabController? tabController,
    required this.isVertical,
    this.tabCount = 1,
    this.maxWidth = 0,
  })  : titleText = Text(
    title!,
    style: theme!.textTheme.button,
    textAlign: TextAlign.center,
  ),
        isExpanded = tabController!.index == tabIndex,
        icon = Icon(
          iconData,
          semanticLabel: title,
          color: iconColor,
        );

  final Text titleText;
  final Icon icon;
  final bool isExpanded;
  final bool isVertical;
  final int tabCount;
  final int maxWidth;

  @override
  _TabState createState() => _TabState();
}

class _TabState extends State<_Tab> with SingleTickerProviderStateMixin {
  late Animation<double> _titleSizeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _iconFadeAnimation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _titleSizeAnimation = _controller.view;
    _titleFadeAnimation = _controller.drive(CurveTween(curve: Curves.easeOut));
    _iconFadeAnimation = _controller.drive(Tween<double>(begin: 0.6, end: 1));
    if (widget.isExpanded) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(_Tab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Column(
        children: [
          const SizedBox(height: 18),
          FadeTransition(
            child: widget.icon,
            opacity: _iconFadeAnimation,
          ),
          const SizedBox(height: 12),
          FadeTransition(
            child: SizeTransition(
              child: Center(child: ExcludeSemantics(child: widget.titleText)),
              axis: Axis.vertical,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
            ),
            opacity: _titleFadeAnimation,
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    // Calculate the width of each unexpanded tab by counting the number of
    // units and dividing it into the screen width. Each unexpanded tab is 1
    // unit, and there is always 1 expanded tab which is 1 unit + any extra
    // space determined by the multiplier.
    final width = widget.maxWidth; // ?? MediaQuery.of(context).size.width;
    const expandedTitleWidthMultiplier = 2;
    final unitWidth = width / (widget.tabCount + expandedTitleWidthMultiplier);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          FadeTransition(
            child: SizedBox(
              width: unitWidth,
              child: widget.icon,
            ),
            opacity: _iconFadeAnimation,
          ),
          FadeTransition(
            child: SizeTransition(
              child: SizedBox(
                width: unitWidth * expandedTitleWidthMultiplier,
                child: Center(
                  child: ExcludeSemantics(child: widget.titleText),
                ),
              ),
              axis: Axis.horizontal,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
            ),
            opacity: _titleFadeAnimation,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class TabWithSidebar extends StatelessWidget {
  const TabWithSidebar({
    Key? key,
    required this.mainView,
    required this.sidebarItems,
  }) : super(key: key);

  final Widget mainView;
  final List<Widget> sidebarItems;

  @override
  Widget build(BuildContext context) {
    if (isDisplayDesktop(context) && sidebarItems.length > 0) {
      return Row(
        children: [
          Flexible(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: mainView,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF26282F),

              ///TODO
              padding: const EdgeInsetsDirectional.only(start: 24),
              height: double.infinity,
              alignment: AlignmentDirectional.centerStart,
              child: ListView(
                shrinkWrap: true,
                children: sidebarItems,
              ),
            ),
          ),
        ],
      );
    } else {
      return mainView;
    }
  }
}

class ListItem extends StatelessWidget {
  const ListItem({Key? key, required this.value, required this.title})
      : super(key: key);

  final String value;
  final String title;
  static const Color gray = Color(0xFFD8D8D8);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: textTheme.bodyText2!.copyWith(
            fontSize: 16,
            color: gray,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.bodyText1!.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Container(
          color: Theme.of(context).primaryColor,
          height: 1,
        ),
      ],
    );
  }
}

class TabView {
  final String label;
  final IconData? iconData;
  final Color? iconColor;
  final Widget view;
  final List<Widget>? sideView;

  TabView({required this.label,
    this.iconData,
    this.iconColor,
    required this.view,
    this.sideView})
      : assert(label != null),
        assert(view != null);
}
