import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hour_tracker/models/project_model.dart';
import 'package:hour_tracker/models/task_model.dart';
import 'package:hour_tracker/models/time_entry_model.dart';
import 'package:hour_tracker/models/user_settings_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hour_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Projects Table
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        client_name TEXT,
        hourly_rate REAL NOT NULL DEFAULT 0.0,
        color_hex TEXT NOT NULL,
        target_hours REAL DEFAULT 0.0,
        created_at TEXT NOT NULL
      )
    ''');

    // Tasks Table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Time Entries Table
    await db.execute('''
      CREATE TABLE time_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER,
        project_name TEXT NOT NULL,
        project_color TEXT NOT NULL,
        task_id INTEGER,
        task_name TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        break_minutes INTEGER NOT NULL DEFAULT 0,
        hourly_rate REAL NOT NULL DEFAULT 0.0,
        is_billable INTEGER NOT NULL DEFAULT 1,
        is_overtime INTEGER NOT NULL DEFAULT 0,
        overtime_multiplier REAL NOT NULL DEFAULT 1.5,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // User Settings Table
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        daily_target REAL DEFAULT 8.0,
        weekly_target REAL DEFAULT 40.0,
        monthly_target REAL DEFAULT 160.0,
        overtime_threshold REAL DEFAULT 8.0,
        overtime_multiplier REAL DEFAULT 1.5,
        enable_notifications INTEGER DEFAULT 1
      )
    ''');

    // Seed initial settings & sample projects
    await db.insert('user_settings', UserSettingsModel().toMap());
    
    final sampleProject1 = ProjectModel(
      name: 'Mobile App Development',
      clientName: 'Acme Corp',
      hourlyRate: 45.0,
      colorHex: '0xFF6C5CE7',
      targetHours: 40.0,
    );

    final sampleProject2 = ProjectModel(
      name: 'UI/UX Design Strategy',
      clientName: 'Design Studio',
      hourlyRate: 35.0,
      colorHex: '0xFF00CEC9',
      targetHours: 20.0,
    );

    final p1Id = await db.insert('projects', sampleProject1.toMap());
    final p2Id = await db.insert('projects', sampleProject2.toMap());

    await db.insert('tasks', TaskModel(projectId: p1Id, name: 'Flutter Coding').toMap());
    await db.insert('tasks', TaskModel(projectId: p1Id, name: 'Code Review').toMap());
    await db.insert('tasks', TaskModel(projectId: p2Id, name: 'Wireframing').toMap());

    // Seed sample time entries for past 3 days so dashboard/graphs look great immediately!
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    await db.insert('time_entries', TimeEntryModel(
      projectId: p1Id,
      projectName: 'Mobile App Development',
      projectColor: '0xFF6C5CE7',
      taskName: 'Flutter Coding',
      startTime: twoDaysAgo.subtract(const Duration(hours: 8)),
      endTime: twoDaysAgo.subtract(const Duration(hours: 3)),
      durationMinutes: 300,
      breakMinutes: 30,
      hourlyRate: 45.0,
      isBillable: true,
      notes: 'Initial state setup and architecture design',
    ).toMap());

    await db.insert('time_entries', TimeEntryModel(
      projectId: p1Id,
      projectName: 'Mobile App Development',
      projectColor: '0xFF6C5CE7',
      taskName: 'Code Review',
      startTime: yesterday.subtract(const Duration(hours: 6)),
      endTime: yesterday.subtract(const Duration(hours: 1)),
      durationMinutes: 300,
      breakMinutes: 15,
      hourlyRate: 45.0,
      isBillable: true,
      isOvertime: true,
      overtimeMultiplier: 1.5,
      notes: 'Implemented database service and models',
    ).toMap());

    await db.insert('time_entries', TimeEntryModel(
      projectId: p2Id,
      projectName: 'UI/UX Design Strategy',
      projectColor: '0xFF00CEC9',
      taskName: 'Wireframing',
      startTime: now.subtract(const Duration(hours: 4)),
      endTime: now.subtract(const Duration(hours: 1)),
      durationMinutes: 180,
      breakMinutes: 0,
      hourlyRate: 35.0,
      isBillable: false,
      notes: 'Design review and team meeting',
    ).toMap());
  }

  // --- PROJECTS CRUD ---
  Future<List<ProjectModel>> getProjects() async {
    final db = await database;
    final maps = await db.query('projects', orderBy: 'id DESC');
    return maps.map((m) => ProjectModel.fromMap(m)).toList();
  }

  Future<int> insertProject(ProjectModel project) async {
    final db = await database;
    return await db.insert('projects', project.toMap());
  }

  Future<int> updateProject(ProjectModel project) async {
    final db = await database;
    return await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'project_id = ?', whereArgs: [id]);
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // --- TASKS CRUD ---
  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'project_id = ?', whereArgs: [projectId]);
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // --- TIME ENTRIES CRUD ---
  Future<List<TimeEntryModel>> getAllTimeEntries() async {
    final db = await database;
    final maps = await db.query('time_entries', orderBy: 'start_time DESC');
    return maps.map((m) => TimeEntryModel.fromMap(m)).toList();
  }

  Future<int> insertTimeEntry(TimeEntryModel entry) async {
    final db = await database;
    return await db.insert('time_entries', entry.toMap());
  }

  Future<int> updateTimeEntry(TimeEntryModel entry) async {
    final db = await database;
    return await db.update(
      'time_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteTimeEntry(int id) async {
    final db = await database;
    return await db.delete('time_entries', where: 'id = ?', whereArgs: [id]);
  }

  // --- SETTINGS CRUD ---
  Future<UserSettingsModel> getUserSettings() async {
    final db = await database;
    final maps = await db.query('user_settings', where: 'id = 1');
    if (maps.isNotEmpty) {
      return UserSettingsModel.fromMap(maps.first);
    }
    return UserSettingsModel();
  }

  Future<int> updateUserSettings(UserSettingsModel settings) async {
    final db = await database;
    return await db.update(
      'user_settings',
      settings.toMap(),
      where: 'id = 1',
    );
  }
}
