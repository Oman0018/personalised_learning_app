//personalised_learning_app/lib/services/module_service.dart
//3) Learning Module content provider (mock only)
import 'mock_data.dart';

class ModuleItem {
  final String id, title, summary, content;
  ModuleItem(this.id, this.title, this.summary, this.content);

  factory ModuleItem.fromMap(Map<String, String> m) =>
      ModuleItem(m['id']!, m['title']!, m['summary']!, m['content']!);
}

class ModuleService {
  static final List<ModuleItem> _items =
      MockData.modules.map((m) => ModuleItem.fromMap(m)).toList();

  static int get length => _items.length;
  static ModuleItem byIndex(int i) => _items[i];
}
