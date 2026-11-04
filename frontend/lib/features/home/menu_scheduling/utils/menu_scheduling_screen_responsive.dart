class MenuSchedulingResponsive {
  static double horizontalPadding(double width) {
    if (width < 600) return 16;
    if (width < 1024) return 24;
    return 32;
  }

  static double verticalPadding(double width) {
    if (width < 600) return 12;
    if (width < 1024) return 20;
    return 24;
  }

  static double spacing(double width) {
    if (width < 600) return 12;
    if (width < 900) return 16;
    return 20;
  }

  static int gridColumns(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  static double cardWidth(double availableWidth, int columns, double gap) {
    final safeColumns = columns < 1 ? 1 : columns;
    return (availableWidth - gap * (safeColumns - 1)) / safeColumns;
  }

  static double cardHeight(double cardWidth) {
    if (cardWidth < 240) return 300;
    if (cardWidth < 340) return 320;
    return 340;
  }
}