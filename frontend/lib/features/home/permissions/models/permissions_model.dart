class PermissionRole {
  final int id;
  final String name;

  const PermissionRole({
    required this.id,
    required this.name,
  });

  factory PermissionRole.fromJson(Map<String, dynamic> json) {
    return PermissionRole(
      id: int.parse(
        (json['id'] ?? json['role_id']).toString(),
      ),
      name: (json['name'] ?? json['role_name'] ?? '').toString(),
    );
  }
}

class PermissionScreen {
  final int id;
  final String name;

  const PermissionScreen({
    required this.id,
    required this.name,
  });

  factory PermissionScreen.fromJson(Map<String, dynamic> json) {
    return PermissionScreen(
      id: int.parse(
        (json['id'] ?? json['screen_id']).toString(),
      ),
      name: (json['name'] ?? json['screen_name'] ?? '').toString(),
    );
  }
}

class ScreenPermission {
  final int screenId;
  bool canView;

  ScreenPermission({
    required this.screenId,
    this.canView = false,
  });

  factory ScreenPermission.fromJson(Map<String, dynamic> json) {
    return ScreenPermission(
      screenId: int.parse(
        (json['screen_id'] ?? json['id']).toString(),
      ),
      canView: json['can_view'] == true ||
          json['can_view'] == 1 ||
          json['can_view'].toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screen_id': screenId,
      'can_view': canView,
    };
  }
}