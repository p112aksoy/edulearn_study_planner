import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/data/models/deadline_mode.dart';
import 'package:edulearn/logic/providers/home_provider.dart';
import 'package:edulearn/core/responsive.dart';

class DeadlineSection extends StatefulWidget {
  const DeadlineSection({super.key});

  @override
  State<DeadlineSection> createState() => _DeadlineSectionState();
}

class _DeadlineSectionState extends State<DeadlineSection> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(StateSetter setModalState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary:   Theme.of(context).colorScheme.primary,
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            onSurface: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setModalState(() => _selectedDate = picked);
  }

  void _showDeadlineSheet() {
    _titleController.clear();
    _selectedDate = DateTime.now();
    final color = Theme.of(context).colorScheme;
    final text  = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left:   Responsive.pagePadding(context),
            right:  Responsive.pagePadding(context),
            top:    Responsive.spacing(context) * 1.25,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                Responsive.sectionSpacing(context) * 1.5,
          ),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Responsive.radius(context))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45, height: 5,
                decoration: BoxDecoration(
                    color: color.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
              ),
              SizedBox(height: Responsive.sectionSpacing(context)),

              // it is for title input
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context) * 1.25,
                    vertical: 5),
                decoration: BoxDecoration(
                  color: color.onSurface.withValues(alpha: 0.05),
                  borderRadius:
                  BorderRadius.circular(Responsive.cardRadius(context)),
                ),
                child: TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: "Task Name",
                    hintStyle: TextStyle(
                        color: color.onSurface.withValues(alpha: 0.3)),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: Responsive.spacing(context) * 1.25),

              // * for date picker*
              InkWell(
                onTap: () => _pickDate(setModalState),
                borderRadius:
                BorderRadius.circular(Responsive.cardRadius(context)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.spacing(context),
                      vertical:   Responsive.spacing(context) * 1.125),
                  decoration: BoxDecoration(
                    color: color.onSurface.withValues(alpha: 0.05),
                    borderRadius:
                    BorderRadius.circular(Responsive.cardRadius(context)),
                    border: Border.all(
                        color: color.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        color: color.primary,
                        size: Responsive.icon(context)),
                    SizedBox(width: Responsive.spacing(context)),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? "Select Target Date"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color.onSurface),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: Responsive.smallIcon(context) * 0.75,
                        color: color.primary),
                  ]),
                ),
              ),

              SizedBox(height: Responsive.sectionSpacing(context) * 1.5),

              // for save button
              SizedBox(
                width: double.infinity,
                height: Responsive.buttonHeight(context),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                    foregroundColor: color.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            Responsive.cardRadius(context))),
                  ),
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty &&
                        _selectedDate != null) {
                      context.read<HomeProvider>().addDeadline(
                          _titleController.text.trim(), _selectedDate!);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Schedule Task",
                      style: text.titleSmall?.copyWith(
                          color: color.onPrimary,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color    = Theme.of(context).colorScheme;
    final provider = context.watch<HomeProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text("Deadlines",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color.onSurface, fontWeight: FontWeight.w900)),
            ),
            SizedBox(width: Responsive.spacing(context) * 0.75),
            ElevatedButton.icon(
              onPressed: _showDeadlineSheet,
              icon: Icon(Icons.add_rounded,
                  size: Responsive.smallIcon(context)),
              label: const Text("Add",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.primary,
                foregroundColor: color.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        Responsive.cardRadius(context))),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context)),
        if (provider.deadlines.isEmpty)
          _buildEmptyState(color)
        else
          ...provider.deadlines.map(
                (d) => _buildDeadlineItem(color, d, provider),
          ),
      ],
    );
  }

  Widget _buildDeadlineItem(
      ColorScheme color, Deadline item, HomeProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context) * 0.75),
      padding: EdgeInsets.all(Responsive.spacing(context) * 1.125),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(
            color: color.primary.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded,
              color: color.primary, size: Responsive.icon(context)),
          SizedBox(width: Responsive.spacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color.onSurface, fontWeight: FontWeight.w700)),
                Text(_formatDateLabel(item.date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color.primary, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => provider.removeDeadline(item.id),
            icon: Icon(Icons.close_rounded,
                color: color.onSurface.withValues(alpha: 0.2),
                size: Responsive.icon(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme color) {
    return Column(children: [
      SizedBox(height: Responsive.spacing(context) * 1.25),
      Icon(Icons.calendar_today_outlined,
          color: color.primary.withValues(alpha: 0.15),
          size: Responsive.icon(context) * 2.18),
      SizedBox(height: Responsive.spacing(context) * 0.625),
      Text("No goals yet",
          style: TextStyle(
              color: color.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold)),
    ]);
  }

  String _formatDateLabel(DateTime date) {
    final now  = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff < 0) return "Overdue";
    if (diff == 0) return "Today";
    if (diff == 1) return "Tomorrow";
    return "In $diff days";
  }
}