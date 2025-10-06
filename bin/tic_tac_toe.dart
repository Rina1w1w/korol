import 'dart:io';
import 'dart:math';

void main() {
  while (true) 
  {
    print('\n=== КРЕСТИКИ-НОЛИКИ ===');

    int size;
    while (true) 
    {
      stdout.write('Введите размер поля (минимум 3): ');
      final input = stdin.readLineSync();
      final n = int.tryParse(input ?? '');
      if (n != null && n >= 3) 
      {
        size = n;
        break;
      } else 
      {
        print(' Размер поля должен быть целым числом не меньше 3. Попробуйте снова.');
      }
    }

    stdout.write('Хотите играть против робота? (y/n): ');
    final vsBot = (stdin.readLineSync() ?? '').toLowerCase().startsWith('y');

    final first = Random().nextBool() ? 'X' : 'O';
    if (vsBot) 
    {
      print('Вы играете за X. Робот играет за O.');
    }
    print('Первым ходит: $first');

    final game = TicTacToe(size, vsBot, first);
    game.play();

    stdout.write('\nСыграть ещё раз? (y/n): ');
    final again = stdin.readLineSync()?.toLowerCase();
    if (again != 'y' && again != 'yes') break;
  }

  print('\nСпасибо за игру!');
}

class TicTacToe 
{
  final int size;
  final bool vsBot;
  String current;
  List<List<String>> board;

  TicTacToe(this.size, this.vsBot, this.current)
      : board = List.generate(
          size,
          (_) => List.filled(size, ' '),
        );

  void play() 
  {
    while (true) 
    {
      printBoard();

      if (vsBot && current == 'O') 
      {
        botMove();
        print('Робот (O) сделал ход.');
      } else 
      {
        playerMove();
      }

      if (checkWin(current)) 
      {
        printBoard();
        print(' Победил $current!');
        break;
      }

      if (isFull()) 
      {
        printBoard();
        print(' Ничья!');
        break;
      }

      current = (current == 'X') ? 'O' : 'X';
    }
  }

  void printBoard() 
  {
    print('');
    for (int i = 0; i < size; i++) 
    {
      print(' ${board[i].join(' | ')}');
      if (i < size - 1) {
        print(' ${List.filled(size, '-').join('-+-')}');
      }
    }
    print('');
  }

  void playerMove() 
{
  while (true) 
  {
    stdout.write('Ваш ход ($current), введите строку и столбец (1-$size), например: 2 3: ');
    final parts = stdin.readLineSync()?.split(' ');
    if (parts == null || parts.length != 2) continue;

    final r = int.tryParse(parts[0]) ?? 0;
    final c = int.tryParse(parts[1]) ?? 0;

    if (r < 1 || r > size || c < 1 || c > size) 
    {
      print('Введите числа от 1 до $size.');
      continue;
    }

    if (board[r - 1][c - 1] != ' ') 
    {
      print('Клетка занята.');
      continue;
    }

    board[r - 1][c - 1] = current;
    break;
  }
}

  void botMove() 
  {
    final emptyCells = <List<int>>[];
    for (int i = 0; i < size; i++) 
    {
      for (int j = 0; j < size; j++) 
      {
        if (board[i][j] == ' ') 
        {
          emptyCells.add([i, j]);
        }
      }
    }
    if (emptyCells.isNotEmpty) 
    {
      final randomIndex = Random().nextInt(emptyCells.length);
      final move = emptyCells[randomIndex];
      board[move[0]][move[1]] = 'O';
    }
  }

  bool checkWin(String player) 
  {
 
    for (int i = 0; i < size; i++) {
      if (board[i].every((cell) => cell == player)) return true;
    }

    for (int j = 0; j < size; j++) 
    {
      if (board.every((row) => row[j] == player)) return true;
    }

    if (List.generate(size, (i) => board[i][i]).every((cell) => cell == player)) 
    {
      return true;
    }

    if (List.generate(size, (i) => board[i][size - 1 - i])
        .every((cell) => cell == player)) 
        {
      return true;
    }

    return false;
  }

  bool isFull() => board.every((row) => !row.contains(' '));
}