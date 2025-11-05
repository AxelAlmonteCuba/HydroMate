import 'package:flutter/material.dart';
import '../../data/models/operation_mode.dart';

class ModeSelector extends StatelessWidget {
  final OperationMode currentMode;
  final bool isLoading;
  final Function(OperationMode) onModeChanged;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.isLoading,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Modo de Operación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selector de modo
            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    icon: Icons.touch_app,
                    label: 'Manual',
                    mode: OperationMode.manual,
                    isSelected: currentMode == OperationMode.manual,
                    isEnabled: !isLoading,
                    onTap: () => onModeChanged(OperationMode.manual),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeButton(
                    icon: Icons.settings_suggest,
                    label: 'Automático',
                    mode: OperationMode.automatic,
                    isSelected: currentMode == OperationMode.automatic,
                    isEnabled: !isLoading,
                    onTap: () => onModeChanged(OperationMode.automatic),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Descripción del modo actual
            _ModeDescription(mode: currentMode),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final OperationMode mode;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.mode,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.blue : Colors.grey;
    
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isEnabled ? color : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isEnabled ? color : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeDescription extends StatelessWidget {
  final OperationMode mode;

  const _ModeDescription({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isAutomatic = mode == OperationMode.automatic;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAutomatic ? Colors.blue[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAutomatic ? Colors.blue[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: isAutomatic ? Colors.blue[700] : Colors.orange[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAutomatic
                  ? 'El sistema activará el riego automáticamente según los umbrales configurados'
                  : 'Controla la bomba manualmente desde la aplicación',
              style: TextStyle(
                fontSize: 12,
                color: isAutomatic ? Colors.blue[700] : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}