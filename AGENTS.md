# Codex Project Guide

This file is the project-level working guide for Codex in `flutter_ui_project`.

## Project Role

`flutter_ui_project` is the final Flutter business frontend project. Its purpose is to keep the existing high-fidelity m1 Flutter UI while wiring real m1 page logic, API behavior, and Flutter engineering capabilities into the current codebase.

Do not treat this project as a direct copy of the m1 Web project or the old Flutter project. All final implementation belongs in this repository.

## Reference Boundaries

When this project mentions "m1", "m1 project", or "bw-6-2 reference project", it always means:

```text
/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1
```

Use this m1 project as the source for:

- UI structure, visual details, page interaction, and transition intent.
- Page lifecycle, API call timing, request params, response usage, and route behavior.
- `views/**`, `api/**`, `router/index.js`, and `i18n/messages/**`.

Do not substitute other bw-6-2 subprojects, the old Flutter project, or similar directories.

The old Flutter project is only an engineering reference:

```text
/Users/john/Documents/trae_projects/flutter-v1
```

Use it only for network layer organization, Provider/Service/Model patterns, cache, error handling, platform capability, and Flutter implementation experience. Do not use it as the source for page business logic and do not copy it wholesale.

## Core Principles

- Preserve the current m1 high-fidelity Flutter UI before changing business behavior.
- Keep UI changes and business integration separated where possible.
- Make the smallest UI binding needed for real data, loading, empty, error, and fallback states.
- Zero tolerance for `RenderFlex overflowed` across iPhone, iPad, common Android sizes, and long text.
- Do not show fake business data when APIs fail or return empty data.
- Every implemented page or business loop should remain independently verifiable and easy to roll back.

## Flutter Constraints

- Use Flutter `>=3.19.0` and Dart `>=3.3.0`.
- Use `go_router` for declarative routing.
- Use `provider` or `flutter_hooks` for local or page-level UI state. Avoid unnecessary global state.
- Use `flutter_svg` for vector assets.
- Manage asset paths through static wrappers such as `AppImages.logo`; avoid hard-coded asset strings in business code.

## UI And Styling

- Avoid hard-coded colors and design dimensions in widgets. Prefer project theme tokens and `ThemeExtension`, for example `Theme.of(context).extension<AppColors>()`.
- Use `flutter_screenutil` for scalable width, height, radius, and font sizes with `.w`, `.h`, `.r`, and `.sp`.
- Thin divider/border lines may stay fixed at `1.0` or `0.5`.
- Map Web typography carefully. Flutter `TextStyle.height` is `line-height / font-size`.
- Configure and preserve font fallback for multilingual baseline consistency.
- Convert CSS `box-shadow` to Flutter `BoxShadow` with matching color, offset, blur, and spread.
- Convert CSS `backdrop-filter: blur` with `BackdropFilter` and `ImageFilter.blur`.

## Components And Layout

- Prefer bottom-up component work: reusable atomic widgets first, then page composition.
- Buttons, cards, hover, active, and focus states should provide visible feedback through Flutter-native animation/state APIs.
- Map Web Flexbox to `Row`/`Column` plus `Expanded` when needed.
- Map Web Grid to `SliverGrid` or `GridView.builder` with accurate `crossAxisCount` and `childAspectRatio`.
- Game top-level provider category images must follow m1 `views/main/Game.vue` `.provider-grid` / `.provider-cover`: 3 columns, 12px spacing, title below image, no fixed height or square aspect ratio for top-level categories.
- Do not apply `GameSubList.vue` square child-game image rules to the top-level provider category list.
- Use `SafeArea` or `MediaQuery.padding` where needed to avoid notches and bottom system areas.

## Directory And Naming

- Dart files use `snake_case`, for example `home_screen.dart`.
- Dart classes use `PascalCase`, for example `HomeScreen`.
- Keep design tokens in `lib/theme/`.
- Keep shared atomic widgets in `lib/widgets/`.
- Keep business pages in `lib/screens/`.
- Keep routes and transition configuration in `lib/router/`.
- Put project documents in `docs/`.

## Documents

The OpenCode project documents have been migrated into the normal project documentation area:

- `docs/API_INTEGRATION_SEQUENCE.md`
- `docs/ENGINEERING_BUSINESSIZATION_PLAN.md`
- `docs/NEW_FRONTEND_ARCHITECTURE_GUIDE.md`
- `docs/bw-pc-api-v2（适配h5）接口文档.md`
- `docs/UI_REPLICA_PROGRESS.md`

Documentation updates are part of the definition of done for business/API/UI changes.

Update the relevant document before reporting completion when a task changes:

- API integration, data source switching, page business behavior, route/navigation behavior, fallback state, or key bug fixes.
- Interface and business progress: update `docs/API_INTEGRATION_SEQUENCE.md`.
- Overall plan, priority, risk boundary, or businessization scope: update `docs/ENGINEERING_BUSINESSIZATION_PLAN.md`.
- UI replica status, page entry, interaction state, or implemented/unimplemented state: update `docs/UI_REPLICA_PROGRESS.md`.

Before the final response for code-changing work, check whether these documents need updates:

- `docs/API_INTEGRATION_SEQUENCE.md`
- `docs/ENGINEERING_BUSINESSIZATION_PLAN.md`
- `docs/UI_REPLICA_PROGRESS.md`

Pure consultation, read-only investigation, test-only runs, or temporary experiments that do not land changes may skip document updates. If the conclusion changes future plans, update the relevant plan document.

## Project Skills

OpenCode skills for this project have been migrated into project-level Codex skill sources under:

```text
codex/skills/
```

These skills are project-local references. When a user request clearly matches one of them, read the corresponding `SKILL.md` before working:

- `codex/skills/flutter-layout-fixer/SKILL.md`: use for Flutter `RenderFlex` overflow, layout breakage, long multilingual text, and Flex/Grid constraint fixes.
- `codex/skills/screenshot-to-flutter/SKILL.md`: use when converting a screenshot or source UI into high-fidelity Flutter code.
- `codex/skills/ui-fidelity-checker/SKILL.md`: use when checking or improving UI fidelity against m1, a screenshot, or an original design.
- `codex/skills/ui-ux-pro-max/SKILL.md`: use for broader UI/UX design, implementation, review, or improvement work. Its searchable data and scripts live in `codex/skills/ui-ux-pro-max/data/` and `codex/skills/ui-ux-pro-max/scripts/`.

For `ui-ux-pro-max`, run its helper from the project root, for example:

```bash
python3 codex/skills/ui-ux-pro-max/scripts/search.py "flutter dashboard professional" --design-system -p "flutter_ui_project"
```

## Common Commands

```bash
flutter pub get
./run_web.sh
dart format lib test
flutter analyze lib test
flutter test
```

When the user asks to start the project, default to:

```bash
./run_web.sh
```

`run_web.sh` prepares Flutter Web fallback fonts and starts Chrome with `flutter run -d chrome --no-web-resources-cdn`.

## Git

Do not proactively commit, push, reset, or otherwise mutate Git history unless the user explicitly asks.
