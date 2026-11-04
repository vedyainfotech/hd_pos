import 'package:flutter/material.dart';
import 'package:hd_pos/core/theme/theme.dart';

import '../utils/menu_scheduling_screen_responsive.dart';

class MenuSchedulingScreen extends StatefulWidget {
  const MenuSchedulingScreen({super.key});

  @override
  State<MenuSchedulingScreen> createState() => _MenuSchedulingScreenState();
}

class _MenuSchedulingScreenState extends State<MenuSchedulingScreen> {
  DateTime selectedDate = DateTime(2026, 9, 29);

  final Map<String, List<MenuGroup>> menus = {
    'Breakfast': [
      MenuGroup('Tiffins', [
        MenuItem('Idly', 40),
        MenuItem('Vada', 50),
        MenuItem('Pesarattu', 60),
      ]),
      MenuGroup('Beverages', [MenuItem('Tea', 20), MenuItem('Coffee', 30)]),
    ],
    'Lunch': [
      MenuGroup('Rice Items', [
        MenuItem('Chicken Biryani', 180),
        MenuItem('Veg Biryani', 150),
        MenuItem('Plain Rice', 40),
      ]),
      MenuGroup('Curries', [
        MenuItem('Chicken Curry', 160),
        MenuItem('Paneer Curry', 150),
      ]),
      MenuGroup('Sides', [MenuItem('Raita', 30)]),
    ],
    'Dinner': [
      MenuGroup('Rice Items', [
        MenuItem('Fried Rice', 140),
        MenuItem('Schezwan Rice', 150),
      ]),
      MenuGroup('Curries', [
        MenuItem('Manchurian', 140),
        MenuItem('Chilli Chicken', 180),
      ]),
    ],
    'Special Dishes': [
      MenuGroup('Special', [
        MenuItem('Mutton Biryani', 220),
        MenuItem('Fish Curry', 180),
      ]),
    ],
  };

  final Map<String, List<MenuItem>> availableItems = {
    'Tiffins': [
      MenuItem('Idly', 40),
      MenuItem('Vada', 50),
      MenuItem('Pesarattu', 60),
      MenuItem('Dosa', 70),
      MenuItem('Masala Dosa', 80),
      MenuItem('Upma', 50),
      MenuItem('Poori', 50),
    ],
    'Beverages': [
      MenuItem('Tea', 20),
      MenuItem('Coffee', 30),
      MenuItem('Juice', 50),
    ],
    'Rice Items': [
      MenuItem('Chicken Biryani', 180),
      MenuItem('Veg Biryani', 150),
      MenuItem('Plain Rice', 40),
      MenuItem('Fried Rice', 140),
      MenuItem('Schezwan Rice', 150),
    ],
    'Curries': [
      MenuItem('Chicken Curry', 160),
      MenuItem('Paneer Curry', 150),
      MenuItem('Manchurian', 140),
      MenuItem('Chilli Chicken', 180),
    ],
    'Sides': [MenuItem('Raita', 30), MenuItem('Papad', 20)],
    'Snacks': [MenuItem('Samosa', 30), MenuItem('Bajji', 35)],
    'Desserts': [MenuItem('Gulab Jamun', 50), MenuItem('Payasam', 60)],
    'Special': [
      MenuItem('Mutton Biryani', 220),
      MenuItem('Fish Curry', 180),
      MenuItem('Special Meals', 250),
    ],
  };

  int itemCount(String meal) {
    return menus[meal]!.fold(0, (sum, group) => sum + group.items.length);
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${selectedDate.day} '
        '${months[selectedDate.month - 1]} '
        '${selectedDate.year}';
  }

  String get weekday {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[selectedDate.weekday - 1];
  }

