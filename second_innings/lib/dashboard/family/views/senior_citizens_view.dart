import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_details_view.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/family_service.dart';

class SeniorCitizensView extends StatefulWidget {
  const SeniorCitizensView({super.key});

  @override
  State<SeniorCitizensView> createState() => _SeniorCitizensViewState();
}

class _SeniorCitizensViewState extends State<SeniorCitizensView> {
  List<Map<String, dynamic>> _seniorCitizens = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSeniorCitizens();
  }

  Future<void> _loadSeniorCitizens() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await FamilyService.getLinkedSeniorCitizens();

      if (response.statusCode == 200) {
        final seniorCitizensData =
            response.data?['data']?['linked_senior_citizens'] as List?;
        if (seniorCitizensData != null) {
          setState(() {
            _seniorCitizens = seniorCitizensData.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _seniorCitizens = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load senior citizens';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading senior citizens: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: '2nd Innings'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Senior Citizens",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "linked to me.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(_error!, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSeniorCitizens,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList.builder(
                itemCount: _seniorCitizens.length,
                itemBuilder: (context, index) {
                  final citizen = _seniorCitizens[index];
                  final name = citizen['full_name'] ?? '';
                  final relation = citizen['relation'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeniorCitizenDetailPage(
                            name: name,
                            relation: relation,
                            selectedIndex: 0,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: colorScheme.primaryContainer.withAlpha(51),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer
                                  .withAlpha(204),
                              child: Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  relation,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withAlpha(128),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.arrow_upward, size: 20),
                                  Icon(Icons.monitor_heart_outlined, size: 20),
                                  Icon(Icons.square_foot, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
