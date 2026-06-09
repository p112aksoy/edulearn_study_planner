import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/data/models/scratchpad_model.dart';
import 'package:edulearn/logic/providers/home_provider.dart';
import 'package:edulearn/core/responsive.dart';

class ScratchpadSection extends StatefulWidget {
  const ScratchpadSection({super.key});

  @override
  State<ScratchpadSection> createState() => _ScratchpadSectionState();
}

class _ScratchpadSectionState extends State<ScratchpadSection> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    // always dispose controllers to avoid memory leaks
    _noteController.dispose();
    super.dispose();
  }

  // handles the animation sequence before permanently removing the note
  Future<void> _completeAndRemove(int index) async {
    final provider = context.read<HomeProvider>();
    // 1. mark the note as done to trigger the UI checkmark and fade animation
    await provider.completeScratchNote(index);
    // 2. wait for the 550ms fade out animation to complete
    await Future.delayed(const Duration(milliseconds: 550));
    // 3. permanently remove the record from provider and local database
    if (mounted) await provider.removeScratchNoteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    // context.watch rebuilds the widget whenever scratchNotes changes
    final notes = context.watch<HomeProvider>().scratchNotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Scratchpad",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color.onSurface, fontWeight: FontWeight.w800)),
        SizedBox(height: Responsive.spacing(context)),
        _buildInput(color),
        SizedBox(height: Responsive.spacing(context) * 0.75),
        _buildList(notes, color),
      ],
    );
  }

  Widget _buildInput(ColorScheme color) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context) * 0.625),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Responsive.radius(context)),
        border: Border.all(
            color: color.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          SizedBox(width: Responsive.spacing(context) * 0.625),
          Expanded(
            child: TextField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addNote(),
              decoration: InputDecoration(
                hintText: "Add quick note...",
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: color.onSurface.withValues(alpha: 0.3)),
              ),
            ),
          ),
          IconButton(
            onPressed: _addNote,
            icon: Icon(Icons.add_circle_rounded,
                color: color.primary,
                size: Responsive.icon(context) * 1.45),
          ),
        ],
      ),
    );
  }

  // builds the list of scratchpad notes with fade animation on completion
  Widget _buildList(List<ScratchpadModel> notes, ColorScheme color) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];

        // animatedOpacity fades out the note when isDone becomes true
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: note.isDone ? 0.0 : 1.0,
          child: Container(
            margin: EdgeInsets.only(
                bottom: Responsive.spacing(context) * 0.625),
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing(context),
                vertical: Responsive.spacing(context) * 0.875),
            decoration: BoxDecoration(
              color: color.onSurface.withValues(alpha: 0.12),
              borderRadius:
              BorderRadius.circular(Responsive.cardRadius(context)),
              border: Border.all(
                  color: color.primary.withValues(alpha: 0.12), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  // accesses task directly from the model instead of map lookup
                  child: Text(note.task,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color.onSurface,
                          fontWeight: FontWeight.w600)),
                ),
                SizedBox(width: Responsive.spacing(context) * 0.75),
                GestureDetector(
                  onTap: () => _completeAndRemove(index),
                  // animatedContainer smoothly transitions the checkbox fill color
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: Responsive.icon(context) * 1.27,
                    height: Responsive.icon(context) * 1.27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color.primary, width: 2),
                      color: note.isDone ? color.primary : Colors.transparent,
                    ),
                    child: note.isDone
                        ? Icon(Icons.check,
                        size: Responsive.smallIcon(context),
                        color: color.onPrimary)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // sanitizes text entry and dispatches the new note to the state manager
  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      context.read<HomeProvider>().addScratchNote(_noteController.text.trim());
      _noteController.clear();
    }
  }
}