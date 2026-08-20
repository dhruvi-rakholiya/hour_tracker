import 'package:get/get.dart';
import 'package:hour_tracker/models/project_model.dart';
import 'package:hour_tracker/models/task_model.dart';
import 'package:hour_tracker/services/database_service.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';

class ProjectController extends GetxController {
  List<ProjectModel> projects = [];
  Map<int, List<TaskModel>> projectTasks = {};
  bool isLoading = false;
  ProjectModel? selectedProject;
  TaskModel? selectedTask;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    isLoading = true;
    update();

    try {
      projects = await DatabaseService.instance.getProjects();
      if (projects.isNotEmpty) {
        if (selectedProject == null) {
          selectedProject = projects.first;
        } else {
          final found = projects.firstWhereOrNull((p) => p.id == selectedProject!.id);
          selectedProject = found ?? projects.first;
        }
        await loadTasksForProject(selectedProject!.id!);
      } else {
        selectedProject = null;
        selectedTask = null;
      }
    } catch (e) {
      showToast("Error loading projects");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loadTasksForProject(int projectId) async {
    final tasks = await DatabaseService.instance.getTasksByProject(projectId);
    projectTasks[projectId] = tasks;
    if (selectedProject?.id == projectId && tasks.isNotEmpty) {
      selectedTask = tasks.first;
    }
    update();
  }

  void selectProject(ProjectModel project) {
    selectedProject = project;
    if (project.id != null) {
      loadTasksForProject(project.id!);
    } else {
      selectedTask = null;
    }
    update();
  }

  void selectTask(TaskModel task) {
    selectedTask = task;
    update();
  }

  Future<bool> addProject(ProjectModel project) async {
    if (project.name.trim().isEmpty) {
      showToast("Project name cannot be empty");
      return false;
    }

    try {
      await DatabaseService.instance.insertProject(project);
      await loadProjects();

      showToast("Project created successfully");
      return true;
    } catch (e) {
      showToast("Failed to create project");
      return false;
    }
  }

  Future<bool> updateProject(ProjectModel project) async {
    if (project.name.trim().isEmpty) {
      showToast("Project name cannot be empty");
      return false;
    }

    try {
      await DatabaseService.instance.updateProject(project);
      await loadProjects();
      showToast("Project updated");
      return true;
    } catch (e) {
      showToast("Failed to update project");
      return false;
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await DatabaseService.instance.deleteProject(id);
      if (selectedProject?.id == id) {
        selectedProject = null;
        selectedTask = null;
      }
      await loadProjects();
      showToast("Project deleted");
    } catch (e) {
      showToast("Failed to delete project");
    }
  }

  Future<void> addTask(int projectId, String taskName) async {
    if (taskName.trim().isEmpty) {
      showToast("Task name cannot be empty");
      return;
    }

    final task = TaskModel(projectId: projectId, name: taskName.trim());
    await DatabaseService.instance.insertTask(task);
    await loadTasksForProject(projectId);
    showToast("Task added");
  }

  Future<void> deleteTask(int taskId, int projectId) async {
    await DatabaseService.instance.deleteTask(taskId);
    await loadTasksForProject(projectId);
    showToast("Task deleted");
  }
}
