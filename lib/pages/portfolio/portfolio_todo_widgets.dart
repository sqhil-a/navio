part of 'portfolio_home.dart';

class _TaskSquareButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _TaskSquareButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_TaskSquareButton> createState() => _TaskSquareButtonState();
}

class _TaskSquareButtonState extends State<_TaskSquareButton> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _canTap => widget.enabled && !widget.isLoading;

  void _setHovered(bool value) {
    if (!mounted) return;
    setState(() {
      _hovered = value;
      if (!value) _pressed = false;
    });
  }

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = _canTap || widget.isLoading;

    return MouseRegion(
      cursor: _canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _canTap ? widget.onTap : null,
        onTapDown: _canTap ? (_) => _setPressed(true) : null,
        onTapUp: _canTap ? (_) => _setPressed(false) : null,
        onTapCancel: _canTap ? () => _setPressed(false) : null,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: NavioTheme.normal,
            width: 42,
            height: 46,
            decoration: NavioTheme.surfaceDecoration(
              active: active,
              hovered: _hovered && _canTap,
              pressed: _pressed,
              disabled: !active,
              glow: _hovered && _canTap,
              radius: NavioTheme.radiusMedium,
              border: false,
            ),
            child: widget.isLoading
                ? Center(
                    child: SizedBox(
                      width: 17,
                      height: 17,
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: active
                        ? NavioTheme.accent
                        : NavioTheme.textMuted(alpha: 0.26),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final _TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: NavioTheme.surfaceDecoration(
          active: todo.isDone,
          radius: NavioTheme.radiusMedium,
          border: false,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: _TodoActionControl(todo: todo, onTap: onToggle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                todo.title,
                softWrap: true,
                style: TextStyle(
                  fontFamily: "SF-Pro",
                  fontSize: 13,
                  color: todo.isDone
                      ? NavioTheme.textMuted(alpha: 0.42)
                      : NavioTheme.textSecondary(alpha: 0.78),
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: NavioTheme.textMuted(alpha: 0.42),
                ),
              ),
            ),
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: NavioTheme.textMuted(alpha: 0.38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoActionControl extends StatelessWidget {
  final _TodoItem todo;
  final VoidCallback onTap;

  const _TodoActionControl({required this.todo, required this.onTap});

  bool get _isSpecial => todo.kind != _todoKindNormal;

  IconData get _icon {
    if (todo.isDone) return Icons.check_rounded;
    return switch (todo.kind) {
      _todoKindResources => Icons.open_in_new_rounded,
      _todoKindSkills => Icons.radar_rounded,
      _todoKindResume => Icons.upload_file_rounded,
      _ => Icons.check_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final active = todo.isDone || _isSpecial;
    final showIcon = todo.isDone || _isSpecial;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: NavioTheme.normal,
          width: _isSpecial && !todo.isDone ? 30 : 22,
          height: 22,
          decoration: BoxDecoration(
            // Always use BoxShape.rectangle with borderRadius so AnimatedContainer
            // can safely interpolate between states without triggering the
            // assertion that fires when shape switches between circle and rectangle.
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(999),
            color: active
                ? NavioTheme.accent.withValues(alpha: todo.isDone ? 0.18 : 0.1)
                : null,
            border: Border.all(
              color: active
                  ? NavioTheme.borderColor(active: true)
                  : NavioTheme.borderColor(),
              width: NavioTheme.borderWidth,
            ),
            boxShadow: _isSpecial && !todo.isDone
                ? NavioTheme.glow(alpha: 0.05)
                : const [],
          ),
          child: showIcon
              ? Center(
                  child: Icon(
                    _icon,
                    size: _isSpecial && !todo.isDone ? 13 : 15,
                    color: active
                        ? NavioTheme.accent
                        : NavioTheme.textMuted(alpha: 0.42),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _EmptyTodoState extends StatelessWidget {
  const _EmptyTodoState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: NavioTheme.surfaceDecoration(
        radius: NavioTheme.radiusMedium,
        border: false,
      ),
      child: Text(
        "Add a task from your roadmap, an application deadline, or one thing to learn next.",
        style: TextStyle(
          fontFamily: "SF-Pro",
          fontSize: 13,
          color: NavioTheme.textMuted(alpha: 0.42),
          height: 1.45,
        ),
      ),
    );
  }
}