  void changeDate(int value) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: value));
    });
  }

  Future<void> selectDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2026),
    lastDate: DateTime(2030),
  );

  if (pickedDate != null) {
    setState(() {
      selectedDate = pickedDate;
    });
  }
}

  // ============================================================
  // ADD ITEMS
  // ============================================================

  Future<void> addItems(String meal) async {
    List<MenuGroup> groups = menus[meal]!
        .map(
          (group) => MenuGroup(
            group.name,
            group.items
                .map(
                  (item) =>
                      MenuItem(item.name, item.price, isActive: item.isActive),
                )
                .toList(),
          ),
        )
        .toList();

    while (mounted) {
      // ------------------------------------------------------------
      // STEP 1: OPEN ADD ITEMS
      // ------------------------------------------------------------

      final result = await showDialog<List<MenuGroup>>(
        context: context,
        builder: (_) => AddItemsDialog(
          mealName: meal,
          availableItems: availableItems,
          currentGroups: groups,
        ),
      );

      // User cancelled
      if (result == null) {
        return;
      }

      groups = result;

      if (!mounted) return;

      // ------------------------------------------------------------
      // STEP 2: SHOW ONLY THIS MEAL'S PREVIEW
      // ------------------------------------------------------------

      final submitted = await showDialog<bool>(
        context: context,
        builder: (_) => MealPreviewDialog(
          date: selectedDate,
          mealName: meal,
          groups: groups,
        ),
      );

      // ------------------------------------------------------------
      // STEP 3: SUBMIT
      // ------------------------------------------------------------

      if (submitted == true) {
        setState(() {
          menus[meal] = groups;
        });

        return;
      }

      // ------------------------------------------------------------
      // STEP 4: BACK
      // ------------------------------------------------------------
      //
      // If Back is pressed, the loop opens Add Items again
      // with the current changes.
    }
  }

  // ============================================================
  // EDIT MEAL
  // ============================================================
  Future<void> editMeal(String meal) async {
    List<MenuGroup> groups = menus[meal]!
        .map(
          (group) => MenuGroup(
            group.name,
            group.items
                .map(
                  (item) =>
                      MenuItem(item.name, item.price, isActive: item.isActive),
                )
                .toList(),
          ),
        )
        .toList();

    while (mounted) {
      final result = await showDialog<List<MenuGroup>>(
        context: context,
        builder: (_) => EditMealDialog(mealName: meal, groups: groups),
      );

      if (result == null) {
        return;
      }

      // Keep changes temporary until Submit
      groups = result;

      if (!mounted) return;

      final submitted = await showDialog<bool>(
        context: context,
        builder: (_) => MealPreviewDialog(
          date: selectedDate,
          mealName: meal,
          groups: groups,
        ),
      );

      if (submitted == true) {
        // Only now save the changes
        setState(() {
          menus[meal] = groups;
        });

        return;
      }

      // submitted == false
      // Preview Back → open Edit again
    }
  }
  // ============================================================
  // PREVIEW
  // ============================================================

  Future<void> showMenuPreview() async {
    await showDialog(
      context: context,
      builder: (_) => MenuPreviewDialog(date: selectedDate, menus: menus),
    );
  }

 // ============================================================
