import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool done;
  final ValueChanged<bool> onChanged;
  final Widget? expandedChild;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.done,
    required this.onChanged,
    this.expandedChild,
  });

  @override
  Widget build(BuildContext context) {
    final color = done
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(!done),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    _CheckCircle(done: done),
                  ],
                ),
                if (expandedChild != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  expandedChild!,
                ],
              ],
            ),
          ),
        ),
      ).animate(target: done ? 1 : 0).scaleXY(
            begin: 1,
            end: 1.01,
            duration: 180.ms,
          ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool done;
  const _CheckCircle({required this.done});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? primary : Colors.transparent,
        border: Border.all(
          color: done ? primary : Theme.of(context).dividerColor,
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }
}
