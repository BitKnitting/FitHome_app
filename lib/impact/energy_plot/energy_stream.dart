abstract class EnergyStream {
  Future startReadingsStream(String monitorName, void onData(var reading));
  void closeReadingsStream();
}
