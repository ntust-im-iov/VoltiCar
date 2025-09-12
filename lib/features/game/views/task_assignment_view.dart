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
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.95,
        child: Consumer<TaskAssignmentViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isTaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.isTaskError != null) {
              return Center(child: Text('錯誤: ${viewModel.isTaskError}'));
            }

            return Column(
              children: [
                // 頂部導覽列
                Container(
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF42A5F5), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 10,),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '任務委託',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                
                // 任務分類標籤
                Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF42A5F5), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (viewModel.isMainTask) {
                              setState(() {
                                viewModel.toggleTaskType();
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final mode = viewModel.isMainTask ? 'story' : 'daily';
                                viewModel.fetchTasks(mode);
                              });
                            }
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                              color: !viewModel.isMainTask 
                                  ? const Color(0xFF42A5F5) 
                                  : Colors.transparent,
                              border: const Border(
                                right: BorderSide(color: Color(0xFF42A5F5), width: 1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '日常任務',
                                style: TextStyle(
                                  color: !viewModel.isMainTask 
                                      ? Colors.white 
                                      : const Color(0xFF42A5F5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!viewModel.isMainTask) {
                              setState(() {
                                viewModel.toggleTaskType();
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final mode = viewModel.isMainTask ? 'story' : 'daily';
                                viewModel.fetchTasks(mode);
                              });
                            }
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                              color: viewModel.isMainTask 
                                  ? const Color(0xFF42A5F5) 
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '主線任務',
                                style: TextStyle(
                                  color: viewModel.isMainTask 
                                      ? Colors.white 
                                      : const Color(0xFF42A5F5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 主要內容區域
                Expanded(
                  child: Row(
                    children: [
                      // 左側任務列表
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // 委託任務區域
                            Container(
                              height: 30,
                              color: const Color(0xFF2A2A2A),
                              child: const Center(
                                child: Text(
                                  '委託任務',
                                  style: TextStyle(
                                    color: Color(0xFF42A5F5), 
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: const Color(0xFF1A1A1A),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _getAllTasks(viewModel).length,
                                  itemBuilder: (context, index) {
                                    final task = _getAllTasks(viewModel)[index];
                                    final isAccepted = viewModel.acceptedTasks.any((acceptedTask) => 
                                        acceptedTask.taskId == task.taskId);
                                    return _buildTaskCard(task, viewModel, isAccepted);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 右側任務詳情和操作按鈕
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            border: Border(
                              left: BorderSide(color: Color(0xFF42A5F5), width: 1),
                            ),
                          ),
                          child: Column(
                            children: [
                              // 任務詳情區域
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: viewModel.selectedTask != null
                                      ? _buildTaskDetails(viewModel.selectedTask!)
                                      : const Center(
                                          child: Text(
                                            '選擇一個任務查看詳情',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              
                              // 操作按鈕區域
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF42A5F5), width: 1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // 接取任務按鈕
                                    Expanded(
                                      child: SizedBox(
                                        height: 45,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF42A5F5),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: _canAcceptTask(viewModel)
                                              ? () => _handleAcceptTask(context, viewModel)
                                              : null,
                                          child: viewModel.isTaskLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : const Text('接取任務', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // 放棄任務按鈕
                                    Expanded(
                                      child: SizedBox(
                                        height: 45,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: _canAbandonTask(viewModel)
                                              ? () => _handleAbandonTask(context, viewModel)
                                              : null,
                                          child: const Text('放棄任務', style: TextStyle(fontSize: 14)),
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
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<dynamic> _getAllTasks(TaskAssignmentViewModel viewModel) {
    // 將可用任務和當前類型的已接受任務合併，並去除重複
    List<dynamic> allTasks = List.from(viewModel.availableTasks);
    
    // 當前任務模式
    final currentMode = viewModel.isMainTask ? 'story' : 'daily';
    
    // 添加不在可用任務列表中但屬於當前類型的已接受任務
    for (var acceptedTask in viewModel.acceptedTasks) {
      bool alreadyExists = allTasks.any((task) => task.taskId == acceptedTask.taskId);
      
      // 檢查任務類型是否匹配當前模式
      bool isCorrectType = acceptedTask.mode.toLowerCase() == currentMode;
      
      if (!alreadyExists && isCorrectType) {
        allTasks.add(acceptedTask);
      }
    }
    
    return allTasks;
  }

  Widget _buildTaskCard(task, TaskAssignmentViewModel viewModel, bool isAccepted) {
    final isSelected = viewModel.selectedTask?.taskId == task.taskId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF42A5F5).withValues(alpha: 0.3) : const Color(0xFF2A2A2A),
        border: Border.all(
          color: isSelected ? const Color(0xFF42A5F5) : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => viewModel.selectTask(task),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 左側任務內容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 任務標題
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 任務描述
                    Text(
                      task.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 等級限制 (如果有的話)
                    if (task.requirements.containsKey('level'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '需要等級: ${task.requirements['level']}',
                          style: const TextStyle(
                            color: Color(0xFF42A5F5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // 右側狀態標籤
              if (isAccepted)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Text(
                    '已接受',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDetails(task) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任務標題
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 任務要求
          if (task.requirements.isNotEmpty) ...[
            const Text(
              '任務要求',
              style: TextStyle(
                color: Color(0xFF42A5F5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...task.requirements.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${_formatRequirement(entry.key, entry.value)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
          
          // 任務獎勵
          if (task.rewards.isNotEmpty) ...[
            const Text(
              '任務獎勵',
              style: TextStyle(
                color: Color(0xFF42A5F5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...task.rewards.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${_formatReward(entry.key, entry.value)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  String _formatRequirement(String key, dynamic value) {
    switch (key) {
      case 'level':
        return '等級需求: $value';
      case 'prerequisite_tasks':
        return '前置任務: ${value.join(', ')}';
      default:
        return '$key: $value';
    }
  }

  String _formatReward(String key, dynamic value) {
    switch (key) {
      case 'exp':
        return '經驗值: $value';
      case 'gold':
        return '金幣: $value';
      case 'items':
        return '道具: ${value.join(', ')}';
      default:
        return '$key: $value';
    }
  }

  bool _canAcceptTask(TaskAssignmentViewModel viewModel) {
    return !viewModel.isTaskLoading &&
           viewModel.selectedTask != null &&
           !viewModel.acceptedTasks.any((task) => 
               task.taskId == viewModel.selectedTask!.taskId);
  }

  bool _canAbandonTask(TaskAssignmentViewModel viewModel) {
    return !viewModel.isTaskLoading &&
           viewModel.selectedTask != null &&
           viewModel.acceptedTasks.any((task) => 
               task.taskId == viewModel.selectedTask!.taskId) &&
           viewModel.canAbandonTask(viewModel.selectedTask!);
  }

  Future<void> _handleAcceptTask(BuildContext context, TaskAssignmentViewModel viewModel) async {
    await viewModel.acceptTask();
    if (!context.mounted) return;
    
    if (viewModel.acceptTaskError != null) {
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

  Future<void> _handleAbandonTask(BuildContext context, TaskAssignmentViewModel viewModel) async {
    await viewModel.abandonTask();
    if (!context.mounted) return;
    
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
}