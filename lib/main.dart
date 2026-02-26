import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String display = '0';
  String expression = '';
  static const int maxDigits = 12;

  double? _acc;
  String? _op;
  bool _resetOnNextDigit = false;

  void handleButton(String label) {
    if ('0123456789'.contains(label)) {
      _inputDigit(label);
      return;
    }

    switch (label) {
      case '+':
      case '−':
      case '×':
      case '÷':
        _setOperator(label);
        break;

      case '=':
        _compute();
        break;

      case 'C':
        _clearAll();
        break;

      case 'CE':
        _clearEntry();
        break;

      case '⌫':
        _backspace();
        break;

      default:
        // şimdilik diğerleri yok say
        break;
    }
  }

  void _inputDigit(String d) {
    setState(() {
      if (_resetOnNextDigit) {
        display = d;
        _resetOnNextDigit = false;
        return;
      }

      if (display == '0') {
        display = d;
        return;
      }

      if (_digitCount(display) >= maxDigits) return;

      display += d;
    });
  }

  int _digitCount(String s) {
    final onlyDigits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return onlyDigits.length;
  }

  void _setOperator(String newOp) {
    setState(() {
      final current = double.tryParse(display.replaceAll(',', '.')) ?? 0;

      if (_acc == null) {
        _acc = current;
      } else if (_op != null && !_resetOnNextDigit) {
        _acc = _applyOp(_acc!, current, _op!);
        display = _format(_acc!);
      }

      _op = newOp;
      expression = '${_format(_acc!)} $newOp';

      _resetOnNextDigit = true;
    });
  }

  void _compute() {
    setState(() {
      if (_acc == null || _op == null) return;

      final num1 = _acc!;
      final num2 = double.tryParse(display.replaceAll(',', '.')) ?? 0;
      final op = _op!;
      
      final result = _applyOp(num1, num2, op);
      
      expression = '${_format(num1)} $op ${_format(num2)} =';
      display = _format(result);

      _acc = null;
      _op = null;
      _resetOnNextDigit = true;
    });
  }

  double _applyOp(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  String _format(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';

    // 42.0 -> 42
    String s = (v == v.roundToDouble()) ? v.toInt().toString() : v.toString();

    // bilimsel gösterim gelirse (çok büyük/küçük sayılar) direkt Overflow diyelim şimdilik
    if (s.contains('e') || s.contains('E')) return 'Overflow';

    // ✅ basamak sayısı kontrolü
    if (_digitCount(s) > maxDigits) return 'Overflow';

    return s;
  }

    void _clearAll() {
    setState(() {
      display = '0';
      expression = '';
      _acc = null;
      _op = null;
      _resetOnNextDigit = false;
    });
  }

  void _clearEntry() {
    setState(() {
      display = '0';
    });
  }

  void _backspace() {
    setState(() {
      // Eğer yeni sayı girilecek moddaysak (ör: 2 + basıldıktan sonra)
      if (_resetOnNextDigit) {
        display = '0';
        return;
      }

      // Tek karakter kaldıysa
      if (display.length <= 1) {
        display = '0';
        return;
      }

      // Son karakteri sil
      display = display.substring(0, display.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: _buildAppBar(),
        body: _buildCalculatorBody(),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(){
    return AppBar(
      leading: Builder(builder: (BuildContext context){
        return IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, size: 24, color: AppColors.keyText),
          tooltip: 'Open Navigation',
          hoverColor: AppColors.hoverOverlay,
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            ), 
          ),
        );
      }),
      title: Align(
        alignment: Alignment.centerLeft,
        child: const Text(
          'Standard', 
          style: TextStyle(
            color: AppColors.keyText, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history,size: 24, color: AppColors.keyText,),
          tooltip: 'History',
          onPressed: () {
            // handle the press
          },
        ),
      ],
      backgroundColor: AppColors.background,
      elevation: 0,
    );
  }

  Widget _buildCalculatorBody() {
    return Column(
      children: [
        calcDisplay(expression, display),
        calcKeyPad(display, handleButton),
      ],
    );
  }
}

