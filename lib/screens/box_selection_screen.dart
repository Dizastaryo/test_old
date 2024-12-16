import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/box_provider.dart';
import '../models/box_model.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'box_screen.dart'; // Импортируем страницу BoxScreen

class BoxSelectionScreen extends StatefulWidget {
  const BoxSelectionScreen({super.key});

  @override
  State<BoxSelectionScreen> createState() => _BoxSelectionScreenState();
}

class _BoxSelectionScreenState extends State<BoxSelectionScreen>
    with TickerProviderStateMixin {
  BoxModel? selectedBox;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxes = Provider.of<BoxProvider>(context).boxes;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Карта склада'),
          backgroundColor: const Color(0xFF6C9942),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(60.0), // Увеличиваем высоту для вкладок
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Прокрутка по горизонтали
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                tabs: const [
                  Tab(text: 'XXS'),
                  Tab(text: 'XS'),
                  Tab(text: 'S'),
                  Tab(text: 'M'),
                  Tab(text: 'L'),
                  Tab(text: 'XL'),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBoxGrid(context, boxes, BoxType.xxs),
                  _buildBoxGrid(context, boxes, BoxType.xs),
                  _buildBoxGrid(context, boxes, BoxType.s),
                  _buildBoxGrid(context, boxes, BoxType.m),
                  _buildBoxGrid(context, boxes, BoxType.l),
                  _buildBoxGrid(context, boxes, BoxType.xl),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: selectedBox != null
                    ? ModelViewer(
                        key: ValueKey(selectedBox
                            ?.id), // Принудительное обновление виджета
                        src:
                            "assets/3d_models/${selectedBox!.type.name.toUpperCase()}.glb",
                        autoRotate: true,
                        cameraControls: true,
                        alt:
                            "3D модель ${selectedBox!.type.name.toUpperCase()}",
                      )
                    : Center(
                        child: Text(
                          'Выберите бокс',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ),
              ),
            ),
            if (selectedBox != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoxScreen(box: selectedBox!),
                      ),
                    );
                  },
                  child: const Text(
                    'Арендовать',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C9942),
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxGrid(
      BuildContext context, List<BoxModel> boxes, BoxType type) {
    final filteredBoxes = boxes.where((box) => box.type == type).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 2.0,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: filteredBoxes.length,
          itemBuilder: (context, index) {
            final box = filteredBoxes[index];
            return GestureDetector(
              onTap: () {
                if (box.isAvailable) {
                  setState(() {
                    selectedBox = box; // Обновляем выбранную коробку
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: box.isAvailable ? const Color(0xFF6C9942) : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  border: selectedBox == box
                      ? Border.all(color: Colors.black, width: 4)
                      : Border.all(color: Colors.transparent, width: 2),
                  boxShadow: [
                    if (selectedBox == box)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    box.id,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
