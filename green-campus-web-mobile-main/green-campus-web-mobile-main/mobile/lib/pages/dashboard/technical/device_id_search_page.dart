import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/data/services/technical_services.dart';

/// Página de listado y búsqueda de dispositivos IoT.
///
/// Permite filtrar por nombre (input en tiempo real) y por tipo de nodo
/// (chips: Todos / RASPBERRY / ARDUINO / TEMPERATURA / HUMEDAD / CO2).
/// Al pulsar un nodo RASPBERRY o ARDUINO navega a /hardware-device-details.
/// Al pulsar un nodo sensor navega a /device-details pasando el IotNode.
class DeviceIdSearchPage extends StatefulWidget {
  const DeviceIdSearchPage({super.key});

  @override
  State<DeviceIdSearchPage> createState() => _DeviceIdSearchPageState();
}

// Tipos de filtro disponibles en los chips
enum _NodeTypeFilter { todos, raspberry, arduino, temperatura, humedad, co2 }

class _DeviceIdSearchPageState extends State<DeviceIdSearchPage> {
  final _searchController = TextEditingController();
  final _service = TechnicalServices();

  List<IotNode> _allNodes = [];
  bool _isLoadingList = true;
  String? _listError;

  _NodeTypeFilter _selectedFilter = _NodeTypeFilter.todos;

  @override
  void initState() {
    super.initState();
    _loadAllNodes();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Carga inicial ─────────────────────────────────────────────────────────

  Future<void> _loadAllNodes() async {
    setState(() {
      _isLoadingList = true;
      _listError = null;
    });
    try {
      final response = await _service.getNodes();
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        setState(() {
          _allNodes = list.map((e) => IotNode.fromJson(e)).toList();
        });
      } else {
        setState(() => _listError =
            'HTTP ${response.statusCode}: ${response.body.substring(0, response.body.length.clamp(0, 120))}');
      }
    } catch (e) {
      if (mounted) setState(() => _listError = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingList = false);
    }
  }

  // ── Filtrado ──────────────────────────────────────────────────────────────

  bool _matchesTypeFilter(IotNode node) {
    final combined = (node.name + node.type).toLowerCase();
    switch (_selectedFilter) {
      case _NodeTypeFilter.todos:
        return true;
      case _NodeTypeFilter.raspberry:
        return combined.contains('raspberry');
      case _NodeTypeFilter.arduino:
        return combined.contains('arduino');
      case _NodeTypeFilter.temperatura:
        return combined.contains('tem');
      case _NodeTypeFilter.humedad:
        return combined.contains('hum');
      case _NodeTypeFilter.co2:
        return combined.contains('co2') || combined.contains('calidad');
    }
  }

  List<IotNode> get _filteredNodes {
    final query = _searchController.text.trim().toLowerCase();
    return _allNodes.where((node) {
      final matchesType = _matchesTypeFilter(node);
      final matchesName = query.isEmpty ||
          node.name.toLowerCase().contains(query) ||
          node.location.toLowerCase().contains(query);
      return matchesType && matchesName;
    }).toList();
  }

  // ── Navegación ────────────────────────────────────────────────────────────

  void _openNode(IotNode node) {
    final type = (node.name + node.type).toLowerCase();
    if (type.contains('raspberry') || type.contains('arduino')) {
      Navigator.pushNamed(context, '/hardware-device-details', arguments: node);
    } else {
      Navigator.pushNamed(context, '/device-details', arguments: node);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Dispositivos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary, size: 22),
            onPressed: _isLoadingList ? null : _loadAllNodes,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // ── Buscador por nombre ────────────────────────────────────────
          _buildSearchBar(),

          // ── Chips de tipo ──────────────────────────────────────────────
          _buildTypeFilterChips(),

          const Divider(height: 1, color: AppColors.border),

          // ── Cabecera de sección ────────────────────────────────────────
          _buildListHeader(),

          // ── Lista filtrada ─────────────────────────────────────────────
          Expanded(child: _buildNodeList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o ubicación…',
          hintStyle: const TextStyle(
            fontFamily: 'JetBrains Mono',
            color: AppColors.textMuted,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.accentGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterChips() {
    const chips = [
      (_NodeTypeFilter.todos, 'Todos', Icons.apps_rounded),
      (_NodeTypeFilter.raspberry, 'Raspberry', Icons.developer_board_rounded),
      (_NodeTypeFilter.arduino, 'Arduino', Icons.memory_rounded),
      (_NodeTypeFilter.temperatura, 'Temperatura', Icons.thermostat_rounded),
      (_NodeTypeFilter.humedad, 'Humedad', Icons.water_drop_rounded),
      (_NodeTypeFilter.co2, 'CO2', Icons.air_rounded),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label, icon) = chips[index];
          final selected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color:
                    selected ? AppColors.accentGreen : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.accentGreen
                      : AppColors.inputBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'DISPOSITIVOS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          if (!_isLoadingList && _allNodes.isNotEmpty)
            Text(
              '${_filteredNodes.length} de ${_allNodes.length}',
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textMuted,
                fontFamily: 'JetBrains Mono',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeList() {
    if (_isLoadingList) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentGreen),
      );
    }

    if (_listError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                _listError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _loadAllNodes,
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.accentGreen),
                label: const Text('Reintentar',
                    style: TextStyle(color: AppColors.accentGreen)),
              ),
            ],
          ),
        ),
      );
    }

    final nodes = _filteredNodes;

    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              _allNodes.isEmpty
                  ? 'No hay dispositivos disponibles.'
                  : 'Sin resultados para los filtros aplicados.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: nodes.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) => _buildNodeTile(nodes[index]),
    );
  }

  Widget _buildNodeTile(IotNode node) {
    final typeLabel = _resolveTypeLabel(node);
    final typeColor = _resolveTypeColor(node);

    return InkWell(
      onTap: () => _openNode(node),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Punto de estado
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor(node.status),
              ),
            ),
            const SizedBox(width: 12),
            // Información del nodo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${node.name} · ${node.location}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${node.id}  ·  ',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      // Badge de tipo
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.battery_charging_full_rounded,
                          size: 12, color: AppColors.textMuted),
                      Text(
                        ' ${node.battery}%',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  /// Devuelve la etiqueta canónica del tipo de nodo para el badge.
  String _resolveTypeLabel(IotNode node) {
    final combined = (node.name + node.type).toLowerCase();
    if (combined.contains('raspberry')) return 'RASPBERRY';
    if (combined.contains('arduino')) return 'ARDUINO';
    if (combined.contains('tem')) return 'TEMPERATURA';
    if (combined.contains('hum')) return 'HUMEDAD';
    if (combined.contains('co2') || combined.contains('calidad')) return 'CO2';
    return node.type.toUpperCase();
  }

  /// Color asociado a cada categoría de nodo.
  Color _resolveTypeColor(IotNode node) {
    final combined = (node.name + node.type).toLowerCase();
    if (combined.contains('raspberry') || combined.contains('arduino')) {
      return Colors.indigo;
    }
    if (combined.contains('tem')) return Colors.orange;
    if (combined.contains('hum')) return Colors.blue;
    if (combined.contains('co2') || combined.contains('calidad')) {
      return Colors.purple;
    }
    return AppColors.textMuted;
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return AppColors.statusOnline;
      case 'STANDBY':
        return AppColors.statusWarning;
      case 'OFFLINE':
        return AppColors.statusOffline;
      default:
        return AppColors.textMuted;
    }
  }
}
