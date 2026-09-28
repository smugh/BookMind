# Book&Mind

Personal reading knowledge system for Android, built with Flutter and designed to work offline.

## Project structure

```text
lib/
  app/                         App setup, routing, and dependency wiring
  core/                        Shared utilities, errors, and design tokens
  data/
    database/                  Local SQLite/Drift setup and schema
  features/
    library/                   Import and manage PDF/EPUB books
      data/ domain/ presentation/
    reader/                    Read books, search text, save position/bookmarks
      data/ domain/ presentation/
    highlights/                Capture and color source highlights
      data/ domain/ presentation/
    notes/                     Reflection notes and tags
      data/ domain/ presentation/
    knowledge_hub/             Search, browse, and filter notes across books
      data/ domain/ presentation/
  shared/                      Reusable widgets and cross-feature components
  main.dart                    Flutter entry point
```

Feature folders use `data`, `domain`, and `presentation` boundaries so each module can grow independently. Local storage and database setup live outside individual features because books, highlights, notes, and tags share the same database.

## Initial build order

1. App shell and dependency setup.
2. Drift/SQLite schema and local book import.
3. Library and PDF/EPUB reader with last-read position.
4. Highlights, reflections, and tags.
5. Knowledge Hub search, filters, and source navigation.
