import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmDetailsStep extends ConsumerStatefulWidget {
  const FarmDetailsStep({super.key});

  @override
  ConsumerState<FarmDetailsStep> createState() => _FarmDetailsStepState();
}

class _FarmDetailsStepState extends ConsumerState<FarmDetailsStep> {
  static const double _fieldRadius = 12;

  late final TextEditingController stateController;
  late final TextEditingController districtController;
  late final TextEditingController villageController;
  late final TextEditingController pincodeController;
  late final TextEditingController landAreaController;

  final stateFocus = FocusNode();
  final districtFocus = FocusNode();
  final villageFocus = FocusNode();
  final pincodeFocus = FocusNode();
  final landFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final registerState = ref.read(registerProvider);
    stateController = TextEditingController(text: registerState.stateName);
    districtController = TextEditingController(text: registerState.district);
    villageController = TextEditingController(text: registerState.village);
    pincodeController = TextEditingController(text: registerState.pincode);
    landAreaController = TextEditingController(text: registerState.landArea);
  }

  @override
  void dispose() {
    stateController.dispose();
    districtController.dispose();
    villageController.dispose();
    pincodeController.dispose();
    landAreaController.dispose();
    stateFocus.dispose();
    districtFocus.dispose();
    villageFocus.dispose();
    pincodeFocus.dispose();
    landFocus.dispose();
    super.dispose();
  }

  void nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  void _updateFarm({
    String? stateName,
    String? district,
    String? village,
    String? pincode,
    String? landArea,
  }) {
    ref.read(registerProvider.notifier).updateFarmDetails(
          stateName: stateName,
          district: district,
          village: village,
          pincode: pincode,
          landArea: landArea,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Farm Details', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        TextFormField(
          controller: stateController,
          focusNode: stateFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(districtFocus),
          onChanged: (value) => _updateFarm(stateName: value),
          decoration: InputDecoration(
            hintText: 'State',
            prefixIcon: Icon(Icons.map, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: districtController,
          focusNode: districtFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(villageFocus),
          onChanged: (value) => _updateFarm(district: value),
          decoration: InputDecoration(
            hintText: 'District',
            prefixIcon: Icon(Icons.location_city, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: villageController,
          focusNode: villageFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(pincodeFocus),
          onChanged: (value) => _updateFarm(village: value),
          decoration: InputDecoration(
            hintText: 'Village',
            prefixIcon: Icon(Icons.home, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: pincodeController,
          focusNode: pincodeFocus,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(landFocus),
          onChanged: (value) => _updateFarm(pincode: value),
          decoration: InputDecoration(
            hintText: 'Pincode',
            prefixIcon: Icon(Icons.location_pin, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: landAreaController,
          focusNode: landFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => landFocus.unfocus(),
          onChanged: (value) => _updateFarm(landArea: value),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
          ],
          decoration: InputDecoration(
            hintText: 'Land Area',
            prefixIcon: Icon(Icons.agriculture, color: primary),
            suffixText: 'Acres',
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
      ],
    );
  }
}
