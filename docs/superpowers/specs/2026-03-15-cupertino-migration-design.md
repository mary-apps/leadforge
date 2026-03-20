# LeadForge — Migración a Cupertino Nativo

## Objetivo

Migrar LeadForge de Material Design (dark premium con acentos amber/fuchsia) a **Cupertino nativo** con soporte Light + Dark mode automático, para que la app se sienta como una app nativa de Apple.

## Decisiones de Diseño

- **Framework UI**: CupertinoApp + widgets Cupertino nativos
- **Color**: Colores estándar de Apple (systemBlue acento, systemGroupedBackground, etc.) con soporte automático Light/Dark
- **Tipografía**: SF Pro (system font de iOS), eliminando google_fonts y Space Grotesk
- **Navegación**: CupertinoTabBar estándar (5 tabs, sin FAB), CupertinoNavigationBar en detalles con push/pop nativo
- **Animaciones**: Conservar score gauge animado y staggered lists; eliminar aurora, confetti, glow cards, shimmer text, pulse dots
- **Feedback al usuario**: Reemplazar SnackBars con banners estilo iOS (overlay custom ligero)
- **Formularios**: `CupertinoTextField` con validación custom inline (no tiene `errorText` nativo)

## Consideraciones Técnicas Clave

### GoRouter + CupertinoTabBar

`CupertinoTabScaffold` gestiona sus propios tabs y entra en conflicto con `StatefulShellRoute.indexedStack` de GoRouter. **Solución: usar `CupertinoTabBar` como widget directo** dentro del shell de GoRouter existente, sin `CupertinoTabScaffold`. Esto preserva la arquitectura actual de navegación.

### Estado mixto durante migración

`CupertinoApp` no provee `ThemeData` a descendientes. Cualquier widget que use `Theme.of(context)` obtendrá defaults. Durante la migración:
- Crear una clase `AppColors` con `CupertinoDynamicColor` que reemplace todos los lookups de `Theme.of(context)`
- Envolver temporalmente con un widget `Theme` si es necesario para widgets Material que aún no se migraron

### Diálogos y sheets

Reemplazar todos los usos de `showModalBottomSheet` → `showCupertinoModalPopup` y `showDialog` → `showCupertinoDialog` en los archivos que los usen.

### RefreshIndicator

`RefreshIndicator` (Material) → `CupertinoSliverRefreshControl` dentro de `CustomScrollView` en Dashboard y cualquier pantalla con pull-to-refresh.

## Estrategia: Migración por Capas (5 fases)

### Fase 1: Theme + CupertinoApp Base

**Archivos:**
- `lib/app.dart` — `MaterialApp.router` → `CupertinoApp.router` (este es el archivo que contiene el MaterialApp, no main.dart)
- `lib/main.dart` — Actualizar system overlay style para ser dinámico (no hardcoded dark)
- `lib/config/theme.dart` — Reescribir con `CupertinoThemeData` + clase `AppColors` con `CupertinoDynamicColor` para colores semánticos
- `lib/config/routes.dart` — Adaptar GoRouter para `CupertinoPageRoute` transitions
- `pubspec.yaml` — Remover `google_fonts`

**Detalles:**
- `CupertinoThemeData` con `brightness` auto (respeta configuración del sistema)
- `primaryColor`: `CupertinoColors.systemBlue`
- `scaffoldBackgroundColor`: `CupertinoColors.systemGroupedBackground`
- `barBackgroundColor`: translúcido con blur (comportamiento por defecto de Cupertino)
- Clase `AppColors` con colores semánticos: `CupertinoColors.systemGreen` (success), `.systemOrange` (warning), `.systemRed` (danger), `.systemIndigo` (info)
- Mantener `GlobalMaterialLocalizations.delegate` temporalmente hasta completar Fase 4

**Criterio de completado:** La app lanza con CupertinoApp, Light/Dark mode del sistema funciona, todas las pantallas renderizan (aunque se vean mixtas).

### Fase 2: Navegación

**Archivos:**
- `lib/widgets/app_bottom_nav.dart` — Reescribir como `CupertinoTabBar` (widget directo, sin CupertinoTabScaffold) dentro del shell de GoRouter
- `lib/config/routes.dart` — `CupertinoPageRoute` para rutas de detalle, eliminar custom slide+fade transitions
- `lib/screens/audit/business_detail_screen.dart` — Agregar `CupertinoNavigationBar`
- `lib/screens/build/build_demo_screen.dart` — Agregar `CupertinoNavigationBar`
- `lib/screens/outreach/outreach_screen.dart` — Agregar `CupertinoNavigationBar`

**Detalles:**
- 5 tabs: Dashboard (`CupertinoIcons.house_fill`), Pipeline (`CupertinoIcons.chart_bar_fill`), Scout (`CupertinoIcons.search`), Messages (`CupertinoIcons.bubble_left_fill`), Settings (`CupertinoIcons.gear`)
- Eliminar: scout orb FAB, breathing animation, glass effect flotante
- `CupertinoNavigationBar` con `previousPageTitle` dinámico en pantallas de detalle
- Decidir sobre Hero animations existentes: mantener si aportan valor, remover si interfieren con push/pop nativo

**Criterio de completado:** Navegación por tabs funciona con CupertinoTabBar, pantallas de detalle tienen nav bar con back button nativo.

