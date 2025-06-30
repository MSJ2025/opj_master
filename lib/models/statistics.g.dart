// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatisticsAdapter extends TypeAdapter<Statistics> {
  @override
  final int typeId = 0;

  @override
  Statistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Statistics(
      quizId: fields[0] as String,
      correctAnswers: fields[1] as int,
      totalQuestions: fields[2] as int,
      totalResponseTime: fields[3] as double,
      domain: fields[4] as String,
      subDomain: fields[5] as String,
      isCorrect: fields[6] as bool,
      isChallenge: fields[7] as bool,
      isWin: fields[8] as bool,
      date: fields[9] as DateTime,
      sessions: (fields[10] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      challengeType: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Statistics obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.quizId)
      ..writeByte(1)
      ..write(obj.correctAnswers)
      ..writeByte(2)
      ..write(obj.totalQuestions)
      ..writeByte(3)
      ..write(obj.totalResponseTime)
      ..writeByte(4)
      ..write(obj.domain)
      ..writeByte(5)
      ..write(obj.subDomain)
      ..writeByte(6)
      ..write(obj.isCorrect)
      ..writeByte(7)
      ..write(obj.isChallenge)
      ..writeByte(8)
      ..write(obj.isWin)
      ..writeByte(9)
      ..write(obj.date)
      ..writeByte(10)
      ..write(obj.sessions)
      ..writeByte(11)
      ..write(obj.challengeType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
