double roundTo(double value, int decimals) {
  var factor = 1.0;
  for (var i = 0; i < decimals; i++) {
    factor *= 10.0;
  }
  return (value * factor).roundToDouble() / factor;
}

double roundTo0(double value) => roundTo(value, 0);

double roundTo1(double value) => roundTo(value, 1);

double roundKbju(double value) => roundTo(value, 2);

double roundGrams(double value) => roundTo(value, 1);
