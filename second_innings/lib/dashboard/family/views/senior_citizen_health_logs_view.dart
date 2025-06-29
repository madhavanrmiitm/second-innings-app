import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/family_home.dart';

class SeniorCitizenHealthLogsPage extends StatefulWidget {
  final String name;
  final String relation;
  final int selectedIndex;

  const SeniorCitizenHealthLogsPage({
    super.key,
    required this.name,
    required this.relation,
    this.selectedIndex = 0,
  });

  @override
  State<SeniorCitizenHealthLogsPage> createState() =>
      _SeniorCitizenHealthLogsPageState();
}

class _SeniorCitizenHealthLogsPageState
    extends State<SeniorCitizenHealthLogsPage> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // default to today
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: true,
            elevation: 0,
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.name,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.relation,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical History
                  Text(
                    "Medical History",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: colorScheme.primaryContainer.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "• Diabetes\n• Hypertension\n• Arthritis",
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Regular Medications
                  Text(
                    "Regular Medications",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: colorScheme.primaryContainer.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "• Metformin 500mg daily\n• Amlodipine 5mg daily\n• Paracetamol as needed",
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Logs for ${selectedDate.toLocal().toString().split(' ')[0]}",
                        style: textTheme.bodyLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: colorScheme.primaryContainer.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "• Blood Pressure: 130/85\n• Blood Sugar: 110 mg/dL\n• General Feeling: Good",
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: (int index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyHomePage(selectedIndex: index),
            ),
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Senior Citizens',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Caregivers'),
        ],
      ),
    );
  }
}
