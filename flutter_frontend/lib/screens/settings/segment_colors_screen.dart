import 'package:flutter/material.dart';
import '../../core/utils/colors.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SegmentColorsScreen extends StatefulWidget {
  const SegmentColorsScreen({super.key});

  @override
  _SegmentColorsScreenState createState() => _SegmentColorsScreenState();
}

class _SegmentColorsScreenState extends State<SegmentColorsScreen> {
  late Color _segmentAColor;
  late Color _segmentBColor;
  late Color _segmentCColor;
  late Color _segmentDColor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    await SegmentColors.loadColors();
    setState(() {
      _segmentAColor = SegmentColors.segmentA;
      _segmentBColor = SegmentColors.segmentB;
      _segmentCColor = SegmentColors.segmentC;
      _segmentDColor = SegmentColors.segmentD;
      _isLoading = false;
    });
  }

  Future<void> _pickColor(Color currentColor, ValueChanged<Color> onColorChanged) async {
    Color pickedColor = currentColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wybierz kolor'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              pickedColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    onColorChanged(pickedColor);
  }

  void _saveColors() async {
    SegmentColors.updateColors(
      segmentAColor: _segmentAColor,
      segmentBColor: _segmentBColor,
      segmentCColor: _segmentCColor,
      segmentDColor: _segmentDColor,
    );
    await SegmentColors.saveColors();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kolory zostały zapisane')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
            title: const Text('Segment A'),
            trailing: CircleAvatar(
              backgroundColor: _segmentAColor,
            ),
            onTap: () => _pickColor(_segmentAColor, (color) {
              setState(() {
                _segmentAColor = color;
              });
            }),
          ),
          ListTile(
            title: const Text('Segment B'),
            trailing: CircleAvatar(
              backgroundColor: _segmentBColor,
            ),
            onTap: () => _pickColor(_segmentBColor, (color) {
              setState(() {
                _segmentBColor = color;
              });
            }),
          ),
          ListTile(
            title: const Text('Segment C'),
            trailing: CircleAvatar(
              backgroundColor: _segmentCColor,
            ),
            onTap: () => _pickColor(_segmentCColor, (color) {
              setState(() {
                _segmentCColor = color;
              });
            }),
          ),
          ListTile(
            title: const Text('Segment D'),
            trailing: CircleAvatar(
              backgroundColor: _segmentDColor,
            ),
            onTap: () => _pickColor(_segmentDColor, (color) {
              setState(() {
                _segmentDColor = color;
              });
            }),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveColors,
            child: const Text('Zapisz kolory'),
          ),
        ],
      ),
    );
  }
}
