// Chapter 03 — Layout Examples
// This file shows common layout patterns in Flutter

import 'package:flutter/material.dart';

// ─── Profile Card ─────────────────────────────────

class ProfileCard extends StatelessWidget {
  final String name;
  final String title;
  final String avatarUrl;
  final int followers;
  final int following;
  final int posts;

  const ProfileCard({
    super.key,
    required this.name,
    required this.title,
    required this.avatarUrl,
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(height: 12),

            // Name
            Text(name, style: theme.textTheme.titleLarge),
            Text(title, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(label: 'Posts', value: posts),
                _StatColumn(label: 'Followers', value: followers),
                _StatColumn(label: 'Following', value: following),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ─── Responsive Layout ─────────────────────────────

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Layout')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width >= 1200) {
            // Desktop: 3 columns + sidebar
            return Row(
              children: [
                // Sidebar
                SizedBox(
                  width: 250,
                  child: _buildSidebar(),
                ),
                const VerticalDivider(width: 1),
                // Main content — 3 columns
                Expanded(
                  child: _buildGrid(crossAxisCount: 3),
                ),
              ],
            );
          } else if (width >= 600) {
            // Tablet: 2 columns
            return _buildGrid(crossAxisCount: 2);
          } else {
            // Mobile: 1 column
            return _buildGrid(crossAxisCount: 1);
          }
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return ListView(
      children: const [
        DrawerHeader(child: Text('Menu')),
        ListTile(leading: Icon(Icons.home), title: Text('Home')),
        ListTile(leading: Icon(Icons.search), title: Text('Search')),
        ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
      ],
    );
  }

  Widget _buildGrid({required int crossAxisCount}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Card(
          child: Center(
            child: Text('Item ${index + 1}'),
          ),
        );
      },
    );
  }
}

// ─── Custom ScrollView Example ──────────────────────

class CustomScrollViewExample extends StatelessWidget {
  const CustomScrollViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Scroll Demo'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('List Item ${index + 1}'),
                    subtitle: const Text('Subtitle text'),
                  ),
                ),
                childCount: 10,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => Card(
                  color: Colors.primaries[index % Colors.primaries.length].shade100,
                  child: Center(child: Text('Grid ${index + 1}')),
                ),
                childCount: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
