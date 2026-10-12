import 'package:flutter/material.dart';
import 'chart_screen.dart';

// Modelo de Gasto adaptado con fecha real
class GastoItem {
  final String categoria;
  final double monto;
  final String descripcion;
  final DateTime fecha;

  GastoItem({
    required this.categoria,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _categoriaSeleccionada = 'Comida';
  DateTime _fechaSeleccionada = DateTime.now();

  // Lista limpia para que el usuario registre sus propios datos
  final List<GastoItem> _listaGastos = [];

  void _seleccionarFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _agregarGasto() {
    if (_montoController.text.isEmpty) return;
    double? monto = double.tryParse(_montoController.text);

    if (monto != null) {
      setState(() {
        _listaGastos.add(
          GastoItem(
            categoria: _categoriaSeleccionada,
            monto: monto,
            descripcion: _descController.text.isEmpty ? 'Gasto general' : _descController.text,
            fecha: _fechaSeleccionada,
          ),
        );
      });
      _montoController.clear();
      _descController.clear();
      FocusScope.of(context).unfocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gasto registrado con éxito!'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String fechaTexto = "${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 SmartExpense: Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics, color: Color(0xFF0EA5E9), size: 28),
            onPressed: () {
              if (_listaGastos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Agrega al menos un gasto para ver el análisis.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChartScreen(gastos: _listaGastos),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar Nuevo Gasto (COP)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            
            // Fila de Entrada de Monto y Categoría
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _montoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ej. 45000',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButton<String>(
                      value: _categoriaSeleccionada,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1E293B),
                      items: ['Comida', 'Transporte', 'Ocio', 'Servicios']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _categoriaSeleccionada = val!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Selector de Fecha y Botón de Agregar
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: () => _seleccionarFecha(context),
                    icon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF0EA5E9)),
                    label: Text(fechaTexto, style: const TextStyle(color: Colors.white70)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E293B)),
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _agregarGasto,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Agregar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Historial de Movimientos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 10),

            // Lista de Movimientos
            Expanded(
              child: _listaGastos.isEmpty
                  ? const Center(child: Text('No hay gastos registrados. ¡Agrega el primero!', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: _listaGastos.length,
                      itemBuilder: (context, index) {
                        final item = _listaGastos[index];
                        String fechaFmt = "${item.fecha.year}-${item.fecha.month.toString().padLeft(2, '0')}-${item.fecha.day.toString().padLeft(2, '0')}";
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.2),
                              child: const Icon(Icons.wallet, color: Color(0xFF0EA5E9)),
                            ),
                            title: Text(item.categoria, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('$fechaFmt', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            trailing: Text(
                              '\$${item.monto.toStringAsFixed(0)} COP',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.greenAccent),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),

            // Botón para ir al Análisis
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_listaGastos.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Agrega gastos antes de ver el reporte.')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChartScreen(gastos: _listaGastos),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics, color: Colors.white),
                label: const Text('Generar Reporte Gráfico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}