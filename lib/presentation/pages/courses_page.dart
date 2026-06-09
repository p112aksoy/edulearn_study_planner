import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/courses.provider.dart';
import 'package:edulearn/data/models/course_model.dart';
import 'package:edulearn/presentation/pages/pomodoro_page.dart';
import 'package:edulearn/core/responsive.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // microtask triggers right after the first frame to load data from provider safely
    Future.microtask(() => context.read<CoursesProvider>().loadCourses());
  }

  @override
  void dispose() {
    // always dispose controllers to avoid memory leaks
    _titleController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final color    = theme.colorScheme;
    // context.watch listens to changes and rebuilds the UI automatically
    final provider = context.watch<CoursesProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: color.primary))
          : _buildBody(provider.courses, color, theme),
    );
  }

  Widget _buildBody(List<CourseModel> courses, ColorScheme color, ThemeData theme) {
    final double screenPadding = Responsive.padding(context);
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(

            padding: EdgeInsets.fromLTRB(screenPadding, 28, screenPadding, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Courses",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: color.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (courses.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context) * 0.75,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: color.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: color.primary.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            "${courses.length} course${courses.length > 1 ? 's' : ''} enrolled",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: color.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: Responsive.small(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showAddCourseSheet,
                  child: Container(
                    width: Responsive.buttonHeight(context) * 0.85,
                    height: Responsive.buttonHeight(context) * 0.85,
                    decoration: BoxDecoration(
                      color: color.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.primary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add_rounded, color: color.onPrimary, size: Responsive.icon(context)),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (courses.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(color, theme),
          )
        else
          SliverPadding(

            padding: EdgeInsets.fromLTRB(screenPadding, 0, screenPadding, 120),
            // dynamically switches between list and grid layout based on screen,device size
            sliver: (isMobile && !isLandscape)
                ? SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildCard(courses[i], i, color, theme),
                childCount: courses.length,
              ),
            )
                : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 2,
                mainAxisSpacing: Responsive.spacing(context),
                crossAxisSpacing: Responsive.spacing(context),
                mainAxisExtent: isLandscape
                    ? (Responsive.buttonHeight(context) * 3.4)
                    : (isDesktop ? 220 : 190),
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildCard(courses[i], i, color, theme),
                childCount: courses.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(CourseModel course, int index, ColorScheme color, ThemeData theme) {
    final progress = (course.progress / 100).clamp(0.0, 1.0);
    final double cardRadius = Responsive.radius(context);
    final double innerSpacing = Responsive.spacing(context);
    final bool isMobile = Responsive.isMobile(context);
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
// dismissible enables swiping cards to delete them from the list
    return Dismissible(
      key: ValueKey(course.id ?? course.title),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: (isMobile && !isLandscape) ? innerSpacing : 0),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: color.primary.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: color.primary, size: Responsive.icon(context)),
            const SizedBox(height: 4),
            Text("Delete",
                style: theme.textTheme.labelSmall?.copyWith(
                    color: color.primary,
                    fontSize: Responsive.small(context),
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDeletion(course, color, theme),
      onDismissed: (_) {
        // context.read is used inside callbacks (clicks/events) because we don't need to watch it here
        if (course.id != null) context.read<CoursesProvider>().deleteCourse(course.id!);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: (isMobile && !isLandscape) ? innerSpacing : 0),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: color.primary.withValues(alpha: 0.08), width: 1.5),
        ),
        child: Padding(
          padding: EdgeInsets.all(innerSpacing * 1.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Responsive.buttonHeight(context) * 0.72,
                    height: Responsive.buttonHeight(context) * 0.72,
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        course.title.isNotEmpty ? course.title[0].toUpperCase() : "?",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: color.primary,
                          fontSize: Responsive.heading(context) * 0.85,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: color.onSurface,
                            fontSize: Responsive.heading(context) * 0.85,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.flag_outlined,
                                size: Responsive.smallIcon(context) * 0.55,
                                color: color.onSurface.withValues(alpha: 0.35)),
                            const SizedBox(width: 4),
                            Text(
                              "${course.targetHours} hour goal",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: color.onSurface.withValues(alpha: 0.38),
                                fontSize: Responsive.small(context) * 0.95,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showEditCourseSheet(course),
                    icon: Icon(Icons.more_vert_rounded,
                        color: color.onSurface.withValues(alpha: 0.22),
                        size: Responsive.icon(context) * 0.8),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      "${course.progress}%",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color.primary,
                        fontSize: Responsive.body(context) * 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: color.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color.primary),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${(course.targetHours * course.progress / 100).toStringAsFixed(1)}h done",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color.primary,
                        fontSize: Responsive.small(context) * 0.9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${(course.targetHours * (100 - course.progress) / 100).toStringAsFixed(1)}h left",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color.onSurface.withValues(alpha: 0.4),
                        fontSize: Responsive.small(context) * 0.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PomodoroPage(
                          courseName: course.title,
                          courseId: course.id,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(context) * 0.9,
                        vertical: Responsive.spacing(context) * 0.4,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: color.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: color.onPrimary,
                              size: Responsive.smallIcon(context) * 0.9),
                          const SizedBox(width: 2),
                          Text("Study",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: color.onPrimary,
                                fontSize: Responsive.small(context) * 0.9,
                                fontWeight: FontWeight.w800,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme color, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book_rounded,
                color: color.primary.withValues(alpha: 0.35), size: 40),
          ),
          const SizedBox(height: 24),
          Text("No courses yet",
              style: theme.textTheme.titleLarge?.copyWith(
                color: color.onSurface.withValues(alpha: 0.5),
                fontSize: Responsive.heading(context),
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          Text("Tap + to add your first course",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color.onSurface.withValues(alpha: 0.3),
                fontSize: Responsive.body(context),
              )),
        ],
      ),
    );
  }

  void _showAddCourseSheet() {
    _titleController.clear();
    _hoursController.clear();
    _showCourseSheet(
      title: "New Course",
      subtitle: "Add a course to your study plan.",
      buttonLabel: "Add Course",
      onConfirm: () async {
        final t = _titleController.text.trim();
        final h = int.tryParse(_hoursController.text.trim()) ?? 1;
        if (t.isNotEmpty) {
          await context.read<CoursesProvider>().addCourse(t, h);
          if (mounted) Navigator.pop(context);
        }
      },
    );
  }

  void _showEditCourseSheet(CourseModel course) {
    _titleController.text = course.title;
    _hoursController.text = course.targetHours.toString();
    _showCourseSheet(
      title: "Edit Course",
      subtitle: "Update the course details.",
      buttonLabel: "Save Changes",
      onConfirm: () async {
        final t = _titleController.text.trim();
        final h = int.tryParse(_hoursController.text.trim()) ?? 1;
        if (t.isNotEmpty) {
          final updated = course.copyWith(title: t, targetHours: h);
          await context.read<CoursesProvider>().updateCourse(updated);
          if (mounted) Navigator.pop(context);
        }
      },
    );
  }

  void _showCourseSheet({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onConfirm,
  }) {
    final color = Theme.of(context).colorScheme;
    final text  = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: Responsive.cardWidth(context)),
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            top: 20, left: 26, right: 26,
          ),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Responsive.radius(context)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: color.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(title,
                    style: text.headlineSmall?.copyWith(
                        color: color.onSurface,
                        fontSize: Responsive.heading(context),
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: text.bodyMedium?.copyWith(
                        color: color.onSurface.withValues(alpha: 0.4),
                        fontSize: Responsive.body(context))),
                const SizedBox(height: 28),
                _buildInput(controller: _titleController, hint: "Course Title",
                    icon: Icons.title_rounded, color: color, text: text),
                const SizedBox(height: 14),
                _buildInput(controller: _hoursController, hint: "Target Hours",
                    icon: Icons.timer_outlined, color: color, text: text,
                    isNumber: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: Responsive.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.primary,
                      foregroundColor: color.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(buttonLabel,
                        style: text.titleSmall?.copyWith(
                            color: color.onPrimary,
                            fontSize: Responsive.body(context),
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ColorScheme color,
    required TextTheme text,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.primary.withValues(alpha: 0.12), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        style: text.bodyLarge?.copyWith(
            color: color.onSurface,
            fontSize: Responsive.body(context),
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color.primary, size: Responsive.smallIcon(context)),
          hintText: hint,
          hintStyle: text.bodyMedium?.copyWith(
              color: color.onSurface.withValues(alpha: 0.28),
              fontSize: Responsive.body(context)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Future<bool?> _confirmDeletion(CourseModel course, ColorScheme color, ThemeData theme) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: color.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context))),
        title: Text("Delete Course?",
            style: theme.textTheme.titleLarge?.copyWith(
                color: color.onSurface,
                fontSize: Responsive.heading(context),
                fontWeight: FontWeight.w900)),
        content: Text(
          "\"${course.title}\" will be permanently removed.",
          style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurface.withValues(alpha: 0.55),
              fontSize: Responsive.body(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel",
                style: theme.textTheme.labelLarge?.copyWith(
                    color: color.onSurface.withValues(alpha: 0.4),
                    fontSize: Responsive.small(context),
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete",
                style: theme.textTheme.labelLarge?.copyWith(
                    color: color.primary,
                    fontSize: Responsive.small(context),
                    fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}