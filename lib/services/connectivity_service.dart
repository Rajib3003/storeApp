final result = await Connectivity().checkConnectivity();

if(result != ConnectivityResult.none){
    await SyncService.syncSales();
}