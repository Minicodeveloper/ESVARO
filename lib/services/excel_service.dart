import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/cliente.dart';
import '../models/guia.dart';
import '../models/tracking.dart';
import 'firebase_service.dart';

// Importación condicional para web/mobile
import 'excel_save_stub.dart'
    if (dart.library.html) 'excel_save_web.dart'
    if (dart.library.io) 'excel_save_mobile.dart' as saver;

class ExcelService {
  // ==================== IMPORTAR CLIENTES ====================
  static Future<int> importarClientes() async {
    final bytes = await _pickExcelFile();
    if (bytes == null) return 0;
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;
    int importados = 0;
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;
      final nombre = _cellStr(row, 0);
      if (nombre.isEmpty) continue;
      await FirebaseService.crearCliente(Cliente(
        clienteId: '',
        nombreComercial: nombre,
        tipoCliente: _cellStr(row, 1).isNotEmpty ? _cellStr(row, 1) : 'natural',
        dniRuc: _cellStr(row, 2),
        telefono: _cellStr(row, 3),
        email: _cellStr(row, 4),
        estado: 'activo',
      ));
      importados++;
    }
    return importados;
  }

  // ==================== IMPORTAR GUÍAS + TRACKINGS ====================
  static Future<int> importarGuiasTrackings(String vueloId) async {
    final bytes = await _pickExcelFile();
    if (bytes == null) return 0;
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;
    int importados = 0;
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.isEmpty || row[0]?.value == null) continue;
      final numGuia = _cellStr(row, 0);
      if (numGuia.isEmpty) continue;
      final clienteNombre = _cellStr(row, 1);
      final consigNombre = _cellStr(row, 2);
      final bultos = int.tryParse(_cellStr(row, 3)) ?? 1;
      final tracking = _cellStr(row, 4);

      final guia = Guia(
        guiaId: '', vueloId: vueloId, clienteId: '', consignatarioId: '',
        numeroGuia: numGuia, almacenMiami: '', clienteNombre: clienteNombre, consignatarioNombre: consigNombre,
        bultosEsperados: bultos, bultosRecibidos: 0,
        estadoLogistico: 'pendiente_retiro', estadoFinanciero: 'pendiente', estadoEntrega: 'pendiente',
      );
      final guiaId = await FirebaseService.crearGuia(guia);

      if (tracking.isNotEmpty) {
        final trackings = tracking.split(',');
        for (final t in trackings) {
          if (t.trim().isEmpty) continue;
          await FirebaseService.crearTracking(Tracking(
            trackingId: '', guiaId: guiaId, numeroTracking: t.trim(),
            estado: 'pendiente',
          ));
        }
      }
      importados++;
    }
    return importados;
  }

  // ==================== EXPORTAR CLIENTES ====================
  static Future<void> exportarClientes() async {
    final clientes = await FirebaseService.getClientesActivos();
    final excel = Excel.createExcel();
    final sheet = excel['Clientes'];
    sheet.appendRow([TextCellValue('Nombre'), TextCellValue('Tipo'), TextCellValue('DNI/RUC'), TextCellValue('Teléfono'), TextCellValue('Email'), TextCellValue('Estado')]);
    for (final c in clientes) {
      sheet.appendRow([TextCellValue(c.nombreComercial), TextCellValue(c.tipoCliente), TextCellValue(c.dniRuc), TextCellValue(c.telefono), TextCellValue(c.email), TextCellValue(c.estado)]);
    }
    excel.delete('Sheet1');
    await _saveExcel(excel, 'clientes_export');
  }

  // ==================== EXPORTAR GUÍAS ====================
  static Future<void> exportarGuias() async {
    final guias = await FirebaseService.getGuias();
    final excel = Excel.createExcel();
    final sheet = excel['Guias'];
    sheet.appendRow([TextCellValue('N° Guía'), TextCellValue('Cliente'), TextCellValue('Consignatario'), TextCellValue('Bultos Esp.'), TextCellValue('Bultos Rec.'), TextCellValue('Est. Logístico'), TextCellValue('Est. Financiero'), TextCellValue('Est. Entrega')]);
    for (final g in guias) {
      sheet.appendRow([TextCellValue(g.numeroGuia), TextCellValue(g.clienteNombre ?? ''), TextCellValue(g.consignatarioNombre ?? ''), IntCellValue(g.bultosEsperados), IntCellValue(g.bultosRecibidos), TextCellValue(g.estadoLogistico), TextCellValue(g.estadoFinanciero), TextCellValue(g.estadoEntrega)]);
    }
    excel.delete('Sheet1');
    await _saveExcel(excel, 'guias_export');
  }

  // ==================== EXPORTAR VUELOS ====================
  static Future<void> exportarVuelos() async {
    final vuelos = await FirebaseService.getVuelos();
    final excel = Excel.createExcel();
    final sheet = excel['Vuelos'];
    sheet.appendRow([TextCellValue('Manifiesto'), TextCellValue('Almacén'), TextCellValue('Fecha Llegada'), TextCellValue('Estado')]);
    for (final v in vuelos) {
      sheet.appendRow([TextCellValue(v.numeroManifiesto), TextCellValue(v.almacenMiami), TextCellValue('${v.fechaLlegada.day}/${v.fechaLlegada.month}/${v.fechaLlegada.year}'), TextCellValue(v.estado)]);
    }
    excel.delete('Sheet1');
    await _saveExcel(excel, 'vuelos_export');
  }

  // ==================== EXPORTAR INCIDENCIAS ====================
  static Future<void> exportarIncidencias() async {
    final incidencias = await FirebaseService.getIncidencias();
    final excel = Excel.createExcel();
    final sheet = excel['Incidencias'];
    sheet.appendRow([TextCellValue('Guía'), TextCellValue('Tipo'), TextCellValue('Descripción'), TextCellValue('Estado'), TextCellValue('Cliente'), TextCellValue('Fecha')]);
    for (final i in incidencias) {
      sheet.appendRow([TextCellValue(i.numeroGuia ?? ''), TextCellValue(i.tipo), TextCellValue(i.descripcion), TextCellValue(i.estado), TextCellValue(i.clienteNombre ?? ''), TextCellValue('${i.fechaCreacion.day}/${i.fechaCreacion.month}/${i.fechaCreacion.year}')]);
    }
    excel.delete('Sheet1');
    await _saveExcel(excel, 'incidencias_export');
  }

  // ==================== EXPORTAR LIQUIDACIONES ====================
  static Future<void> exportarLiquidaciones() async {
    final liquidaciones = await FirebaseService.getLiquidaciones();
    final excel = Excel.createExcel();
    final sheet = excel['Liquidaciones'];
    sheet.appendRow([TextCellValue('Cliente'), TextCellValue('Manifiesto'), TextCellValue('Monto'), TextCellValue('Estado'), TextCellValue('Fecha'), TextCellValue('Guías')]);
    for (final l in liquidaciones) {
      sheet.appendRow([TextCellValue(l.clienteNombre ?? ''), TextCellValue(l.numeroManifiesto ?? ''), DoubleCellValue(l.montoTotal), TextCellValue(l.estado), TextCellValue('${l.fechaLiquidacion.day}/${l.fechaLiquidacion.month}/${l.fechaLiquidacion.year}'), IntCellValue(l.guiasIds.length)]);
    }
    excel.delete('Sheet1');
    await _saveExcel(excel, 'liquidaciones_export');
  }

  // ==================== EXPORTAR ENTREGAS ====================
  static Future<void> exportarEntregas() async {
    final entregas = await FirebaseService.getEntregas();
    final excel = Excel.createExcel();
    final sheet = excel['Entregas'];
    sheet.appendRow([TextCellValue('Guía'), TextCellValue('Cliente'), TextCellValue('Consignatario'), TextCellValue('Tipo'), TextCellValue('Estado'), TextCellValue('Receptor'), TextCellValue('DNI')]);
    for (final e in entregas) {
      sheet.appendRow([TextCellValue(e.numeroGuia ?? ''), TextCellValue(e.clienteNombre ?? ''), TextCellValue(e.consignatarioNombre ?? ''), TextCellValue(e.tipoEntrega), TextCellValue(e.estado), TextCellValue(e.nombreReceptor ?? ''), TextCellValue(e.dniReceptor ?? '')]);
    }
    excel.delete('Sheet1');
    await _saveExcel(excel, 'entregas_export');
  }

  // ==================== HELPERS ====================
  static Future<List<int>?> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls'], withData: true);
    if (result == null || result.files.isEmpty) return null;
    return result.files.first.bytes;
  }

  static String _cellStr(List<Data?> row, int index) {
    if (index >= row.length || row[index] == null) return '';
    return row[index]!.value?.toString() ?? '';
  }

  static Future<void> _saveExcel(Excel excel, String name) async {
    final bytes = excel.encode();
    if (bytes == null) return;
    await saver.saveExcelFile(Uint8List.fromList(bytes), '$name.xlsx');
  }
}
