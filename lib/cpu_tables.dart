class CpuTables {
  static const List<int> addressModes = [
    0, 11, 0, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 4, 4, 0,
    0, 12, 0, 0, 0, 4, 4, 0, 0, 9, 0, 0, 0, 7, 7, 0,
    10, 11, 0, 0, 7, 2, 1, 0, 0, 2, 1, 0, 7, 4, 4, 0,
    0, 12, 0, 0, 0, 4, 4, 0, 0, 9, 0, 0, 0, 7, 7, 0,
    0, 11, 0, 0, 0, 2, 1, 0, 0, 2, 1, 0, 7, 4, 4, 0,
    0, 12, 0, 0, 0, 4, 4, 0, 0, 9, 0, 0, 0, 7, 7, 0,
    0, 11, 0, 0, 0, 2, 1, 0, 0, 2, 1, 0, 10, 4, 4, 0,
    0, 12, 0, 0, 0, 4, 4, 0, 0, 9, 0, 0, 0, 7, 7, 0,
    0, 11, 0, 0, 0, 12, 12, 0, 0, 0, 0, 0, 0, 4, 5, 0,
    0, 12, 0, 0, 0, 4, 5, 0, 0, 9, 0, 0, 0, 7, 0, 0,
    2, 11, 2, 0, 2, 2, 2, 0, 0, 2, 0, 0, 4, 4, 5, 0,
    0, 12, 0, 0, 4, 4, 5, 0, 0, 9, 0, 0, 7, 7, 9, 0,
    2, 11, 0, 0, 2, 2, 2, 0, 0, 2, 0, 0, 2, 4, 4, 0,
    0, 12, 0, 0, 0, 4, 4, 0, 0, 9, 0, 0, 0, 7, 7, 0,
    2, 11, 0, 0, 2, 2, 12, 0, 0, 2, 0, 0, 2, 4, 4, 0,
    0, 12, 0, 0, 0, 4, 4, 0, 0, 9, 0, 0, 0, 7, 7, 0,
  ];

  static const List<int> instructionLen = [
    1, 2, 0, 0, 0, 2, 2, 0, 0, 2, 1, 0, 0, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 3, 0, 0, 0, 3, 3, 0,
    3, 2, 0, 0, 2, 2, 2, 0, 0, 2, 1, 0, 3, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 3, 0, 0, 0, 3, 3, 0,
    1, 2, 0, 0, 0, 2, 2, 0, 0, 2, 1, 0, 3, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 3, 0, 0, 0, 3, 3, 0,
    1, 2, 0, 0, 0, 2, 2, 0, 0, 2, 1, 0, 3, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 3, 0, 0, 0, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 3, 0, 0, 0, 3, 0, 0,
    2, 2, 2, 0, 2, 2, 2, 0, 0, 2, 0, 0, 3, 3, 3, 0,
    0, 2, 0, 0, 2, 2, 2, 0, 0, 3, 0, 0, 3, 3, 3, 0,
    2, 2, 0, 0, 2, 2, 2, 0, 0, 2, 0, 0, 3, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 3, 0, 0, 0, 3, 3, 0,
    2, 2, 0, 0, 2, 2, 2, 0, 0, 2, 1, 0, 3, 3, 3, 0,
    0, 2, 0, 0, 0, 2, 2, 0, 0, 3, 0, 0, 0, 3, 3, 0,
  ];

  static const List<int> instructionCycles = [
    7, 6, 0, 0, 0, 3, 5, 0, 0, 2, 2, 0, 0, 4, 6, 0,
    0, 5, 0, 0, 0, 4, 6, 0, 0, 4, 0, 0, 0, 4, 7, 0,
    6, 6, 0, 0, 3, 3, 5, 0, 0, 2, 2, 0, 4, 4, 6, 0,
    0, 5, 0, 0, 0, 4, 6, 0, 0, 4, 0, 0, 0, 4, 7, 0,
    6, 6, 0, 0, 0, 3, 5, 0, 0, 2, 2, 0, 3, 4, 6, 0,
    0, 5, 0, 0, 0, 4, 6, 0, 0, 4, 0, 0, 0, 4, 7, 0,
    6, 6, 0, 0, 0, 3, 5, 0, 0, 2, 2, 0, 5, 4, 6, 0,
    0, 5, 0, 0, 0, 4, 6, 0, 0, 4, 0, 0, 0, 4, 7, 0,
    0, 6, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 4, 4, 0,
    0, 6, 0, 0, 0, 4, 4, 0, 0, 5, 0, 0, 0, 5, 0, 0,
    2, 6, 2, 0, 3, 3, 3, 0, 0, 2, 0, 0, 4, 4, 4, 0,
    0, 5, 0, 0, 4, 4, 4, 0, 0, 4, 0, 0, 4, 4, 4, 0,
    2, 6, 0, 0, 3, 3, 5, 0, 0, 2, 0, 0, 4, 4, 6, 0,
    0, 5, 0, 0, 0, 4, 6, 0, 0, 4, 0, 0, 0, 4, 7, 0,
    2, 6, 0, 0, 3, 3, 5, 0, 0, 2, 2, 0, 4, 4, 6, 0,
    0, 5, 0, 0, 0, 4, 6, 0, 0, 4, 0, 0, 0, 4, 7, 0
  ];
}

