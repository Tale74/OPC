import 'package:flutter/material.dart';

import 'opc_guide_repository.dart';

class OpcGuideScreen extends StatefulWidget {
  const OpcGuideScreen({
    super.key,
    this.initialChapterId = 'overview',
    this.assetBundle,
  });

  final String initialChapterId;
  final AssetBundle? assetBundle;

  @override
  State<OpcGuideScreen> createState() => _OpcGuideScreenState();
}

class _OpcGuideScreenState extends State<OpcGuideScreen> {
  Future<List<OpcGuideChapter>>? _chaptersFuture;
  String? _selectedChapterId;
  int _selectedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedChapterId = widget.initialChapterId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chaptersFuture ??= const OpcGuideRepository().load(
      bundle: widget.assetBundle ?? DefaultAssetBundle.of(context),
    );
  }

  void _selectChapter(OpcGuideChapter chapter) {
    setState(() {
      _selectedChapterId = chapter.id;
      _selectedSectionIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'RAD U APLIKACIJI',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      actions: [
        IconButton(
          key: const Key('opc-guide-full-guide-action'),
          tooltip: 'Početak uputstva',
          onPressed: () => setState(() {
            _selectedChapterId = 'overview';
            _selectedSectionIndex = 0;
          }),
          icon: const Icon(Icons.menu_book_outlined),
        ),
      ],
    ),
    body: FutureBuilder<List<OpcGuideChapter>>(
      future: _chaptersFuture!,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Uputstvo trenutno nije dostupno.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          );
        }
        final chapters = snapshot.data;
        if (chapters == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (chapters.isEmpty) {
          return const Center(
            child: Text(
              'Nema poglavlja u uputstvu.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        }
        final chapter = chapters.firstWhere(
          (item) => item.id == _selectedChapterId,
          orElse: () => chapters.first,
        );
        if (_selectedChapterId != chapter.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedChapterId = chapter.id);
          });
        }
        final wide = MediaQuery.sizeOf(context).width >= 900;
        return Row(
          children: [
            if (wide) ...[
              SizedBox(
                width: 300,
                child: _ChapterNavigation(
                  chapters: chapters,
                  selectedChapterId: chapter.id,
                  onSelected: _selectChapter,
                ),
              ),
              const VerticalDivider(width: 1),
            ],
            Expanded(
              child: _ChapterContent(
                chapters: chapters,
                chapter: chapter,
                selectedSectionIndex: _selectedSectionIndex,
                onChapterSelected: _selectChapter,
                onSectionSelected: (index) =>
                    setState(() => _selectedSectionIndex = index),
                showChapterPicker: !wide,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _ChapterNavigation extends StatelessWidget {
  const _ChapterNavigation({
    required this.chapters,
    required this.selectedChapterId,
    required this.onSelected,
  });

  final List<OpcGuideChapter> chapters;
  final String selectedChapterId;
  final ValueChanged<OpcGuideChapter> onSelected;

  @override
  Widget build(BuildContext context) => ListView.builder(
    key: const Key('opc-guide-chapter-navigation'),
    padding: const EdgeInsets.symmetric(vertical: 8),
    itemCount: chapters.length,
    itemBuilder: (context, index) {
      final chapter = chapters[index];
      return ListTile(
        selected: chapter.id == selectedChapterId,
        title: Text(
          chapter.title,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        onTap: () => onSelected(chapter),
      );
    },
  );
}

class _ChapterContent extends StatelessWidget {
  const _ChapterContent({
    required this.chapters,
    required this.chapter,
    required this.selectedSectionIndex,
    required this.onChapterSelected,
    required this.onSectionSelected,
    required this.showChapterPicker,
  });

  final List<OpcGuideChapter> chapters;
  final OpcGuideChapter chapter;
  final int selectedSectionIndex;
  final ValueChanged<OpcGuideChapter> onChapterSelected;
  final ValueChanged<int> onSectionSelected;
  final bool showChapterPicker;

  @override
  Widget build(BuildContext context) {
    final safeSectionIndex = chapter.sections.isEmpty
        ? 0
        : selectedSectionIndex.clamp(0, chapter.sections.length - 1);
    final section = chapter.sections.isEmpty
        ? null
        : chapter.sections[safeSectionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showChapterPicker)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String>(
              key: const Key('opc-guide-chapter-picker'),
              initialValue: chapter.id,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'POGLAVLJE',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              style: const TextStyle(fontStyle: FontStyle.italic),
              items: chapters
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (id) {
                if (id == null) return;
                onChapterSelected(chapters.firstWhere((item) => item.id == id));
              },
            ),
          ),
        Expanded(
          child: ListView(
            key: Key('opc-guide-content-${chapter.id}'),
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                chapter.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                chapter.intro,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              if (chapter.sections.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  key: const Key('opc-guide-section-picker'),
                  initialValue: safeSectionIndex,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'DEO POGLAVLJA',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  style: const TextStyle(fontStyle: FontStyle.italic),
                  items: chapter.sections.indexed
                      .map(
                        (entry) => DropdownMenuItem<int>(
                          value: entry.$1,
                          child: Text(
                            entry.$2.title,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (index) {
                    if (index != null) onSectionSelected(index);
                  },
                ),
                const SizedBox(height: 16),
                if (section != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            section.text,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              Text(
                'DRUGA POGLAVLJA',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chapters
                    .where((item) => item.id != chapter.id)
                    .take(8)
                    .map(
                      (item) => ActionChip(
                        label: Text(
                          item.title,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        onPressed: () => onChapterSelected(item),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
