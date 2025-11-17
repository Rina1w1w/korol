import 'dart:io';
import 'dart:math';

void main() 
{
  print('===  МОРСКОЙ БОЙ ===\n');

  int playerWins = 0;
  int enemyWins = 0;

  while (true) 
  {
    stdout.write('Введите размер поля (минимум 5): ');
    final n = int.tryParse(stdin.readLineSync() ?? '');
    if (n == null || n < 5) 
    {
      print('Размер поля должен быть не меньше 5.\n');
      continue;
    }

    stdout.write('Играть против компьютера? (y/n): ');
    final vsBot = (stdin.readLineSync() ?? '').toLowerCase().startsWith('y');

    final game = SeaBattle(n, vsBot);
    final winner = game.play();

    // Сохраняем статистику
    game.saveStatistics(winner);

    if (winner == 'player') playerWins++;
    else if (winner == 'enemy') enemyWins++;

    print('\n Текущий счёт: Игрок $playerWins — Противник $enemyWins\n');

    stdout.write('Сыграть ещё раз? (y/n): ');
    if ((stdin.readLineSync() ?? '').toLowerCase() != 'y') break;
  }

  print('\nСпасибо за игру! До новых морских побед ');
}

class SeaBattle 
{
  final int size;
  final bool vsBot;
  final Random _rnd = Random();

  late List<List<String>> playerField;
  late List<List<String>> enemyField;
  late List<List<String>> enemyVisible;

  int playerShips = 0;
  int enemyShips = 0;

  // Статистика игры
  int playerHits = 0;
  int playerMisses = 0;
  int enemyHits = 0;
  int enemyMisses = 0;
  int totalTurns = 0;
  DateTime? gameStartTime;
  DateTime? gameEndTime;

  SeaBattle(this.size, this.vsBot) 
  {
    playerField = List.generate(size, (_) => List.filled(size, '~'));
    enemyField = List.generate(size, (_) => List.filled(size, '~'));
    enemyVisible = List.generate(size, (_) => List.filled(size, '~'));

    print('\nХотите расставить корабли вручную? (y/n): ');
    final manual = (stdin.readLineSync() ?? '').toLowerCase().startsWith('y');

    if (manual) 
    {
      _manualPlacement();
    } else 
    {
      _placeShips(playerField);
    }
    _placeShips(enemyField);

    // Запускаем таймер начала игры
    gameStartTime = DateTime.now();
  }

  void _placeShips(List<List<String>> field) 
  {
    int ships = size ~/ 2;
    int placed = 0;

    while (placed < ships) 
    {
      int x = _rnd.nextInt(size);
      int y = _rnd.nextInt(size);

      if (field[x][y] == '~') 
      {
        field[x][y] = '■';
        placed++;
      }
    }

    if (identical(field, playerField)) 
    {
      playerShips = ships;
    } else 
    {
      enemyShips = ships;
    }
  }

  void _manualPlacement() 
  {
    int ships = size ~/ 2;
    int placed = 0;

    print('\nРасставьте $ships кораблей');
    print('Формат ввода: строка столбец (например: 2 3)');
    _printField(playerField);

    while (placed < ships) 
    {
      stdout.write('Корабль ${placed + 1}/$ships: ');
      final parts = stdin.readLineSync()?.trim().split(RegExp(r'\s+'));

      if (parts == null || parts.length != 2) 
      {
        print('Ошибка: нужно ввести 2 числа через пробел');
        continue;
      }

      final x = int.tryParse(parts[0]);
      final y = int.tryParse(parts[1]);

      if (x == null || y == null) 
      {
        print('Ошибка: введите числа');
        continue;
      }

      if (x < 1 || y < 1 || x > size || y > size) 
      {
        print('Ошибка: координаты от 1 до $size');
        continue;
      }

      final row = x - 1;
      final col = y - 1;

      if (playerField[row][col] != '~') 
      {
        print('Ошибка: клетка уже занята');
        continue;
      }

      playerField[row][col] = '■';
      placed++;
      print('Корабль размещён!');
      _printField(playerField);
    }

    playerShips = ships;
    print('Все корабли расставлены!\n');
  }

  String play() 
  {
    while (playerShips > 0 && enemyShips > 0) 
    {
      _printFields();

      final playerResult = _playerTurn();
      totalTurns++;
      if (playerResult == 'win') 
      {
        gameEndTime = DateTime.now();
        return 'player';
      }

      if (vsBot) 
      {
        _botTurn();
      } else 
      {
        _enemyTurn();
      }
      totalTurns++;

      if (playerShips <= 0) 
      {
        gameEndTime = DateTime.now();
        return 'enemy';
      }
    }

    _printFields();
    gameEndTime = DateTime.now();
    return playerShips > 0 ? 'player' : 'enemy';
  }

