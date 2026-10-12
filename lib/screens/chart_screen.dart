import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_screen.dart';

class ChartScreen extends StatefulWidget {
  final List<GastoItem> gastos;

  const ChartScreen({Key? key, required this.gastos}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  bool _esGraficoDeBarras = true;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  void _seleccionarRango(BuildContext context) async {
    DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (rango != null) {
      setState(() {
        _fechaInicio = rango.start;
        _fechaFin = rango.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filtrar gastos por fecha si hay rango seleccionado
    List<GastoItem> gastosFiltrados = widget.gastos.where((item) {
      if (_fechaInicio == null || _fechaFin == null) return true;
      DateTime itemDate = DateTime(item.fecha.year, item.fecha.month, item.fecha.day);
      DateTime start = DateTime(_fechaInicio!.year, _fechaInicio!.month, _fechaInicio!.day);
      DateTime end = DateTime(_fechaFin!.year, _fechaFin!.month, _fechaFin!.day);
      return itemDate.compareTo(start) >= 0 && itemDate.compareTo(end) <= 0;
    }).toList();

    // 2. Agrupar montos por categoría
    Map<String, double> totales = {
      'Comida': 0.0,
      'Transporte': 0.0,
      'Ocio': 0.0,
      'Servicios': 0.0,
    };

    double sumaTotalGeneral = 0.0;
    for (var item in gastosFiltrados) {
      if (totales.containsKey(item.categoria)) {
        totales[item.categoria] = totales[item.categoria]! + item.monto;
        sumaTotalGeneral += item.monto;
      }
    }

    List<MapEntry<String, double>> categoriasList = totales.entries.toList();

    // 3. Calcular máximo del eje Y para barras
    double maxMonto = 10000.0;
    for (var entry in categoriasList) {
      if (entry.value > maxMonto) {
        maxMonto = entry.value;
      }
    }
    double maxYAxis = maxMonto * 1.2;

    final Map<String, Color> coloresCat = {
      'Comida': Colors.purpleAccent,
      'Transporte': Colors.blueAccent,
      'Ocio': Colors.tealAccent,
      'Servicios': Colors.orangeAccent,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Reporte Financiero (COP)'),
        actions: [
          IconButton(
            icon: Icon(_esGraficoDeBarras ? Icons.pie_chart : Icons.bar_chart, color: Colors.cyanAccent),
            tooltip: 'Cambiar tipo de gráfico',
            onPressed: () {
              setState(() {
                _esGraficoDeBarras = !_esGraficoDeBarras;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Análisis Visual de Proporciones',
                  style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _seleccionarRango(context),
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: const Text('Filtrar Fechas'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: gastosFiltrados.isEmpty
                    ? const Center(child: Text('No hay gastos en este rango de fechas.', style: TextStyle(color: Colors.white54)))
                    : _esGraficoDeBarras
                        ? 
                        // --- GRÁFICO DE BARRAS ---
                        BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxYAxis,
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 && index < categoriasList.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            categoriasList[index].key,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 55,
                                    getTitlesWidget: (value, meta) {
                                      return Text('${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10, color: Colors.white60));
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              barGroups: categoriasList.asMap().entries.map((entry) {
                                int index = entry.key;
                                var categoria = entry.value.key;
                                var montoTotal = entry.value.value;

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: montoTotal,
                                      color: coloresCat[categoria] ?? Colors.white,
                                      width: 26,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        : 
                        // --- GRÁFICO CIRCULAR CON VALOR Y PORCENTAJE REAL ---
                        PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 45,
                              sections: categoriasList.where((e) => e.value > 0).map((entry) {
                                var categoria = entry.key;
                                var monto = entry.value;
                                
                                // Cálculo matemático del porcentaje
                                double porcentaje = sumaTotalGeneral > 0 ? (monto / sumaTotalGeneral) * 100 : 0.0;

                                return PieChartSectionData(
                                  value: monto,
                                  title: '$categoria\n\$${monto.toStringAsFixed(0)}\n(${porcentaje.toStringAsFixed(1)}%)',
                                  color: coloresCat[categoria] ?? Colors.white,
                                  radius: 105,
                                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                );
                              }).toList(),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}