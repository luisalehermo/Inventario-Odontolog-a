import 'package:flutter/material.dart';

class EstadisticasGeneralesForm extends StatelessWidget {
  const EstadisticasGeneralesForm({super.key});

  @override
  Widget build(BuildContext context) {
    final Color azulUSM = const Color(0xFF2B27A1);

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Estadísticas Generales",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: azulUSM,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 100, color: Colors.grey),
                  Text(
                    "Gráfico de flujo mensual (Enero - Diciembre)",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
