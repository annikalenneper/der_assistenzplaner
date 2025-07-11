# UI Komponenten-Bibliothek für "Der Assistenzplaner"

Dieses Dokument dient als Referenz für alle wiederverwendbaren UI-Komponenten, die in der App "Der Assistenzplaner" verwendet werden. Ziel ist es, ein konsistentes Design und eine einheitliche User Experience sicherzustellen.

---

## 1. Grundlegende Elemente

### 1.1. Farben

- **Primärfarbe**: Wird für wichtige Aktionen, den "Heute"-Marker im Kalender und als allgemeine Akzentfarbe verwendet.
- **Akzentfarben (Assistenten)**: Jede Assistenzkraft hat eine einzigartige Farbe, die für ihren `AssistantMarker` und in der Detailansicht verwendet wird.
- **Statusfarben**:
  - **Erfolg/Verfügbar**: Eine einheitliche Farbe für Verfügbarkeits-Marker und positive Statusanzeigen.
  - **Warnung/Info**: Eine einheitliche Farbe für Warnhinweise und informative Dialoge (z.B. Archivierung).
  - **Fehler/Löschen**: Eine einheitliche Farbe für Löschen-Dialoge, negative Abweichungen und Fehlerzustände.
- **Neutral**: Verschiedene neutrale Töne für Text, Hintergründe und Trennlinien.

### 1.2. Typografie

- **HeadlineSmall**: Für Titel in der `AppBar` und in Dialogen.
- **TitleMedium/TitleLarge**: Für wichtige Überschriften innerhalb von Sektionen.
- **BodyMedium/BodySmall**: Für Standardtext und Beschriftungen.
- **Label**: Für kleine Beschriftungen in Buttons oder Chips.

### 1.3. Icons

- **Standard-Icons**: Material Design Icons (`Icons.*`).
- **Spezifische Icons**: FontAwesome Icons (`FaIcon`) für Tags.

---

## 2. Navigation

### 2.1. Hauptnavigation (NavigationRail)

- **Beschreibung**: Die primäre Navigation der App auf größeren Bildschirmen.
- **Ort**: [`lib/main.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\main.dart)

### 2.2. AppBar

- **Beschreibung**: Standard-Kopfzeile für Ansichten wie die Assistenten-Detailansicht. Enthält Titel, Zurück-Button und Aktionen.
- **Ort**: [`lib/views/assistant/assistant_screen.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\assistant\assistant_screen.dart)

### 2.3. TabBar

- **Beschreibung**: Wird in der Assistenten-Detailansicht verwendet, um zwischen Schichten, Verfügbarkeiten und Tags zu wechseln.
- **Ort**: [`lib/views/assistant/assistant_screen.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\assistant\assistant_screen.dart)

---

## 3. Karten (Cards)

### 3.1. ShiftCard

- **Beschreibung**: Zeigt eine einzelne Schicht im Kalender-Detailbereich an. Enthält Informationen zur Schicht und Aktions-Buttons (Zuweisen, Aufteilen, Löschen).
- **Ort**: [`lib/views/planner/shift_card.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\planner\shift_card.dart)

### 3.2. AssistantSidebarCard

- **Beschreibung**: Eine kompakte Karte in der Team-Seitenleiste, die eine Assistenzkraft repräsentiert.
- **Ort**: [`lib/views/assistant/assistant_screen.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\assistant\assistant_screen.dart)

### 3.3. Statistik-Karte

- **Beschreibung**: Eine kleine Karte in der Assistenten-Detailansicht, die eine einzelne Statistik (z.B. geplante Schichten) anzeigt.
- **Implementierung**: `_buildStatCard` in [`lib/views/assistant/assistant_screen.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\assistant\assistant_screen.dart)

---

## 4. Indikatoren & Marker

### 4.1. AssistantMarker

- **Beschreibung**: Ein kreisförmiger Marker mit dem Initial der Assistenzkraft. Wird im Kalender und in Listen verwendet. Passt seine Größe je nach Kontext an.
- **Ort**: [`lib/views/shared/markers.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\shared\markers.dart)

### 4.2. CalendarDayMarker

- **Beschreibung**: Ein komplexes Widget, das innerhalb einer Kalenderzelle die Schicht- und Verfügbarkeits-Marker für diesen Tag anzeigt.
- **Implementierung**: `buildDayMarker` in [`lib/views/shared/markers.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\shared\markers.dart)

### 4.3. Fortschrittsanzeige (Verfügbarkeiten)

- **Beschreibung**: Zeigt den Fortschritt der eingereichten Verfügbarkeiten für den nächsten Monat an. Besteht aus einer Liste von `AssistantMarker` und einem `LinearProgressIndicator`.
- **Ort**: [`lib/views/planner/planner_screen.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\planner\planner_screen.dart)

### 4.4. Chips (Tags)

- **Beschreibung**: Wird zur Anzeige von zugewiesenen Tags in der Assistenten-Detailansicht verwendet.
- **Ort**: `_buildTagsTab` in [`lib/views/assistant/assistant_screen.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\assistant\assistant_screen.dart)

---

## 5. Aktionen & Dialoge

### 5.1. Buttons

- **ElevatedButton**: Standard-Button für primäre Aktionen in Dialogen.
- **TextButton**: Sekundärer Button, z.B. für "Abbrechen".
- **IconButton**: Für Aktionen ohne Text, z.B. in der `AppBar` oder den Testdaten-Buttons.
- **FloatingActionButton**: Zum Hinzufügen neuer Elemente.

### 5.2. Dialoge

- **AlertDialog**: Wird für Bestätigungen (Löschen, Archivieren) und zum Hinzufügen neuer Entitäten (z.B. `AddAssistantForm`) verwendet.
- **Implementierung**: `showDialog` mit `AlertDialog` als Builder.
- **Ort**: [`lib/views/assistant/assistant_screen.dart`](c:\Users\alenn\Praxisprojekt_AssistenzDienstplaner\DerAssistenzplaner_APP\der_assistenzplaner\lib\views\assistant\assistant_screen.dart)

---

## 6. Kalender

### 6.1. Kalender-Zellen

- **Beschreibung**: Das Aussehen der einzelnen Tage im Kalender