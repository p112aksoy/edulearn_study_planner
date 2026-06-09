import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulearn/logic/providers/study_provider.dart';
import 'package:edulearn/core/responsive.dart';

class PomodoroMusicSection extends StatelessWidget {
  const PomodoroMusicSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color     = Theme.of(context).colorScheme;
    final text      = Theme.of(context).textTheme;
    // listening to StudyProvider to reflect instant track changes and play and pause states
    final studyProv = context.watch<StudyProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Responsive.sectionSpacing(context) * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sound Environment",
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900)),
                SizedBox(height: Responsive.spacing(context) * 0.25),
                Text("Select background sound to optimize focus",
                    style: text.bodySmall?.copyWith(
                        color: color.onSurface.withValues(alpha: 0.5))),
              ],
            ),
            // the "mute" button appears only when a specific track is selected or active
            if (studyProv.currentTrackIndex != null)
              TextButton.icon(
                onPressed: () => studyProv.stopMusic(),
                icon: Icon(Icons.music_off_rounded,
                    size: Responsive.smallIcon(context),
                    color: color.error),
                label: Text("Mute",
                    style: TextStyle(
                        color: color.error, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: studyProv.playlist.length,
          itemBuilder: (context, index) {
            final song       = studyProv.playlist[index];
            // dynamic state evaluation to determine UI styling (colors, borders, icons)
            final isSelected = studyProv.currentTrackIndex == index;
            final isPlaying  = isSelected && studyProv.isPlaying;

            return GestureDetector(
              onTap: () => studyProv.togglePlayPause(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(
                    bottom: Responsive.spacing(context) * 0.75),
                padding: EdgeInsets.all(Responsive.spacing(context)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.primary.withValues(alpha: 0.08)
                      : color.surface,
                  borderRadius:
                  BorderRadius.circular(Responsive.cardRadius(context)),
                  border: Border.all(
                    color: isSelected
                        ? color.primary
                        : color.onSurface.withValues(alpha: 0.08),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                // dynamic action icon switching between play and pause states
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          Responsive.spacing(context) * 0.75),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.primary
                            : color.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color:
                        isSelected ? color.onPrimary : color.primary,
                        size: Responsive.icon(context),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.title,
                              style: text.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? color.primary
                                      : color.onSurface)),
                          SizedBox(
                              height: Responsive.spacing(context) * 0.25),
                          Text(song.description,
                              style: text.bodySmall?.copyWith(
                                  color: color.onSurface
                                      .withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    // status badge displaying whether the track is currently active or paused
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context) * 0.75,
                            vertical:   Responsive.spacing(context) * 0.375),
                        decoration: BoxDecoration(
                            color: color.primary,
                            borderRadius: BorderRadius.circular(
                                Responsive.radius(context) * 0.6)),
                        child: Text(isPlaying ? "ACTIVE" : "PAUSED",
                            style: text.labelSmall?.copyWith(
                                color: color.onPrimary,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}