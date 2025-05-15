import 'package:flutter/material.dart';
import 'package:moments_diary/utils.dart';

class ReflectionPromptsScreen extends StatefulWidget {
  const ReflectionPromptsScreen({super.key});

  @override
  State<ReflectionPromptsScreen> createState() =>
      _ReflectionPromptsScreenState();
}

class _ReflectionPromptsScreenState extends State<ReflectionPromptsScreen> {
  final List<TextEditingController> _controllers = [];
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _initializePrompts();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializePrompts() async {
    setState(() {
      _isLoading = true;
    });
    final prompts = await getReflectionPrompts();
    setState(() {
      _controllers.clear();
      if (prompts.isNotEmpty) {
        _controllers.addAll(prompts.map((p) => TextEditingController(text: p)));
      } else {
        _controllers.add(TextEditingController());
      }
      _isLoading = false;
    });
  }

  void _addPrompt() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _deletePrompt(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _savePrompts() {
    final prompts = _controllers.map((c) => c.text).toList();
    saveReflectionPrompts(prompts);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (res, data) async {
        if (res) {
          _savePrompts();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reflection Prompts'),
          actions: [
            IconButton(
              onPressed: _addPrompt,
              icon: const Icon(Icons.add),
              tooltip: 'Add Prompt',
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _controllers.length,
                          itemBuilder: (context, index) {
                            return PromptRow(
                              controller: _controllers[index],
                              label: 'Prompt ${index + 1}',
                              onDelete: () => _deletePrompt(index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class PromptRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onDelete;

  const PromptRow({
    super.key,
    required this.controller,
    required this.label,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
