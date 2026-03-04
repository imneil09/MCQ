class TextChunker {
  static List<String> chunkText(String text) {
    final List<String> chunks = [];
    final List<String> questions = text.split(RegExp(r'\n(?=\d+\.)'));
    String currentChunk = '';

    for (var q in questions) {
      if ((currentChunk.length + q.length) > 4000) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
          currentChunk = '';
        }
        if (q.length > 4000) {
          int start = 0;
          while (start < q.length) {
            int end = (start + 4000 < q.length) ? start + 4000 : q.length;
            chunks.add(q.substring(start, end).trim());
            start += 4000;
          }
        } else {
          currentChunk = q;
        }
      } else {
        currentChunk += (currentChunk.isEmpty ? '' : '\n') + q;
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    return chunks;
  }
}