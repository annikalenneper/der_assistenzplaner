import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:der_assistenzplaner/data/models/shift.dart';
import 'package:der_assistenzplaner/viewmodels/shift_model.dart';
import 'package:der_assistenzplaner/viewmodels/availabilities_model.dart';
import 'package:der_assistenzplaner/viewmodels/assistant_model.dart';

/// Service zum automatischen Generieren eines **Vorab‑Dienstplans**.
///
/// * **rein in Dart / Flutter** – kein REST‑Backend nötig
/// * verteilt alle noch offenen Schichten im angegebenen Zeitraum **möglichst gleichmäßig**
/// * nutzt Verfügbarkeiten (Shift ⇢ Set<AssistantID>) und vermeidet Zeitüberschneidungen
/// * schreibt das Ergebnis **nur in den Preview‑Modus** (→ `ShiftModel.startPreviewMode`)
///   damit der User prüfen und erst danach dauerhaft speichern kann
class WorkscheduleService {
  WorkscheduleService(this.context);

  //--------------------------------------------------------------------
  // public
  //--------------------------------------------------------------------

  final BuildContext context;
  final Random _rng = Random();

  /// Generiert einen Plan und gibt die **zugewiesenen Shift‑Kopien** zurück.
  ///
  /// *Wenn* [activatePreview] `true` ist (Default), wird zusätzlich
  /// `ShiftModel.startPreviewMode()` aufgerufen, damit das UI direkt die
  /// Vorschau anzeigen kann.
  Future<List<Shift>> generateWorkschedule({
    DateTime? startDate,
    DateTime? endDate,
    bool activatePreview = true, // Du brauchst Preview nicht mehr
  }) async {
    //------------------------------------------------------------------
    // 0) Zeitraum bestimmen   (Default: kompletter laufender Monat)
    //------------------------------------------------------------------
    startDate ??= DateTime(DateTime.now().year, DateTime.now().month, 1);
    endDate   ??= DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    dev.log('[Workschedule] Zeitraum: $startDate → $endDate');

    //------------------------------------------------------------------
    // 1) Provider‑Daten holen
    //------------------------------------------------------------------
    final shiftsVm   = Provider.of<ShiftModel>(context, listen: false);
    final availVm    = Provider.of<AvailabilitiesModel>(context, listen: false);
    final assistVm   = Provider.of<AssistantModel>(context, listen: false);

    // offene Schichten einsammeln
    final openShifts = _filterUnscheduled(shiftsVm, startDate, endDate);

    final shiftAvail        = _makeShiftAvailIndex(availVm, openShifts);
    final assistantWorkload = _initWorkload(assistVm);
    final assistantShifts   = <String, List<Shift>>{};
    final targetHours       = _calcTargetHours(openShifts, assistVm.assistants.length);

    // sortieren …
    openShifts.sort((a, b) {
      final diff = (shiftAvail[a.shiftID]!.length) - (shiftAvail[b.shiftID]!.length);
      return diff != 0 ? diff : a.start.compareTo(b.start);
    });

    final List<Shift> assigned = [];

    for (final shift in openShifts) {
      final bestId = _pickBestAssistant(
        shift,
        shiftAvail[shift.shiftID]!,
        assistantShifts,
        assistantWorkload,
        targetHours,
      );
      if (bestId == null) {
        dev.log('[Workschedule] kein Assistent für ${shift.shiftID}');
        continue;
      }

      // *** HIER das Update in Dein ViewModel ***
      await shiftsVm.updateShift(
        shift,
        newAssistantID: bestId,
      );
      assigned.add( shift.copyWith(assistantID: bestId) );

      // Hilfsstrukturen updaten (für Conflict-Check)
      assistantShifts.putIfAbsent(bestId, () => []).add(shift);
      assistantWorkload[bestId] = (assistantWorkload[bestId] ?? 0) + _shiftHours(shift);

      dev.log('[Workschedule] zugewiesen ${shift.shiftID} → $bestId');
    }

    dev.log('[Workschedule] fertig: ${assigned.length}/${openShifts.length}');

    return assigned;
  }

  //--------------------------------------------------------------------
  // private helper
  //--------------------------------------------------------------------

  List<Shift> _filterUnscheduled(
    ShiftModel vm,
    DateTime start,
    DateTime end,
  ) {
    return vm.unscheduledShifts.where((s) {
      return !s.start.isBefore(start) && !s.start.isAfter(end);
    }).toList();
  }

  Map<String, Set<String>> _makeShiftAvailIndex(
    AvailabilitiesModel vm,
    List<Shift> shifts,
  ) {
    final map = <String, Set<String>>{};
    for (final s in shifts) {
      map[s.shiftID] = vm.getAvailableAssistantsForShift(s.shiftID);
    }
    return map;
  }

  Map<String, double> _initWorkload(AssistantModel vm) =>
      {for (final a in vm.assistants) a.assistantID: a.deviation};

  double _calcTargetHours(List<Shift> shifts, int assistantCount) {
    if (assistantCount == 0) return 0;
    final total = shifts.fold<double>(0, (sum, s) => sum + _shiftHours(s));
    return total / assistantCount;
  }

  double _shiftHours(Shift s) => s.end.difference(s.start).inMinutes / 60.0;

  bool _overlaps(Shift a, Shift b) =>
      a.start.isBefore(b.end) && b.start.isBefore(a.end);

  bool _hasConflict(String id, Shift newShift, Map<String, List<Shift>> map) {
    final list = map[id] ?? const [];
    for (final s in list) {
      if (_overlaps(s, newShift)) return true;
    }
    return false;
  }

  String? _pickBestAssistant(
    Shift shift,
    Set<String> candidates,
    Map<String, List<Shift>> assistantShifts,
    Map<String, double> workload,
    double targetHours,
  ) {
    if (candidates.isEmpty) return null;

    String? best;
    double? bestScore;

    for (final id in candidates) {
      if (_hasConflict(id, shift, assistantShifts)) continue;

      final current = workload[id] ?? 0;
      final projected = current + _shiftHours(shift);
      final deviation = (projected - targetHours).abs();
      final score = deviation + (current > targetHours ? deviation * 0.5 : 0) + _rng.nextDouble() * 0.0001;

      if (bestScore == null || score < bestScore) {
        bestScore = score;
        best = id;
      }
    }
    return best;
  }
}
