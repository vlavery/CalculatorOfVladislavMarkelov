//calculator_screen.dart
import 'package:flutter/material.dart';
import 'button_values.dart'; // Assuming Btn class is defined here
import 'history_database.dart'; // Assuming HistoryDatabase class is defined here

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class ExpressionElement {
  final String value;
  final OperatorPriority priority;

  ExpressionElement(this.value, this.priority);
}

enum OperatorPriority { LOW, MEDIUM, HIGH }

extension OperatorPriorityExtension on OperatorPriority {
  bool operator >=(OperatorPriority other) {
    return this.index >= other.index;
  }
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  List<ExpressionElement> expression = [];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horizontal_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/converter');
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              showHistory();
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    expression.isEmpty ? "0" : expressionToString(expression),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                  width: value == Btn.n0
                      ? screenSize.width / 2
                      : (screenSize.width / 4),
                  height: screenSize.width / 5,
                  child: buildButton(value),
                ),
              )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white24,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onBtnTap(String value) {
    setState(() {
      switch (value) {
        case Btn.del:
          delete();
          break;
        case Btn.clr:
          clearAll();
          break;
        case Btn.per:
          convertToPercentage();
          break;
        case Btn.calculate:
          calculate();
          break;
        default:
          appendValue(value);
      }
    });
  }

  void calculate() {
    try {
      if (expression.isEmpty || expression.last.value == Btn.dot) return;

      double result = evaluateExpression(expression);

      String equation = expressionToString(expression);
      String historyEntry = "$equation = $result";
      HistoryDatabase.insertHistory(historyEntry);

      setState(() {
        expression.clear();
        expression.add(ExpressionElement(result.toString(), OperatorPriority.LOW));
      });
    } catch (e) {
      showErrorDialog(e.toString());
    }
  }


  double evaluateExpression(List<ExpressionElement> expression) {
    List<double> numbers = [];
    List<String> operators = [];

    for (var element in expression) {
      if (num.tryParse(element.value) != null) {
        numbers.add(double.parse(element.value));
      } else if (element.value == Btn.openParenthesis) {
        operators.add(element.value);
      } else if (element.value == Btn.closeParenthesis) {
        while (operators.isNotEmpty && operators.last != Btn.openParenthesis) {
          applyOperator(numbers, operators);
        }
        if (operators.isEmpty) {
          throw ArgumentError('Invalid expression: Mismatched parentheses');
        }
        operators.removeLast(); // Remove open parenthesis
      } else {
        while (operators.isNotEmpty && hasPrecedence(operators.last, element.value)) {
          applyOperator(numbers, operators);
        }
        operators.add(element.value);
      }
    }

    while (operators.isNotEmpty) {
      if (operators.last == Btn.openParenthesis || operators.last == Btn.closeParenthesis) {
        throw ArgumentError('Invalid expression: Mismatched parentheses');
      }
      applyOperator(numbers, operators);
    }

    if (numbers.length != 1) {
      throw ArgumentError('Invalid expression: Mismatched operands');
    }

    return numbers.first;
  }

  bool hasPrecedence(String op1, String op2) {
    if (op2 == Btn.openParenthesis || op2 == Btn.closeParenthesis) {
      return false;
    }
    if ((op1 == Btn.multiply || op1 == Btn.divide) && (op2 == Btn.add || op2 == Btn.subtract)) {
      return false;
    }
    return true;
  }

  void applyOperator(List<double> numbers, List<String> operators) {
    if (operators.isEmpty || operators.last == Btn.openParenthesis) {
      return;
    }
    double secondOperand = numbers.removeLast();
    double firstOperand = numbers.removeLast();
    String operator = operators.removeLast();

    double result = performOperation(firstOperand, operator, secondOperand);
    numbers.add(result);
  }

  double performOperation(double firstOperand, String operator, double secondOperand) {
    switch (operator) {
      case Btn.add:
        return firstOperand + secondOperand;
      case Btn.subtract:
        return firstOperand - secondOperand;
      case Btn.multiply:
        return firstOperand * secondOperand;
      case Btn.divide:
        if (secondOperand == 0) {
          throw ArgumentError('Division by zero is not allowed');
        }
        return firstOperand / secondOperand;
      default:
        throw ArgumentError('Unknown operator: $operator');
    }
  }

  void convertToPercentage() {
    // Placeholder implementation for converting number to percentage
  }

  void clearAll() {
    setState(() {
      expression.clear();
    });
  }

  void delete() {
    if (expression.isNotEmpty) {
      expression.removeLast();
    }
  }

  void appendValue(String value) {
    // Check if the value is a digit or a dot
    if (value == Btn.dot || (value.compareTo('0') >= 0 && value.compareTo('9') <= 0)) {
      // If the expression is empty or the last element is an operator, add the new value as a new operand
      if (expression.isEmpty || isOperator(expression.last.value) || expression.last.value == Btn.openParenthesis) {
        expression.add(ExpressionElement(value, OperatorPriority.LOW));
      } else {
        // Otherwise, concatenate the new value to the last operand
        final lastElement = expression.removeLast();
        final newValue = lastElement.value + value;
        expression.add(ExpressionElement(newValue, lastElement.priority));
      }
    } else {
      // If the value is an operator or percentage, add it as a separate element
      expression.add(ExpressionElement(value, operatorPriority(value)));
    }
  }

  bool isOperator(String value) {
    return value == Btn.add ||
        value == Btn.subtract ||
        value == Btn.multiply ||
        value == Btn.divide;
  }

  OperatorPriority operatorPriority(String operator) {
    switch (operator) {
      case Btn.add:
      case Btn.subtract:
        return OperatorPriority.LOW;
      case Btn.multiply:
      case Btn.divide:
        return OperatorPriority.MEDIUM;
      default:
        return OperatorPriority.HIGH;
    }
  }


  String expressionToString(List<ExpressionElement> expression) {
    String result = '';
    for (var element in expression) {
      result += element.value;
    }
    return result.trim();
  }

  Color getBtnColor(String value) {
    if ([Btn.del, Btn.clr].contains(value)) {
      return Colors.blueGrey;
    } else if ([
      Btn.per,
      Btn.multiply,
      Btn.add,
      Btn.subtract,
      Btn.divide,
      Btn.calculate,
      Btn.openParenthesis,
      Btn.closeParenthesis,
    ].contains(value)) {
      return Colors.orange;
    } else if ([
      Btn.n0,
      Btn.n1,
      Btn.n2,
      Btn.n3,
      Btn.n4,
      Btn.n5,
      Btn.n6,
      Btn.n7,
      Btn.n8,
      Btn.n9,
      Btn.dot,
    ].contains(value)) {
      return Colors.black87;
    } else {
      return Colors.black; // Default color for unknown values
    }
  }

  Future<void> showHistory() async {
    final List<Map<String, dynamic>> history = await HistoryDatabase.getHistory();

    // Show history in a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('History'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Calculation: ${history[index][HistoryDatabase.columnCalculation]}'),
                  subtitle: Text('Time: ${history[index][HistoryDatabase.columnTime]}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}