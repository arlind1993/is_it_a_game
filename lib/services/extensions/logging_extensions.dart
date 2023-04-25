import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';


extension LoggerPrinter on Logger{
  static String ansiReset = "\x1B[0m";

  static Map<String,MapEntry<Color, String>> ansiStrings = {
    "black": MapEntry(const Color(0xff000000), "\\x1B[30m"),
    "brick": MapEntry(const Color(0xffa0524f), "\\x1B[31m"),
    "olive": MapEntry(const Color(0xff5c962c), "\\x1B[32m"),
    "gold": MapEntry(const Color(0xffa68a0d), "\\x1B[33m"),
    "blue": MapEntry(const Color(0xff3993d4), "\\x1B[34m"),
    "purple": MapEntry(const Color(0xffa771bf), "\\x1B[35m"),
    "teal": MapEntry(const Color(0xff00a3a3), "\\x1B[36m"),
    "light_gray": MapEntry(const Color(0xff808080), "\\x1B[37m"),
    "dark_gray": MapEntry(const Color(0xff595959), "\\x1B[90m"),
    "red": MapEntry(const Color(0xfff0524f), "\\x1B[91m"),
    "green": MapEntry(const Color(0xff4fc414), "\\x1B[92m"),
    "yellow": MapEntry(const Color(0xffe5bf00), "\\x1B[93m"),
    "light_blue": MapEntry(const Color(0xff1fb0ff), "\\x1B[94m"),
    "magenta": MapEntry(const Color(0xffed7eed), "\\x1B[95m"),
    "cyan": MapEntry(const Color(0xff00e5e5), "\\x1B[96m"),
    "white": MapEntry(const Color(0xffffffff), "\\x1B[97m"),
  };

  static Map<Level, Color> errorColors = {
    Level.ALL: const Color(0xffCCCCCC),
    Level.FINEST: const Color(0xff00FF00),
    Level.FINER: const Color(0xff008000),
    Level.FINE: const Color(0xff2E8B57),
    Level.CONFIG: const Color(0xffF0E68C),
    Level.INFO: const Color(0xff0074D9),
    Level.WARNING: const Color(0xffFFA500),
    Level.SEVERE: const Color(0xffFF4136),
    Level.SHOUT: const Color(0xff800080),
    Level.OFF: const Color(0xff333333),
  };

  static Map<Level, String> errorAnsiColor = {
    Level.ALL: "\x1B[97m",
    Level.FINEST: "\x1B[92m",
    Level.FINER: "\x1B[32m",
    Level.FINE: "\x1B[32m",
    Level.CONFIG: "\x1B[33m",
    Level.INFO: "\x1B[34m",
    Level.WARNING: "\x1B[93m",
    Level.SEVERE: "\x1B[91m",
    Level.SHOUT: "\x1B[35m",
    Level.OFF: "\x1B[90m",
  };

  printLog(
    Level level,
    String message,{
    String? stacktrace,
    DateTime? recordedTime,
    bool withTime = true
  }){
    debugPrint("${errorAnsiColor[level]}"
        "["
        "${withTime ? "${(recordedTime ?? DateTime.now()).toString().split(".").first}, " : ""}"
        "${level >= Level.WARNING ?"ERROR": "LOG"}"
        "(${this.name})]: "
        "$message"
        "${stacktrace==null ? "" : (
          "${ansiReset}\n${errorAnsiColor[level]}"
          "${"="*25}Stacktrace${"="*25}"
          "${ansiReset}\n${errorAnsiColor[level]}"
          "$stacktrace"
          )
        }"
        "${ansiReset}");
  }

  static printLogFrom(
      Level level,
      String name,
      String message,{
        String? stacktrace,
        DateTime? recordedTime,
        bool withTime = true
      }){
    debugPrint("${errorAnsiColor[level]}"
        "["
        "${withTime ? "${(recordedTime ?? DateTime.now()).toString().split(".").first}, " : ""}"
        "${level >= Level.WARNING ?"ERROR": "LOG"}"
        "(${name})]: "
        "$message"
        "${(stacktrace == null || stacktrace == "" || stacktrace == "null")? "" : (
        "${ansiReset}\n${errorAnsiColor[level]}"
            "${"="*25}Stacktrace${"="*25}"
            "${ansiReset}\n${errorAnsiColor[level]}"
            "$stacktrace"
    )
    }"
        "${ansiReset}");
  }

}