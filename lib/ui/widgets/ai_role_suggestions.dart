import 'package:flutter/material.dart';
import 'package:career_path_finder/models/enum.dart';
import 'package:career_path_finder/models/user_profile.dart';
import 'package:career_path_finder/services/ai_service.dart';
import 'package:career_path_finder/ui/goal_setup_screen.dart';
import 'package:career_path_finder/ui/widgets/path_card.dart';

class AiRoleSuggestionsSection extends StatefulWidget {
  final CareerDomain domain;
  final UserProfile profile;

  const AiRoleSuggestionsSection({
    super.key,
    required this.domain,
    required this.profile,
  });

  @override
  State<AiRoleSuggestionsSection> createState() =>
      _AiRoleSuggestionsSectionState();
}

class _AiRoleSuggestionsSectionState extends State<AiRoleSuggestionsSection> {
  late Future<List<AiRoleSuggestion>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _suggestionsFuture = AiService.suggestRoles(widget.domain, widget.profile);
  }

  void _regenerate() {
    setState(() {
      _suggestionsFuture = AiService.suggestRoles(
        widget.domain,
        widget.profile,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder<List<AiRoleSuggestion>>(
          future: _suggestionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'Finding strong career matches...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Could not reach the AI service. Please check your connection or API key.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _regenerate,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            final suggestions = snapshot.data ?? [];

            if (suggestions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No suitable paths found for this domain.'),
                ),
              );
            }

            return Column(
              children: [
                ...suggestions.map(
                  (role) => PathCard(
                    role: role,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GoalSetupScreen(
                            role: role,
                            domain: widget.domain,
                            profile: widget.profile,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                _ActionButton(
                  label: 'Regenerate paths',
                  isOutline: true,
                  onPressed: _regenerate,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "I don't like any of these",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isOutline;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    this.isOutline = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: isOutline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: BorderSide(
                  color: cs.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }
}
