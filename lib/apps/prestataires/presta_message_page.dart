import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/chat/chat_provider.dart';
import 'package:demarcheur_app/providers/presta/presta_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demarcheur_app/apps/prestataires/chat_page.dart';

class PrestaMessagePage extends StatefulWidget {
  const PrestaMessagePage({super.key});

  @override
  State<PrestaMessagePage> createState() => _PrestaMessagePageState();
}

class _PrestaMessagePageState extends State<PrestaMessagePage> {
  ConstColors colors = ConstColors();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final jobs = context.read<PrestaProvider>().allJobs;
      context.read<ChatProvider>().seedFromJobs(jobs);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    var conversations = context.watch<ChatProvider>().conversations;
    if (query.isNotEmpty) {
      conversations = conversations
          .where(
            (c) =>
                c.presta.companyName.toLowerCase().contains(query) ||
                c.presta.title.toLowerCase().contains(query),
          )
          .toList();
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.deferToChild,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: CustomScrollView(
          slivers: [
            Header(auto: false),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Rechercher une conversation...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.secondary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.tertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.primary),
                    ),
                  ),
                ),
              ),
            ),
            if (conversations.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "Aucune conversation",
                      style: TextStyle(color: colors.primary),
                    ),
                  ),
                ),
              )
            else
              SliverList.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: colors.tertiary, indent: 76),
                itemBuilder: (context, index) {
                  final c = conversations[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(presta: c.presta),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          c.presta.imageUrl.first,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.presta.companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.timeLabel,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (c.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${c.unreadCount}",
                                style: TextStyle(
                                  color: colors.bg,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
