// import 'package:flutter/material.dart';
// import 'package:second_innings/dashboard/family/family_home.dart';
// import 'package:second_innings/dashboard/family/views/caregivers_view.dart';
// import 'package:second_innings/dashboard/family/views/notifications_view.dart';
// import 'package:second_innings/dashboard/family/views/senior_citizens_view.dart';

// class LinkNewSeniorCitizenPage extends StatefulWidget {
//   const LinkNewSeniorCitizenPage({super.key});

//   @override
//   State<LinkNewSeniorCitizenPage> createState() => _LinkNewSeniorCitizenPageState();
// }

// class _LinkNewSeniorCitizenPageState extends State<LinkNewSeniorCitizenPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _relationController = TextEditingController();

//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const FamilyHomePage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar.large(
//             pinned: true,
//             floating: true,
//             backgroundColor: colorScheme.primaryContainer.withAlpha(204),
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               centerTitle: true,
//               titlePadding: const EdgeInsets.only(bottom: 16),
//               title: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'New Member',
//                     style: textTheme.titleLarge?.copyWith(
//                       color: colorScheme.onPrimaryContainer,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Link a new senior citizen',
//                     style: textTheme.bodySmall?.copyWith(
//                       color: colorScheme.onPrimaryContainer,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: GestureDetector(
//                         onTap: () {
//                           // TODO: Implement image picker logic
//                         },
//                         child: CircleAvatar(
//                           radius: 40,
//                           backgroundColor: colorScheme.primaryContainer.withAlpha(100),
//                           child: const Icon(Icons.person, size: 40),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email ID',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter an email';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     TextFormField(
//                       controller: _relationController,
//                       decoration: const InputDecoration(
//                         labelText: 'Relation',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter relation';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: colorScheme.primary,
//                           foregroundColor: colorScheme.onPrimary,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         icon: const Icon(Icons.link),
//                         label: const Text('Link Senior Citizen'),
//                         onPressed: () {
//                           if (_formKey.currentState?.validate() ?? false) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Senior citizen linked!')),
//                             );
//                             Navigator.pop(context);
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: _onItemTapped,
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.groups_outlined),
//             label: 'Senior Citizens',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.notifications_outlined),
//             label: 'Notifications',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.search),
//             label: 'Caregivers',
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _relationController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/family_home.dart';

class LinkNewSeniorCitizenPage extends StatefulWidget {
  final int selectedIndex;
  const LinkNewSeniorCitizenPage({super.key, this.selectedIndex = 0});

  @override
  State<LinkNewSeniorCitizenPage> createState() =>
      _LinkNewSeniorCitizenPageState();
}

class _LinkNewSeniorCitizenPageState extends State<LinkNewSeniorCitizenPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

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
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Member',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Link a new senior citizen',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundColor: colorScheme.primaryContainer
                                .withAlpha(100),
                            child: const Icon(Icons.person, size: 80),
                          ),
                          Positioned(
                            bottom: -20,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement image picker logic
                              },
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text("Upload member's headshot"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer
                                    .withAlpha(40),
                                foregroundColor: colorScheme.onSurface,
                                textStyle: textTheme.bodySmall,
                                elevation: 1,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(0, 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _relationController,
                      decoration: const InputDecoration(
                        labelText: 'Relation',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter relation';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(
                                context,
                              ).floatingActionButtonTheme.backgroundColor ??
                              colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.link),
                        label: const Text('Link Senior Citizen'),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Senior citizen linked!'),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FamilyHomePage(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
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
            MaterialPageRoute(builder: (context) => const FamilyHomePage()),
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

  @override
  void dispose() {
    _emailController.dispose();
    _relationController.dispose();
    super.dispose();
  }
}
