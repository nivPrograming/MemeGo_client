import 'dart:typed_data';

class Message {
  final int opcode; 
  final int status; 
  final List<Uint8List> fields;

  Message(this.opcode, this.status, [List<Uint8List>? fields])
      : fields = fields ?? [];

  // serializes the msg from the class members values
  Uint8List prepare() {
  
    int totalLength = 4;

    for (final field in fields) {
      totalLength += 4;
      totalLength += field.length;
    }

    final buffer = ByteData(totalLength);
    int offset = 0;


    buffer.setUint16(offset, opcode, Endian.big);
    offset += 2;


    buffer.setUint16(offset, status, Endian.big);
    offset += 2;

    for (final field in fields) {
      buffer.setUint32(offset, field.length, Endian.big);
      offset += 4;

      buffer.buffer.asUint8List().setRange(
            offset,
            offset + field.length,
            field,
          );
      offset += field.length;
    }

    return buffer.buffer.asUint8List();
  }

  /// Deserialize from bytes
  static Message? loadFromBytes(Uint8List data) {
    if (data.length < 4) return null;

    final buffer = ByteData.sublistView(data);
    int offset = 0;

    final opcode = buffer.getUint16(offset, Endian.big);
    offset += 2;

    final status = buffer.getUint16(offset, Endian.big);
    offset += 2;

    final fields = <Uint8List>[];

    while (offset + 4 <= data.length) {
      final fieldSize = buffer.getUint32(offset, Endian.big);
      offset += 4;

      if (offset + fieldSize > data.length) {
        return null; // corrupted / incomplete packet
      }

      fields.add(
        Uint8List.sublistView(data, offset, offset + fieldSize),
      );
      offset += fieldSize;
    }

    return Message(opcode, status, fields);
  }
}