enum HeroTagFormBuilderEnum {
  componentsPanel('components_panel'),
  buttonComponents('button_components'),
  addPage('add_page'),
  removePage('remove_page'),
  pagesOverview('pages_overview');

  const HeroTagFormBuilderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
