String formatLabel(String username, {int maxSymbols=12}) {
  final showingLength = maxSymbols;
  if (username.length > showingLength) {
    return '${username.substring(0, showingLength)}...';
  }
  return username;
}