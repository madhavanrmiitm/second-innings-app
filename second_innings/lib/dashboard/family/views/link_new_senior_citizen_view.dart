import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/family_home.dart';
import 'package:second_innings/services/family_service.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: colorScheme.primaryContainer
                                .withValues(alpha: 0.4),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 60,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Implement image picker logic
                            },
                            icon: const Icon(
                              Icons.upload_file_outlined,
                              size: 20,
                            ),
                            label: const Text("Upload photo"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Registered Gmail ID',
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'Enter the Gmail ID of the senior citizen',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required.';
                        }
                        if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _relationController,
                      decoration: InputDecoration(
                        labelText: 'Relationship',
                        prefixIcon: const Icon(Icons.family_restroom_outlined),
                        hintText: 'e.g. Father, Mother, Grandfather',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Relationship is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _linkSeniorCitizen();
                        }
                      },
                      icon: const Icon(Icons.link_rounded),
                      label: const Text('Link Senior Citizen'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
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

  Future<void> _linkSeniorCitizen() async {
    try {
      final response = await FamilyService.linkSeniorCitizen(
        seniorCitizenEmail: _emailController.text,
        relation: _relationController.text,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senior citizen linked successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FamilyHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to link senior citizen'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error linking senior citizen: $e')),
      );
    }
  }
}

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
