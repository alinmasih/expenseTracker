import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

import '../models/budget.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sqlite.Database? _database;
  
  // In-memory fallback if sqflite native driver fails on certain web platforms
  final List<Expense> _memoryExpenses = [];
  final Map<String, Budget> _memoryBudgets = {};
  bool _useMemoryFallback = false;

  DatabaseHelper._init();

  Future<sqlite.Database?> get database async {
    if (_useMemoryFallback) return null;
    if (_database != null) return _database!;

    try {
      _database = await _initDB('spendtrack.db');
      return _database;
    } catch (e) {
      debugPrint('SQLite initialization error, falling back to memory storage: $e');
      _useMemoryFallback = true;
      return null;
    }
  }

  Future<sqlite.Database> _initDB(String filePath) async {
    final dbPath = await sqlite.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sqlite.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(sqlite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');
  }

  // --- EXPENSE CRUD ---

  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    if (db != null) {
      await db.insert(
        'expenses',
        expense.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
      );
    } else {
      _memoryExpenses.removeWhere((e) => e.id == expense.id);
      _memoryExpenses.add(expense);
    }
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    if (db != null) {
      final maps = await db.query('expenses', orderBy: 'date DESC, createdAt DESC');
      return maps.map((map) => Expense.fromMap(map)).toList();
    } else {
      _memoryExpenses.sort((a, b) => b.date.compareTo(a.date));
      return List.from(_memoryExpenses);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    if (db != null) {
      await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } else {
      final index = _memoryExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _memoryExpenses[index] = expense;
      }
    }
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    if (db != null) {
      await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      _memoryExpenses.removeWhere((e) => e.id == id);
    }
  }

  Future<void> clearAllExpenses() async {
    final db = await database;
    if (db != null) {
      await db.delete('expenses');
    } else {
      _memoryExpenses.clear();
    }
  }

  // --- BUDGET CRUD ---

  Future<void> setBudget(Budget budget) async {
    final db = await database;
    if (db != null) {
      await db.insert(
        'budgets',
        budget.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
      );
    } else {
      final key = '${budget.year}-${budget.month}';
      _memoryBudgets[key] = budget;
    }
  }

  Future<Budget?> getBudget(int month, int year) async {
    final db = await database;
    if (db != null) {
      final maps = await db.query(
        'budgets',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
      );
      if (maps.isNotEmpty) {
        return Budget.fromMap(maps.first);
      }
      return null;
    } else {
      final key = '$year-$month';
      return _memoryBudgets[key];
    }
  }

  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
  }
}