  String _playerTurn() 
  {
    while (true) 
    {
      stdout.write('\nВаш ход (1-$size) или "exit": ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (input.toLowerCase() == 'exit') 
      {
        print('Завершение игры...');
        exit(0);
      }

      final parts = input.split(RegExp(r'\s+'));
      if (parts.length != 2) 
      {
        print('Введите: строка столбец');
        continue;
      }

      final x = int.tryParse(parts[0]);
      final y = int.tryParse(parts[1]);

      if (x == null || y == null) 
      {
        print('Нужны числа');
        continue;
      }

      if (x < 1 || y < 1 || x > size || y > size) 
      {
        print('Координаты: 1-$size');
        continue;
      }

      final row = x - 1;
      final col = y - 1;

      if (enemyVisible[row][col] != '~') 
      {
        print('Сюда уже стреляли');
        continue;
      }

      if (enemyField[row][col] == '■') 
      {
        print('Попадание!');
        enemyField[row][col] = 'X';
        enemyVisible[row][col] = 'X';
        enemyShips--;
        playerHits++;

        if (enemyShips <= 0) 
        {
          print('Все корабли противника уничтожены!');
          return 'win';
        }
      } else 
      {
        print('Мимо...');
        enemyVisible[row][col] = '•';
        playerMisses++;
      }

      break;
    }
    return 'continue';
  }

  void _enemyTurn() 
  {
    print('\n--- Ход противника ---');

    while (true) 
    {
      stdout.write('Введите координаты: ');
      final parts = stdin.readLineSync()?.trim().split(RegExp(r'\s+'));

      if (parts?.length == 2) 
      {
        final x = int.tryParse(parts![0]);
        final y = int.tryParse(parts[1]);

        if (x != null && y != null && x >= 1 && y >= 1 && x <= size && y <= size) 
        {
          _processEnemyShot(x - 1, y - 1);
          break;
        }
      }
      print('Некорректный ввод');
    }
  }

  void _botTurn() 
  {
    print('\n--- Ход робота ---');

    int x, y;
    do 
    {
      x = _rnd.nextInt(size);
      y = _rnd.nextInt(size);
    } while (playerField[x][y] == 'X' || playerField[x][y] == '•');

    _processEnemyShot(x, y);
  }

  void _processEnemyShot(int x, int y) 
  {
    if (playerField[x][y] == '■') {
      print('Робот попал в (${x + 1}, ${y + 1})!');
      playerField[x][y] = 'X';
      playerShips--;
      enemyHits++;
    } else 
    {
      print('Робот промахнулся (${x + 1}, ${y + 1})');
      playerField[x][y] = '•';
      enemyMisses++;
    }
  }

  void _printField(List<List<String>> field) 
  {
    print('\n   ${List.generate(size, (i) => (i + 1).toString().padLeft(2)).join(' ')}');
    for (int i = 0; i < size; i++) 
    {
      print('${(i + 1).toString().padLeft(2)} ${field[i].join('  ')}');
    }
    print('');
  }

  void _printFields() 
  {
    print('\n' + '=' * (size * 3 + 10));
    print('Ваше поле:'.padRight(20) + 'Поле противника:');

    print('${List.generate(size, (i) => (i + 1).toString().padLeft(2)).join(' ')}'.padRight(20) +
        '${List.generate(size, (i) => (i + 1).toString().padLeft(2)).join(' ')}');

    for (int i = 0; i < size; i++) 
    {
      final playerRow = '${(i + 1).toString().padLeft(2)} ${playerField[i].join('  ')}';
      final enemyRow = '${(i + 1).toString().padLeft(2)} ${enemyVisible[i].join('  ')}';
      print(playerRow.padRight(20) + enemyRow);
    }

    print('Корабли: $playerShips'.padRight(20) + 'Корабли: $enemyShips');
    print('=' * (size * 3 + 10));
  }

  // Метод для сохранения статистики в файл
  void saveStatistics(String winner) 
  {
    try 
    {
      // Создаем каталог для статистики
      final statsDir = Directory('game_statistics');
      if (!statsDir.existsSync()) 
      {
        statsDir.createSync();
      }

      // Создаем файл с уникальным именем на основе времени
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('game_statistics/statistics_$timestamp.txt');

      // Вычисляем длительность игры
      final duration = gameEndTime!.difference(gameStartTime!);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;

      // Формируем статистику
      final stats = '''

      === СТАТИСТИКА ИГРЫ В МОРСКОЙ БОЙ ===
      Время игры: ${gameStartTime!.toString()}
      Длительность игры: ${minutes} мин. ${seconds} сек.

      РЕЗУЛЬТАТ: ${winner == 'player' ? 'ПОБЕДА ИГРОКА' : 'ПОБЕДА ПРОТИВНИКА'}

      СТАТИСТИКА ИГРОКА:
      - Уничтожено кораблей противника: ${size ~/ 2 - enemyShips}
      - Потеряно кораблей: ${size ~/ 2 - playerShips}
      - Осталось кораблей: $playerShips/${size ~/ 2}
      - Попадания: $playerHits
      - Промахи: $playerMisses
      - Точность: ${playerHits + playerMisses > 0 ? ((playerHits / (playerHits + playerMisses)) * 100).toStringAsFixed(1) : 0}%

      СТАТИСТИКА ПРОТИВНИКА:
      - Уничтожено кораблей игрока: ${size ~/ 2 - playerShips}
      - Потеряно кораблей: ${size ~/ 2 - enemyShips}
      - Осталось кораблей: $enemyShips/${size ~/ 2}
      - Попадания: $enemyHits
      - Промахи: $enemyMisses
      - Точность: ${enemyHits + enemyMisses > 0 ? ((enemyHits / (enemyHits + enemyMisses)) * 100).toStringAsFixed(1) : 0}%

      ОБЩАЯ СТАТИСТИКА:
      - Всего ходов: $totalTurns
      - Размер поля: $size×$size
      - Противник: ${vsBot ? 'Компьютер' : 'Человек'}
      ''';

      // Записываем статистику в файл
      file.writeAsStringSync(stats);
      
      // Выводим статистику на экран
      print('\n' + '=' * 50);
      print('СТАТИСТИКА ИГРЫ:');
      print('=' * 50);
      print(stats);
      print('Статистика сохранена в файл: ${file.path}');
      print('=' * 50);

    } catch (e) 
    {
      print('Ошибка при сохранении статистики: $e');
    }
  }
}