// RESPONSIVE MAIN SCREEN
// ============================================================

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Menu Scheduling'),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final horizontalPadding =
            MenuSchedulingResponsive.horizontalPadding(width);

        final verticalPadding =
            MenuSchedulingResponsive.verticalPadding(width);

        final gap =
            MenuSchedulingResponsive.spacing(width);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              buildPageHeader(width),

              SizedBox(
                height: width < 600 ? 14 : 16,
              ),

              // ==================================================
              // MEAL CARDS
              // ==================================================

              LayoutBuilder(
                builder: (context, gridConstraints) {
                  final availableWidth =
                      gridConstraints.maxWidth;

                  final columns =
                      MenuSchedulingResponsive.gridColumns(
                    availableWidth,
                  );

                  final cardWidth =
                      MenuSchedulingResponsive.cardWidth(
                    availableWidth,
                    columns,
                    gap,
                  );

                  final cardHeight =
                      MenuSchedulingResponsive.cardHeight(
                    cardWidth,
                  );

                  return GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: menus.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
                      mainAxisExtent: cardHeight,
                    ),
                    itemBuilder: (context, index) {
                      final meal =
                          menus.keys.elementAt(index);

                      return MealCard(
                        mealName: meal,
                        groups: menus[meal]!,
                        itemCount: itemCount(meal),
                        onEdit: () => editMeal(meal),
                        onAddItems: () => addItems(meal),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}

// ============================================================
// PAGE HEADER
// ============================================================

// ============================================================
// PAGE HEADER
// ============================================================

Widget buildPageHeader(double width) {
  final isPhone = width < 600;

  // ==========================================================
  // PHONE
  // ==========================================================

  if (isPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        Text(
          'Manage the menu for each delivery date.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 14),

        buildDateSelector(width),
      ],
    );
  }

  // ==========================================================
  // TABLET / DESKTOP
  // ==========================================================

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 4),

            Text(
              'Manage the menu for each delivery date.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),

      const SizedBox(width: 20),

      buildDateSelector(width),
    ],
  );
}

  // ============================================================
  // DATE SELECTOR
  // ============================================================

  Widget buildDateSelector(double width) {
    return Container(
      width: 300,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => changeDate(-1),
            icon: const Icon(Icons.chevron_left, size: 21),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),

          Expanded(
            child: InkWell(
              onTap: selectDate,
              borderRadius: BorderRadius.circular(6),
              child: Center(
                child: Text(
                  formattedDate,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: () => changeDate(1),
            icon: const Icon(Icons.chevron_right, size: 21),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),

          InkWell(
            onTap: selectDate,
            borderRadius: BorderRadius.circular(7),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ================================================================
// MEAL CARD
// ================================================================

class MealCard extends StatelessWidget {
  final String mealName;
  final List<MenuGroup> groups;
  final int itemCount;
  final VoidCallback onEdit;
  final VoidCallback onAddItems;

  const MealCard({
    super.key,
    required this.mealName,
    required this.groups,
    required this.itemCount,
    required this.onEdit,
    required this.onAddItems,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    mealName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$itemCount Items',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ====================================================
            // INNER SCROLLING CONTENT
            // ====================================================
            Expanded(
              child: groups.isEmpty
                  ? Center(
                      child: Text(
                        'No items scheduled',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                          padding: const EdgeInsets.only(
                            right: 6,
                           bottom: 4,
                            ),
                            itemCount: groups.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return MenuGroupPreview(
                                group: groups[index],
                              );
                            },
                          ),
                    ),
            ),

            const SizedBox(height: 8),

            // ====================================================
            // BUTTONS
            // ====================================================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onAddItems,
                    child: const Text('+ Add Items'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// GROUP PREVIEW
// ================================================================

class MenuGroupPreview extends StatelessWidget {
  final MenuGroup group;

  const MenuGroupPreview({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${group.name} (${group.items.length})',
            style: Theme.of(context).textTheme.labelLarge,
          ),

          const SizedBox(height: 5),

          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ADD ITEMS DIALOG
// ================================================================

class AddItemsDialog extends StatefulWidget {
  final String mealName;
  final Map<String, List<MenuItem>> availableItems;
  final List<MenuGroup> currentGroups;

  const AddItemsDialog({
    super.key,
    required this.mealName,
    required this.availableItems,
    required this.currentGroups,
  });

  @override
  State<AddItemsDialog> createState() => _AddItemsDialogState();
}

class _AddItemsDialogState extends State<AddItemsDialog> {
  late String selectedCategory;

  final Set<String> selectedItems = {};

  String search = '';

  @override
  void initState() {
    super.initState();

    selectedCategory = widget.availableItems.keys.first;

    for (final group in widget.currentGroups) {
      for (final item in group.items) {
        selectedItems.add('${group.name}|${item.name}');
      }
    }
  }

  List<MenuItem> get filteredItems {
    final items = widget.availableItems[selectedCategory] ?? [];

    if (search.trim().isEmpty) {
      return items;
    }

    return items
        .where((item) => item.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  List<MenuGroup> buildGroups() {
    final Map<String, List<MenuItem>> result = {};

    for (final entry in widget.availableItems.entries) {
      final items = entry.value.where(
        (item) => selectedItems.contains('${entry.key}|${item.name}'),
      );

      if (items.isNotEmpty) {
        result[entry.key] = items
            .map((item) => MenuItem(item.name, item.price))
            .toList();
      }
    }

    return result.entries
        .map((entry) => MenuGroup(entry.key, entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final mobile = width < 600;

   return AlertDialog(
  title: Row(
    children: [
      Expanded(
        child: Text(
          'Add Items - ${widget.mealName}',
        ),
      ),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
        tooltip: 'Close',
      ),
    ],
  ),

  content: SizedBox(
    width: mobile ? width - 32 : 560,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              search = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search items...',
            prefixIcon: Icon(Icons.search),
          ),
        ),

        const SizedBox(height: 12),

        if (mobile)
          buildMobile()
        else
          buildDesktop(),
      ],
    ),
  ),

  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),

    ElevatedButton(
      onPressed: () {
        Navigator.pop(context, buildGroups());
      },
      child: const Text('Preview'),
    ),
  ],
);
  }

 Widget buildMobile() {
  return Column(
    children: [
      DropdownButtonFormField<String>(
        initialValue: selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Subcategory',
        ),
        items: widget.availableItems.keys
            .map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedCategory = value;
            });
          }
        },
      ),

      const SizedBox(height: 10),

      SizedBox(
        height: 300,
        child: ListView(
          padding: EdgeInsets.zero,
          children: filteredItems
              .map(buildCheckItem)
              .toList(),
        ),
      ),
    ],
  );
}

Widget buildDesktop() {
  return SizedBox(
    height: 300,
    child: Row(
      children: [
        SizedBox(
          width: 150,
          child: DecoratedBox(
            decoration: BoxDecoration(
              // Entire category panel is WHITE
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: widget.availableItems.keys.map((category) {
                final selected = category == selectedCategory;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),

                    // ONLY SELECTED SUBCATEGORY IS COLORED
                    color: selected
                        ? AppColors.primarySoft
                        : AppColors.surface,

                    child: Text(
                      category,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ListView(
            children: filteredItems
                .map(buildCheckItem)
                .toList(),
          ),
        ),
      ],
    ),
  );
}

  Widget buildCheckItem(MenuItem item) {
    final key = '$selectedCategory|${item.name}';
    final selected = selectedItems.contains(key);

    return InkWell(
      onTap: () {
        setState(() {
          if (selected) {
            selectedItems.remove(key);
          } else {
            selectedItems.add(key);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Hollow selected checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? Colors.transparent : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.borderLight,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: selected
                  ? Icon(Icons.check, size: 20, color: AppColors.primary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// EDIT MEAL
// ================================================================

class EditMealDialog extends StatefulWidget {
  final String mealName;
  final List<MenuGroup> groups;

  const EditMealDialog({
    super.key,
    required this.mealName,
    required this.groups,
  });

  @override
  State<EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends State<EditMealDialog> {
  late List<MenuGroup> groups;

  @override
  void initState() {
    super.initState();

    groups = widget.groups
        .map(
          (group) => MenuGroup(
            group.name,
            group.items
                .map(
                  (item) =>
                      MenuItem(item.name, item.price, isActive: item.isActive),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AlertDialog(
  title: Row(
    children: [
      Expanded(
        child: Text(
          'Edit ${widget.mealName} Menu',
        ),
      ),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
        tooltip: 'Close',
      ),
    ],
  ),

  content: SizedBox(
    // Smaller dialog
    width: width < 600 ? width - 32 : 520,

    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.65,
      ),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final group in groups)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),

                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Column(
                  children: [
                    // Group header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${group.name} (${group.items.length})',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),

                    // Items
                    ...group.items.map(
                      (item) => buildItem(group, item),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  ),

  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),

    ElevatedButton(
      onPressed: () {
        Navigator.pop(context, groups);
      },
      child: const Text('Preview'),
    ),
  ],
);
  }

  Widget buildItem(MenuGroup group, MenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      child: Row(
        children: [
          // Item name
          Expanded(child: Text(item.name, overflow: TextOverflow.ellipsis)),

          const SizedBox(width: 12),

          // Price
          Text(
            '₹${item.price.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(width: 12),

          // Only Remove button
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.delete_outline, size: 21),
            onPressed: () {
              setState(() {
                group.items.remove(item);

                // Remove empty group
                if (group.items.isEmpty) {
                  groups.remove(group);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
// ================================================================
// MEAL PREVIEW DIALOG
// ================================================================

class MealPreviewDialog extends StatelessWidget {
  final DateTime date;
  final String mealName;
  final List<MenuGroup> groups;

  const MealPreviewDialog({
    super.key,
    required this.date,
    required this.mealName,
    required this.groups,
  });

  int countItems() {
    return groups.fold(0, (sum, group) => sum + group.items.length);
  }

  String weekday(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width < 600 ? width - 24 : 700,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview - $mealName',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '${date.day.toString().padLeft(2, '0')}/'
                          '${date.month.toString().padLeft(2, '0')}/'
                          '${date.year}'
                          ' • '
                          '${weekday(date)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(),

              const SizedBox(height: 8),

              // ==================================================
              // ITEM COUNT
              // ==================================================
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$mealName • ${countItems()} Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // ONLY SELECTED MEAL CONTENT
              // ==================================================
              Expanded(
                child: groups.isEmpty
                    ? Center(
                        child: Text(
                          'No items selected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : Scrollbar(
                        thumbVisibility: true,
                        child: ListView.separated(
                          itemCount: groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final group = groups[index];

                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // GROUP HEADER
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      '${group.name} (${group.items.length})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),

                                  // ITEMS
                                  ...group.items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          Text(
                                            '₹${item.price.toStringAsFixed(0)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // BACK + SUBMIT
              // ==================================================
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('Back'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// MENU PREVIEW
// ================================================================

class MenuPreviewDialog extends StatelessWidget {
  final DateTime date;
  final Map<String, List<MenuGroup>> menus;

  const MenuPreviewDialog({super.key, required this.date, required this.menus});

  int count(List<MenuGroup> groups) {
    return groups.fold(0, (sum, group) => sum + group.items.length);
  }

  String weekday(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  double previewCardWidth(double width) {
    if (width < 600) {
      return width - 40;
    }

    if (width < 1000) {
      return (width - 12) / 2;
    }

    return (width - 36) / 4;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width < 600 ? width - 24 : 1200,
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu Preview',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${date.day.toString().padLeft(2, '0')}/'
                          '${date.month.toString().padLeft(2, '0')}/'
                          '${date.year} • '
                          '${weekday(date)}',
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(),

              // PREVIEW CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final entry in menus.entries)
                        SizedBox(
                          width: previewCardWidth(width),
                          child: Card(
                            color: AppColors.surfaceSoft,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: AppColors.primary),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    '${count(entry.value)} Items',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),

                                  const SizedBox(height: 10),

                                  for (final group in entry.value)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            group.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge,
                                          ),

                                          ...group.items.map(
                                            (item) => Padding(
                                              padding: const EdgeInsets.only(
                                                top: 3,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${item.price.toStringAsFixed(0)}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STATIC DATA MODELS
// ================================================================

class MenuItem {
  final String name;
  final double price;
  bool isActive;

  MenuItem(this.name, this.price, {this.isActive = true});
}

class MenuGroup {
  final String name;
  final List<MenuItem> items;

  MenuGroup(this.name, this.items);
}