Widget calcDisplay(String expression, String display){
  return Expanded(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            expression,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.displaySecondaryText,
              fontSize: 14,
            ),
          ),
          Text(
            formatWithDots(display),
            textAlign: TextAlign.right,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: AppColors.displayPrimaryText,
              fontSize: 42,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
  );
}

String formatWithDots(String value) {
  bool isNegative = value.startsWith('-');
  if (isNegative) {
    value = value.substring(1);
  }

  String reversed = value.split('').reversed.join();

  List<String> chunks = [];

  for (int i = 0; i < reversed.length; i += 3) {
    int end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
    chunks.add(reversed.substring(i, end));
  }

  String result = chunks.join('.').split('').reversed.join();

  return isNegative ? '-$result' : result;
}

Widget calcKeyPad(String display, Function(String) onPressed){
  return Expanded(
    flex:3,
    child: Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          keyRow(['%', 'CE', 'C', '⌫'], onPressed: onPressed),
          keyRow(['1/x', 'x²', '²√x', '÷'], onPressed: onPressed),
          keyRow(['7', '8', '9', '×'], grayIndex: [0,1,2], onPressed: onPressed),
          keyRow(['4', '5', '6', '−'], grayIndex: [0,1,2], onPressed: onPressed),
          keyRow(['1', '2', '3', '+'], grayIndex: [0,1,2], onPressed: onPressed),
          keyRow(['+/-', '0', ',', '='], grayIndex: [0, 1, 2], equalIndex: 3, onPressed: onPressed),
        ],
      ),
    ),
  );
}

Widget keyRow(List<String> labels, {List<int>? grayIndex, int? equalIndex, required Function(String) onPressed,}) {
  return Expanded(
    child: Row(
      children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: calcButton(
                  labels[i],
                  onPressed: () => onPressed(labels[i]),
                  color: (equalIndex == i) ? AppColors.equalKeyBg :((grayIndex?.contains(i) ?? false)
                        ? AppColors.operatorKeyBg: null),
                  textColor: (equalIndex == i) ? AppColors.equalKeyText : null,
                  hoverColors: (equalIndex == i) ? AppColors.equalKeyHover :((grayIndex?.contains(i) ?? false)
                        ? AppColors.numberKeyBg: AppColors.operatorKeyBg)
              ),
            ),
          ),
      ],
    ),
  );
}

Widget calcButton(String text, {required VoidCallback onPressed, Color? color, Color? textColor, Color? hoverColors}) {
  return MouseRegion(
    cursor: SystemMouseCursors.basic,
    child: SizedBox.expand(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color ?? AppColors.numberKeyBg,
          overlayColor: color?.darker(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17, 
            color: textColor ?? AppColors.keyText
          ),
        ),
      ),
    )
  );
}

class AppColors {
  // Genel arka planlar
  static const Color background = Color(0xFF252424);      // senin ARGB(221,37,36,36) yakın
  static const Color surface = Color(0xFF1F1F1F);         // panel/katman gibi yerler için (opsiyon)

  // Display (ekran) yazıları
  static const Color displayPrimaryText = Color(0xFFFFFFFF);
  static const Color displaySecondaryText = Color(0xFFBDBDBD);

  // Tuş yüzeyleri
  static const Color numberKeyBg = Color(0xFF2E2E2E);     // senin kullandığın ana tuş rengi
  static const Color operatorKeyBg = Color(0xFF3A3A3A);   

  // Eşittir (accent)
  static const Color equalKeyBg = Color.fromARGB(255, 76, 188, 248);
  static const Color equalKeyHover = Color(0xFF7FD3FF); 
  static const Color equalKeyText = Color(0xFF000000);

  // Tuş yazıları
  static const Color keyText = Color(0xFFFFFFFF);
  static const Color keyTextMuted = Color(0xFFE0E0E0);    // gerekirse

  // Hover / pressed (ileriye dönük, şimdilik kullanmasan da dursun)
  static const Color hoverOverlay = Color(0x1AFFFFFF);    // %10 beyaz overlay
  static const Color pressedOverlay = Color(0x33FFFFFF);  // %20 beyaz overlay
}
