import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmDetailsStep extends ConsumerStatefulWidget {
  const FarmDetailsStep({super.key});

  @override
  ConsumerState<FarmDetailsStep> createState() =>
      _FarmDetailsStepState();
}

class _FarmDetailsStepState
    extends ConsumerState<FarmDetailsStep> {
  final stateFocus = FocusNode();
  final districtFocus = FocusNode();
  final villageFocus = FocusNode();
  final pincodeFocus = FocusNode();
  final landFocus = FocusNode();

  void nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  @override
  void dispose() {
    stateFocus.dispose();
    districtFocus.dispose();
    villageFocus.dispose();
    pincodeFocus.dispose();
    landFocus.dispose();
    super.dispose();
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
        Text("Farm Details",
            style: theme.textTheme.titleLarge),

        const SizedBox(height: 20),

        /// 🔹 State
        TextFormField(
          focusNode: stateFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(districtFocus),
          decoration: InputDecoration(
            hintText: "State",
            prefixIcon: Icon(Icons.map, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onChanged: (val) =>
              ref.read(registerProvider.notifier).state =
                  ref.read(registerProvider)
                      .copyWith(stateName: val),
        ),

        const SizedBox(height: 20),

        /// 🔹 District
        TextFormField(
          focusNode: districtFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(villageFocus),
          decoration: InputDecoration(
            hintText: "District",
            prefixIcon:
                Icon(Icons.location_city, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onChanged: (val) =>
              ref.read(registerProvider.notifier).state =
                  ref.read(registerProvider)
                      .copyWith(district: val),
        ),

        const SizedBox(height: 20),

        /// 🔹 Village
        TextFormField(
          focusNode: villageFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(pincodeFocus),
          decoration: InputDecoration(
            hintText: "Village",
            prefixIcon: Icon(Icons.home, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onChanged: (val) =>
              ref.read(registerProvider.notifier).state =
                  ref.read(registerProvider)
                      .copyWith(village: val),
        ),

        const SizedBox(height: 20),

        /// 🔹 Pincode
        TextFormField(
          focusNode: pincodeFocus,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(landFocus),
          decoration: InputDecoration(
            hintText: "Pincode",
            prefixIcon:
                Icon(Icons.location_pin, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onChanged: (val) =>
              ref.read(registerProvider.notifier).state =
                  ref.read(registerProvider)
                      .copyWith(pincode: val),
        ),

        const SizedBox(height: 20),

        /// 🔹 Land Area
        TextFormField(
          focusNode: landFocus,
          keyboardType:
              const TextInputType.numberWithOptions(
                  decimal: true),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            landFocus.unfocus();
          },
          decoration: InputDecoration(
            hintText: "Land Area (in acres)",
            prefixIcon:
                Icon(Icons.agriculture, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onChanged: (val) =>
              ref.read(registerProvider.notifier).state =
                  ref.read(registerProvider)
                      .copyWith(landArea: val),
        ),
      ],
    );
  }
}