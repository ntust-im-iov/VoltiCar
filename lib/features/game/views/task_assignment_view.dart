import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volticar_app/features/game/viewmodels/task_assignment_viewmodel.dart';
import 'package:volticar_app/shared/widgets/top_notification.dart';

class TaskAssignmentView extends StatefulWidget {
  const TaskAssignmentView({super.key});

  @override
  State<TaskAssignmentView> createState() => _TaskAssignmentViewState();
}

class _TaskAssignmentViewState extends State<TaskAssignmentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TaskAssignmentViewModel>(context, listen: false);
      // 獲取當前應該載入的任務模式
      final mode = viewModel.isMainTask ? 'daily' : 'story';
      viewModel.fetchTasks(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 38, 36, 36),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF42A5F5), width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Consumer<TaskAssignmentViewModel>(
            builder: (context, viewModel, child) {
          if (viewModel.isTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.isTaskError != null) {
            return Center(child: Text('錯誤: ${viewModel.isTaskError}'));
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('委託任務',
                        style:
                            TextStyle(color: Color(0xFF42A5F5), fontSize: 16)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.availableTasks.length,
                        itemBuilder: (context, index) {
                          final task = viewModel.availableTasks[index];
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              color:
                                  viewModel.selectedTask?.taskId == task.taskId
                                      ? Colors.blue.withOpacity(0.5)
                                      : null,
                              child: ListTile(
                                title: Text(task.title),
                                onTap: () => viewModel.selectTask(task),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Text('已接受任務',
                        style:
                            TextStyle(color: Color(0xFF42A5F5), fontSize: 16)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.acceptedTasks.length,
                        itemBuilder: (context, index) {
                          final task = viewModel.acceptedTasks[index];
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              color:
                                  viewModel.selectedTask?.taskId == task.taskId
                                      ? Colors.blue.withOpacity(0.5)
                                      : null,
                              child: ListTile(
                                title: Text(task.title),
                                onTap: () => viewModel.selectTask(task),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(viewModel.taskDescription,
                          style: TextStyle(
                              color: Color(0xFF42A5F5), fontSize: 20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: viewModel.isTaskLoading
                                ? null
                                : (viewModel.selectedTask != null &&
                                    !viewModel.acceptedTasks.any((task) =>
                                        task.taskId ==
                                        viewModel.selectedTask!.taskId)
                                    ? () async {
                                        await viewModel.acceptTask();
                                        if (viewModel.acceptTaskError != null) {
                                          // 檢查是否為等級限制錯誤
                                          bool isLevelError = viewModel.acceptTaskError!.contains('需要等級');
                                          
                                          TopNotificationUtils.showTopNotification(
                                            context,
                                            message: viewModel.acceptTaskError!,
                                            isLevelError: isLevelError,
                                          );
                                        } else if (viewModel.isTaskSuccess) {
                                          TopNotificationUtils.showTopNotification(
                                            context,
                                            message: '成功接取任務！',
                                            isSuccess: true,
                                          );
                                        }
                                      }
                                    : null),
                            child: viewModel.isTaskLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('接取任務'),
                          ),
                          const SizedBox(width: 10),
                          Tooltip(
                            message: viewModel.selectedTask != null && 
                                     viewModel.acceptedTasks.any((task) =>
                                        task.taskId == viewModel.selectedTask!.taskId) && 
                                     !viewModel.canAbandonTask(viewModel.selectedTask!)
                                     ? '故事模式任務不可放棄'
                                     : '放棄選中的任務',
                            child: ElevatedButton(
                              onPressed: viewModel.isTaskLoading
                                  ? null
                                  : (viewModel.selectedTask != null &&
                                      viewModel.acceptedTasks.any((task) =>
                                          task.taskId ==
                                          viewModel.selectedTask!.taskId) &&
                                      // 檢查是否為可放棄的任務（非故事模式）
                                      viewModel.canAbandonTask(viewModel.selectedTask!)
                                      ? () async {
                                          await viewModel.abandonTask();
                                          if (viewModel.acceptTaskError != null) {
                                            TopNotificationUtils.showTopNotification(
                                              context,
                                              message: viewModel.acceptTaskError!,
                                              isLevelError: false,
                                            );
                                          } else if (viewModel.isTaskSuccess) {
                                            TopNotificationUtils.showTopNotification(
                                              context,
                                              message: '任務已成功放棄',
                                              isSuccess: true,
                                            );
                                          }
                                        }
                                      : null),
                              child: viewModel.isTaskLoading && viewModel.selectedTask != null &&
                                     viewModel.acceptedTasks.any((task) =>
                                        task.taskId == viewModel.selectedTask!.taskId)
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('放棄任務'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                viewModel.toggleTaskType(); // 切換狀態
                              });
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) {
                                // 注意這裡的邏輯：切換後的狀態來決定載入哪種任務
                                final mode = viewModel.isMainTask ? 'story' : 'daily';
                                Provider.of<TaskAssignmentViewModel>(context,
                                        listen: false)
                                    .fetchTasks(mode);
                              });
                            },
                            child: Text(viewModel.isMainTask ? '主線任務' : '日常任務'),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