### Fase 3: Widgets Comunes

**Migraciones:**

| Widget actual | Widget Cupertino | Notas |
|---|---|---|
| `BrutalButton` | `CupertinoButton` / `CupertinoButton.filled` | |
| `BrutalCard` | `CupertinoListSection` o `Container` con estilo iOS | No todo uso de card mapea a ListSection; algunos serán Container con decoración iOS |
| `BusinessCard` | `CupertinoListTile` con avatar y chevron | |
| `NicheChips` | Pills con `CupertinoButton` toggleable | NicheChips permite multi-select; `CupertinoSlidingSegmentedControl` es single-select, no aplica |
| `EmptyState` | Simplificado: `CupertinoIcons` + texto + `CupertinoButton` | |
| `ErrorState` | Adaptar a Cupertino (usa BrutalButton y Material icons) | |
| `StatCardAnimated` | Mantener, adaptar colores a `CupertinoColors` | |
| `AnimatedScoreGauge` | Mantener, adaptar colores a `CupertinoColors` | |
| `SearchSuggestions` | `CupertinoSearchTextField` + lista nativa | |
| `SkeletonLoaders` | Mantener, adaptar colores | |
| `WeeklyActivityGraph` | Mantener (fl_chart), adaptar colores | |
| `ShareBusinessSheet` | `CupertinoActionSheet` via `showCupertinoModalPopup` | |
| `GlassContainer` | Migrar usos a Container con estilo iOS antes de eliminar en Fase 5 | |

**Además:**
- Reemplazar todos los `ScaffoldMessenger.showSnackBar` (8+ archivos) con un overlay banner estilo iOS
- Reemplazar `showModalBottomSheet` → `showCupertinoModalPopup`
- Reemplazar `showDialog` → `showCupertinoDialog`
- Auditar usos de `flutter_animate`: mantener staggered lists, remover `.shimmer()` y otros efectos "flashy"
- Reemplazar custom `Haptics` utility donde widgets Cupertino ya proveen feedback háptico

**Criterio de completado:** Todos los widgets comunes usan APIs Cupertino. No quedan SnackBars ni showModalBottomSheet.

### Fase 4: Pantallas

Cada pantalla: reemplazar `Scaffold` → `CupertinoPageScaffold`, usar widgets migrados en Fase 3, adaptar layouts a patrones iOS.

| Pantalla | Archivo | Enfoque Cupertino |
|---|---|---|
| Dashboard | `dashboard_screen.dart` | `CupertinoSliverNavigationBar("LeadForge")` en `CustomScrollView`, `CupertinoSliverRefreshControl` para pull-to-refresh |
| Pipeline | `pipeline_screen_enhanced.dart` | `CupertinoSegmentedControl` para stages, lista agrupada |
| Scout | `scout_screen.dart` | `CupertinoSearchTextField`, resultados en lista nativa |
| Messages | `messages_screen.dart` | `CupertinoListSection` con avatars |
| Settings | `settings_screen.dart` | `CupertinoListSection.insetGrouped` (estilo Settings de iOS) |
| Login | `login_screen.dart` | `CupertinoTextField` con validación inline custom, `CupertinoButton`, Sign In with Apple |
| Onboarding | `onboarding_screen.dart` | `CupertinoPageScaffold`, estilo setup de iOS |
| BusinessDetail | `business_detail_screen.dart` | Score gauge + `CupertinoListSection` para info |
| BuildDemo | `build_demo_screen.dart` | `CupertinoFormSection` con validación inline |
| Outreach | `outreach_screen.dart` | `CupertinoFormSection` con validación inline |

**Criterio de completado:** Todas las pantallas usan CupertinoPageScaffold y widgets Cupertino. No queda ningún Scaffold de Material.

### Fase 5: Limpieza

**Eliminar archivos:**
- `lib/widgets/aurora_background.dart`
- `lib/widgets/glow_card.dart`
- `lib/widgets/shimmer_text.dart`
- `lib/widgets/pulse_dot.dart`
- `lib/widgets/forge_loader.dart`
- `lib/widgets/glass_container.dart`
- `lib/widgets/animated_button.dart` (deprecated)
- `lib/widgets/score_gauge.dart` (superseded por AnimatedScoreGauge)

**Eliminar dependencias (pubspec.yaml):**
- `google_fonts`
- `confetti`
- `shimmer`

**Mantener:**
- `flutter_animate` (para staggered list animations)
- `fl_chart` (para gráficas)
- `cupertino_icons` (verificar que esté en pubspec)

**Además:**
- Remover `GlobalMaterialLocalizations.delegate` si ya no se necesita
- Evaluar `uses-material-design: true` en pubspec.yaml — cambiar a false si no quedan Material icons
- Eliminar archivos de pantallas no usadas (e.g., `pipeline_screen.dart` si solo se usa `pipeline_screen_enhanced.dart`)

**Criterio de completado:** No quedan archivos ni dependencias obsoletas. La app compila limpiamente sin warnings de imports no usados.

## Fuera de Alcance

- Funcionalidad nueva — esta migración es puramente visual/UX
- Cambios en backend/Supabase
- Cambios en providers/state management (Riverpod se mantiene igual)
- Soporte para plataformas no-iOS (la app ya es iOS-focused)
