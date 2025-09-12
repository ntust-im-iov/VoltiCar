import 'package:flutter/material.dart';

class PlayerDataDisplayView extends StatelessWidget {
  const PlayerDataDisplayView({Key? key}) : super(key: key);

  void showPlayerDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              const Color.fromARGB(255, 38, 36, 36).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF42A5F5), width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '玩家資料',
                    style: const TextStyle(
                      color: Color(0xFF42A5F5),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // TODO: 在這裡加入玩家資料內容，等待API串接
                const Text(
                  '玩家名稱：XXX',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 12),
                const Text(
                  '等級：10',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 12),
                const Text(
                  '經驗值：12345',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => showPlayerDataDialog(context),
        child: const Text('顯示玩家資料'),
      ),
    );
  }
}
