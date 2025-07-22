import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/features/game/viewmodels/task_assignment_viewmodel.dart';

class TaskAssignmentView extends StatefulWidget {
  const TaskAssignmentView({super.key});

  @override
  State<TaskAssignmentView> createState() => _TaskAssignmentViewState();
}

class _TaskAssignmentViewState extends State<TaskAssignmentView> {
  List<Task> availableTasks = []; // 委託任務列表
  List<Task> acceptedTasks = []; // 已接受任務列表
  String? selectedTask;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Task?> _getTask() {
    final taskAssignmentViewModel =
        Provider.of<TaskAssignmentViewModel>(context, listen: false);
    return taskAssignmentViewModel.taskassignment('daily');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 38, 36, 36).withOpacity(0.5),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF42A5F5), width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('委託任務',
                      style: TextStyle(color: Color(0xFF42A5F5), fontSize: 16)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableTasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Card(
                            color: selectedTask == availableTasks[index]
                                ? Colors.blue.withOpacity(0.5)
                                : null,
                            child: ListTile(
                              title: Text(availableTasks[index].title),
                              onTap: () {
                                setState(() {
                                  selectedTask = selectedTask ==
                                          availableTasks[index].title
                                      ? null
                                      : availableTasks[index].title;
                                });
                              },
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
                  Text('已接受任務',
                      style: TextStyle(color: Color(0xFF42A5F5), fontSize: 16)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: acceptedTasks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Card(
                            color: selectedTask == acceptedTasks[index]
                                ? Colors.blue.withOpacity(0.5)
                                : null,
                            child: ListTile(
                              title: Text(acceptedTasks[index].title),
                              onTap: () {
                                setState(() {
                                  selectedTask =
                                      selectedTask == acceptedTasks[index].title
                                          ? null
                                          : acceptedTasks[index].title;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 移除 Visibility
                        ElevatedButton(
                          onPressed: selectedTask != null &&
                                  !acceptedTasks.contains(selectedTask)
                              ? () {
                                  setState(() {
                                    // acceptedTasks.add(selectedTask!);
                                    availableTasks.remove(selectedTask);
                                    // recordTaskAcceptanceStatus(
                                    //     selectedTask!, true);
                                    // selectedTask = null; // 清除選取
                                  });
                                }
                              : null, // 禁用按鈕如果沒有選取任務
                          child: Text('接取任務'),
                        ),
                        SizedBox(width: 10),
                        // 移除 Visibility
                        ElevatedButton(
                          onPressed: selectedTask != null
                              ? () {
                                  setState(() {
                                    if (!acceptedTasks.contains(selectedTask)) {
                                      availableTasks.remove(selectedTask);
                                    }
                                    acceptedTasks.remove(selectedTask);
                                    // recordTaskAcceptanceStatus(
                                    //     selectedTask!, false);
                                    // selectedTask = null; // 清除選取
                                  });
                                }
                              : null, // 禁用按鈕如果沒有選取任務
                          child: Text('放棄任務'),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// class TaskAssignmentDialog extends StatefulWidget {
//   const TaskAssignmentDialog({Key? key}) : super(key: key);

//   @override
//   State<TaskAssignmentDialog> createState() => _TaskAssignmentDialogState();
// }

// class _TaskAssignmentDialogState extends State<TaskAssignmentDialog> {
//   List<String> availableTasks = []; // 委託任務列表
//   List<String> acceptedTasks = []; // 已接受任務列表
//   String? selectedTask;
//   // bool isTaskAccepted = false; // 移除 isTaskAccepted
//   // bool showAcceptRejectButtons = false; // 移除 showAcceptRejectButtons

//   // API 接口預留
//   Future<List<String>> getAvailableTasks() async {
//     // TODO: 從 API 取得委託任務列表
//     return ["1", "2", "3"];
//   }

//   Future<List<String>> getAcceptedTasks() async {
//     // TODO: 從 API 取得已接受任務列表
//     return [];
//   }

//   // 記錄任務接取狀態
//   void recordTaskAcceptanceStatus(String task, bool accepted) {
//     // TODO: 將任務接取狀態回傳給 API
//     print('任務 $task 接取狀態：$accepted');
//   }

//   // 更新任務視窗
//   Future<void> updateTaskLists() async {
//     availableTasks = await getAvailableTasks();
//     acceptedTasks = await getAcceptedTasks();
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     updateTaskLists();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: const Color.fromARGB(255, 38, 36, 36).withOpacity(0.5),
//       shape: RoundedRectangleBorder(
//         side: BorderSide(color: Color(0xFF42A5F5), width: 2),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.8,
//         height: MediaQuery.of(context).size.height * 0.8,
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 children: [
//                   Text('委託任務',
//                       style: TextStyle(color: Color(0xFF42A5F5), fontSize: 16)),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: availableTasks.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Card(
//                             color: selectedTask == availableTasks[index]
//                                 ? Colors.blue.withOpacity(0.5)
//                                 : null,
//                             child: ListTile(
//                               title: Text(availableTasks[index]),
//                               onTap: () {
//                                 setState(() {
//                                   selectedTask =
//                                       selectedTask == availableTasks[index]
//                                           ? null
//                                           : availableTasks[index];
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 children: [
//                   Text('已接受任務',
//                       style: TextStyle(color: Color(0xFF42A5F5), fontSize: 16)),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: acceptedTasks.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Card(
//                             color: selectedTask == acceptedTasks[index]
//                                 ? Colors.blue.withOpacity(0.5)
//                                 : null,
//                             child: ListTile(
//                               title: Text(acceptedTasks[index]),
//                               onTap: () {
//                                 setState(() {
//                                   selectedTask =
//                                       selectedTask == acceptedTasks[index]
//                                           ? null
//                                           : acceptedTasks[index];
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         // 移除 Visibility
//                         ElevatedButton(
//                           onPressed: selectedTask != null &&
//                                   !acceptedTasks.contains(selectedTask)
//                               ? () {
//                                   setState(() {
//                                     acceptedTasks.add(selectedTask!);
//                                     availableTasks.remove(selectedTask);
//                                     recordTaskAcceptanceStatus(
//                                         selectedTask!, true);
//                                     selectedTask = null; // 清除選取
//                                   });
//                                 }
//                               : null, // 禁用按鈕如果沒有選取任務
//                           child: Text('接取任務'),
//                         ),
//                         SizedBox(width: 10),
//                         // 移除 Visibility
//                         ElevatedButton(
//                           onPressed: selectedTask != null
//                               ? () {
//                                   setState(() {
//                                     if (!acceptedTasks.contains(selectedTask)) {
//                                       availableTasks.remove(selectedTask);
//                                     }
//                                     acceptedTasks.remove(selectedTask);
//                                     recordTaskAcceptanceStatus(
//                                         selectedTask!, false);
//                                     selectedTask = null; // 清除選取
//                                   });
//                                 }
//                               : null, // 禁用按鈕如果沒有選取任務
//                           child: Text('放棄任務'),
//                         ),
//                         SizedBox(width: 20),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
