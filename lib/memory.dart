import 'dart:typed_data' as type_data;

class Memory {
  late type_data.ByteData _data;

  populateMem(type_data.ByteData block) {
    _data = block;
  }

  setMem(int value, int address ) {
    _data.setInt8(address, value);
  }

  int getMem(int address) {
    return _data.getUint8(address);
  }

  type_data.ByteData getDebugSnippet()  {
    return type_data.ByteData.sublistView(_data, 0, 512);
  }

}
