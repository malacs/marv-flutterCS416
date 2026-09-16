import 'package:flutter/material.dart';
import '../widgets/section_header.dart';

// Activity 1 Screen
class Activity1Screen extends StatefulWidget {
  const Activity1Screen({super.key});

  @override
  State<Activity1Screen> createState() => _Activity1ScreenState();
}

class _Activity1ScreenState extends State<Activity1Screen> {
  int _counter = 0;
  bool _isChecked = false;
  bool _isSwitchOn = true;
  String _selectedFramework = 'Widget Tree';
  String _dynamicStatusText = 'Initial State';
  int _statusClickCount = 0;

  final List<String> _dropdownOptions = const [
    'Widget Tree',
    'StatefulWidget',
    'StatelessWidget',
    'Material 3 UI',
  ];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _toggleStatusText() {
    setState(() {
      _statusClickCount++;
      _dynamicStatusText = 'Updated State (Tapped $_statusClickCount times)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 1: Flutter Portfolio & State Management'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withAlpha(100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon
                    Icon(
                      Icons.widgets_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Expanded(
                      child: Text(
                        'Explore basic Flutter widgets and demonstrate local StatefulWidget lifecycle updates.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 1. Counter Control
            const SectionHeader(
              title: '1. Local Counter Control',
              icon: Icons.add_circle_outline,
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Counter Value',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_counter',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _decrementCounter,
                          icon: const Icon(Icons.remove),
                          label: const Text('Decrement'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _incrementCounter,
                          icon: const Icon(Icons.add),
                          label: const Text('Increment'),
                        ),
                        const SizedBox(width: 8),
                        IconButton.outlined(
                          onPressed: _resetCounter,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset Counter',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Selection & Toggle Controls
            const SectionHeader(
              title: '2. Selection & Toggle Controls',
              icon: Icons.tune,
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                ),
              ),
              child: Column(
                children: [
                  // Checkbox
                  CheckboxListTile(
                    title: const Text('Enable Feature Checkbox'),
                    subtitle: Text(
                      _isChecked ? 'Status: Checked (ON)' : 'Status: Unchecked (OFF)',
                    ),
                    value: _isChecked,
                    onChanged: (val) {
                      setState(() {
                        _isChecked = val ?? false;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  // Switch
                  SwitchListTile(
                    title: const Text('Interactive Switch Toggle'),
                    subtitle: Text(
                      _isSwitchOn ? 'Switch is ACTIVE' : 'Switch is INACTIVE',
                    ),
                    value: _isSwitchOn,
                    onChanged: (val) {
                      setState(() {
                        _isSwitchOn = val;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  // Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Topic:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        DropdownButton<String>(
                          value: _selectedFramework,
                          borderRadius: BorderRadius.circular(12),
                          items: _dropdownOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            if (newVal != null) {
                              setState(() {
                                _selectedFramework = newVal;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Dynamic State Button
            const SectionHeader(
              title: '3. Dynamic State Button',
              icon: Icons.text_fields,
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Displayed Text:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dynamicStatusText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _toggleStatusText,
                      child: const Text('Update Text'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Expandable Details
            const SectionHeader(
              title: '4. Expandable Details',
              icon: Icons.expand_circle_down_outlined,
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                ),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('StatefulWidget Lifecycle Explanation'),
                subtitle: const Text('Tap to expand concepts'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'StatefulWidget maintains state information across user interactions. '
                      'Calling setState() tells the Flutter framework that the internal state of this object '
                      'has changed, causing the framework to schedule a build for this State object.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
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
