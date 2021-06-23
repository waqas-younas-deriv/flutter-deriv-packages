import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/difference_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/previous_value_indicator.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';
import 'package:flutter/material.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Detrended Price Oscillator Indicator
class DPOIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes From the given [Indicator].
  factory DPOIndicator(
    Indicator<T> indicator,
    CachedIndicator<T> Function(Indicator<T> indicator) getMAIndicator, {
    int period = 14,
    bool isCentered = true,
  }) =>
      DPOIndicator<T>._(
        indicator,
        getMAIndicator(indicator),
        timeShift: period ~/ 2 + 1,
        isCentered: isCentered,
      );

  DPOIndicator._(
    this.indicator,
    this._maIndicator, {
    @required int timeShift,
    bool isCentered = true,
  })  : _indicatorMinusPreviousSMAIndicator = isCentered
            ? DifferenceIndicator<T>(
                _maIndicator,
                PreviousValueIndicator<T>.fromIndicator(
                  indicator,
                  period: timeShift,
                ),
              )
            : DifferenceIndicator<T>(
                PreviousValueIndicator<T>.fromIndicator(
                  _maIndicator,
                  period: timeShift,
                ),
                indicator,
              ),
        super.fromIndicator(indicator);

  /// Indicator to calculate the MA on.
  ///
  /// Default is a `CloseValueIndicator`.
  final Indicator<T> indicator;

  /// Moving Average Indicator.
  final CachedIndicator<T> _maIndicator;

  final DifferenceIndicator<T> _indicatorMinusPreviousSMAIndicator;

  @override
  T calculate(int index) => createResult(
        index: index,
        quote: _indicatorMinusPreviousSMAIndicator.getValue(index).quote,
      );

  @override
  void copyValuesFrom(covariant DPOIndicator<T> other) {
    super.copyValuesFrom(other);
    _maIndicator.copyValuesFrom(other._maIndicator);
  }

  @override
  void invalidate(int index) {
    _maIndicator.invalidate(index);
    super.invalidate(index);
  }
}
