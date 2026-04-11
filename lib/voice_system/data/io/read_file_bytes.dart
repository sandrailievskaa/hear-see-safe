import 'read_file_bytes_stub.dart'
    if (dart.library.io) 'read_file_bytes_io.dart' as rf;

Future<List<int>?> readFileBytes(String path) => rf.readFileBytes(path);
