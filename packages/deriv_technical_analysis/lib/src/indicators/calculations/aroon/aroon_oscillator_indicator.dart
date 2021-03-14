import 'package:deriv_technical_analysis/src/indicators/calculations/aroon/aroon_down_indicator.dart';

import '../../../../deriv_technical_analysis.dart';
import 'aroon_up_indicator.dart';

/// Calculates the value for Aroon Oscillator Indicator.
class AroonOscillatorIndicator<T extends IndicatorResult>
    extends CachedIndicator<T?> {
  /// Initializes
  AroonOscillatorIndicator.fromIndicator(IndicatorDataInput indicatorDataInput,
      {int period = 14})
      : _upChannel = AroonDownIndicator<T>.fromIndicator(
            LowValueIndicator<T>(indicatorDataInput),
            period: period),
        _downChannel = AroonUpIndicator<T>.fromIndicator(
          HighValueIndicator<T>(indicatorDataInput),
          period: period,
        ),
        super(indicatorDataInput);

  /// Aroon up channel indicator.
  final Indicator<T?> _upChannel;

  /// Aroon down channel indicator.
  final Indicator<T?> _downChannel;

  @override
  T? calculate(int index) => createResult(
      index: index,
      quote: _upChannel.getValue(index)!.quote! -
          _downChannel.getValue(index)!.quote!);
}
