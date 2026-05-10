import 'dart:typed_data' as type_data;

import 'package:c64_flutter/cia1.dart';
import 'package:c64_flutter/tape.dart';
import 'package:c64_flutter/vicii.dart';

class Memory {
  late type_data.ByteData _basic;
  late type_data.ByteData _character;
  late type_data.ByteData _kernal;
  late TapeMemoryInterface _tape;
  late Vicii vic;
  var _readCount = 0;
  var _kernelEnabled = true;

  late type_data.Uint32List image;

  final type_data.ByteData _ram = type_data.ByteData(64*1024);
  late final Cia1 cia1;

  Memory();

  setCia1(Cia1 cia1) {
    this.cia1 = cia1;
  }

  setTape(TapeMemoryInterface tape) {
    _tape = tape;
  }

  setByteArray(type_data.Uint32List bytArray) {
    image = bytArray;
  }

  populateMem(type_data.ByteData basicData, type_data.ByteData characterData,
      type_data.ByteData kernalData) {
    _basic = basicData;
    _character = characterData;
    _kernal = kernalData;
  }

  setMem(int value, int address ) {
    if ((address >> 8) == 0xDC) {
      cia1.setMem(address, value);
    } else if ((address >> 8) == 0xD0) {
      vic.setReg(address, value);
    } else if (address == 1) {
      _ram.setInt8(address, value);
      _tape.setMotor((value & 0x20) == 0 );
      _kernelEnabled = (value & 2) != 0;
    } else {
      _ram.setInt8(address, value);
    }
  }

  int getMem(int address) {
    _readCount++;
    if (address >= 0xA000 && address <= 0xBFFF) {
      return _basic.getUint8(address & 0x1fff);
    } else if (address >= 0xE000 && address <= 0xFFFF && _kernelEnabled) {
      return _kernal.getUint8(address & 0x1fff);
    } else if (address == 0xD012) {
      return (_readCount & 1024) == 0 ? 1 : 0;
    } else if ((address >> 8) == 0xDC ) {
      return cia1.getMem(address);
    } else if ((address >> 8) == 0xD0) {
      return vic.getReg(address);
    } else if (address == 1) {
      var value = _ram.getUint8(address) & 0xef;
      return value | _tape.getCassetteSense();
    } else {
      return _ram.getUint8(address);
    }
  }

  int readVic(int address) {
    var (storage, resolvedAddress) = _resolveVicAddress(address);
    return storage.getUint8(resolvedAddress);
  }

  type_data.Uint8List readVicRange(int address, int count) {
    var (storage, resolvedAddress) = _resolveVicAddress(address);
    return storage.buffer.asUint8List(resolvedAddress, count);
  }

  (type_data.ByteData, int) _resolveVicAddress(address) {
    if (address >= 0x1000) {
      return (_character, address & 0xfff);
    }
    return (_ram, address);
  }

  type_data.ByteData getDebugSnippet()  {
    return type_data.ByteData.sublistView(_ram, 0, 512);
  }

}
