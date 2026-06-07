import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/validators.dart';
import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';
import 'package:shapeup/features/products/providers/products_provider.dart';

class ProductDialogWidget extends ConsumerStatefulWidget {
  const ProductDialogWidget({super.key, this.product});

  final CustomProductEntity? product;

  @override
  ConsumerState<ProductDialogWidget> createState() => _ProductDialogWidgetState();
}

class _ProductDialogWidgetState extends ConsumerState<ProductDialogWidget> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController name;
  late final TextEditingController calories;
  late final TextEditingController proteins;
  late final TextEditingController fats;
  late final TextEditingController carbs;
  final GlobalKey<ScaffoldMessengerState> _dialogMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String _formatNumber(double value, int decimals) {
    return value.toStringAsFixed(decimals);
  }

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.product?.name ?? '');
    calories = TextEditingController(
      text: widget.product == null
          ? ''
          : _formatNumber(widget.product!.calories, 2),
    );
    proteins = TextEditingController(
      text: widget.product == null
          ? ''
          : _formatNumber(widget.product!.proteins, 2),
    );
    fats = TextEditingController(
      text:
          widget.product == null ? '' : _formatNumber(widget.product!.fats, 2),
    );
    carbs = TextEditingController(
      text:
          widget.product == null ? '' : _formatNumber(widget.product!.carbs, 2),
    );
  }

  @override
  void dispose() {
    name.dispose();
    calories.dispose();
    proteins.dispose();
    fats.dispose();
    carbs.dispose();
    super.dispose();
  }

  double d(TextEditingController c) {
    return _nonNegativeDouble(c)!;
  }

  double? _nonNegativeDouble(TextEditingController controller) {
    return ref.read(productsControllerProvider).nonNegativeNumberFromText(controller.text);
  }

  double? _caloriesFromMacros() {
    return ref.read(productsControllerProvider).caloriesFromMacros(
      proteins: _nonNegativeDouble(proteins),
      fats: _nonNegativeDouble(fats),
      carbs: _nonNegativeDouble(carbs),
    );
  }

  String? _macroCaloriesText() {
    final calculated = _caloriesFromMacros();

    if (calculated == null) {
      return null;
    }

    return 'Калории по БЖУ: ${calculated.toStringAsFixed(2)} ккал';
  }

  bool get _canSaveProduct {
    return ref.read(productsControllerProvider).canSaveProduct(
      name: name.text,
      calories: _nonNegativeDouble(calories),
      proteins: _nonNegativeDouble(proteins),
      fats: _nonNegativeDouble(fats),
      carbs: _nonNegativeDouble(carbs),
    );
  }

  String _cleanErrorText(Object error) {
    return russianErrorMessage(error);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return ScaffoldMessenger(
      key: _dialogMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              void refreshButton() {
                _dialogMessengerKey.currentState?.hideCurrentSnackBar();
                setDialogState(() {});
              }

              void showProductError(Object error) {
                final messenger = _dialogMessengerKey.currentState;
                if (messenger == null) return;

                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(_cleanErrorText(error)),
                    ),
                  );
              }

              return AlertDialog(
                title: Text(isEdit ? 'Редактировать продукт' : 'Новый продукт'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 9,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: name,
                          decoration:
                              const InputDecoration(labelText: 'Название'),
                          validator: Validators.requiredText,
                          onChanged: (_) => refreshButton(),
                        ),
                        TextFormField(
                          controller: calories,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(labelText: 'Калории'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                        if (_macroCaloriesText() != null) ...[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _macroCaloriesText()!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        TextFormField(
                          controller: proteins,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Белки'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                        TextFormField(
                          controller: fats,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Жиры'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                        TextFormField(
                          controller: carbs,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(labelText: 'Углеводы'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: _canSaveProduct
                        ? () async {
                            if (!formKey.currentState!.validate()) return;

                            FocusManager.instance.primaryFocus?.unfocus();

                            try {
                              if (isEdit) {
                                await ref
                                    .read(productsControllerProvider)
                                    .updateProduct(
                                      id: widget.product!.id,
                                      name: name.text.trim(),
                                      calories: d(calories),
                                      proteins: d(proteins),
                                      fats: d(fats),
                                      carbs: d(carbs),
                                    );
                              } else {
                                await ref
                                    .read(productsControllerProvider)
                                    .createProduct(
                                      name: name.text.trim(),
                                      calories: d(calories),
                                      proteins: d(proteins),
                                      fats: d(fats),
                                      carbs: d(carbs),
                                    );
                              }

                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (!context.mounted) return;

                              showProductError(e);
                            }
                          }
                        : null,
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
