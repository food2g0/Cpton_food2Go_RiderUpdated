import 'package:cloud_firestore/cloud_firestore.dart';
import '../global/global.dart';



separateOrderItemIDs(orderId)
{
  List<String> separateItemIDsList=[], defaultItemList=[];
  int i=0;

  defaultItemList = List<String>.from(orderId ?? []);


  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();
    var pos = item.lastIndexOf(":");

    //56557657
    String getItemId = (pos != -1) ? item.substring(0, pos) : item;

    print("\nThis is itemID now = " + getItemId);

    separateItemIDsList.add(getItemId);
  }

  print("\nThis is Items List now = ");
  print(separateItemIDsList);

  return separateItemIDsList;
}

separateItemIDs()
{
  List<String> separateItemIDsList=[], defaultItemList=[];
  int i=0;

  defaultItemList = sharedPreferences!.getStringList("userCart")!;

  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();
    var pos = item.lastIndexOf(":");

    //56557657
    String getItemId = (pos != -1) ? item.substring(0, pos) : item;

    // if (kDebugMode) {
    //   print("\nThis is itemID now = $getItemId");
    // }

    separateItemIDsList.add(getItemId);
  }

  // if (kDebugMode) {
  //   print("\nThis is Items List now = ");
  // }
  // if (kDebugMode) {
  //   print(separateItemIDsList);
  // }

  return separateItemIDsList;
}



separateOrderItemQuantities(orderID)
{
  List<String> separateItemQuantityList=[];
  List<String> defaultItemList=[];
  int i=1;

  defaultItemList = List<String>.from(orderID);

  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();


    //0=:
    //1=7
    //:7
    List<String> listItemCharacters = item.split(":").toList();

    //7
    var quanNumber = int.parse(listItemCharacters[1].toString());

    // if (kDebugMode) {
    //   print("\nThis is Quantity Number = $quanNumber");
    // }

    separateItemQuantityList.add(quanNumber.toString());
  }

  // if (kDebugMode) {
  //   print("\nThis is Quantity List now = ");
  // }
  // if (kDebugMode) {
  //   print(separateItemQuantityList);
  // }

  return separateItemQuantityList;
}



separateItemQuantities()
{
  List<int> separateItemQuantityList=[];
  List<String> defaultItemList=[];
  int i=1;

  defaultItemList = sharedPreferences!.getStringList("userCart")!;

  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();


    //0=:
    //1=7
    //:7
    List<String> listItemCharacters = item.split(":").toList();

    //7
    var quanNumber = int.parse(listItemCharacters[1].toString());

    // if (kDebugMode) {
    //   print("\nThis is Quantity Number = $quanNumber");
    // }

    separateItemQuantityList.add(quanNumber);
  }

  // if (kDebugMode) {
  //   print("\nThis is Quantity List now = ");
  // }
  // if (kDebugMode) {
  //   print(separateItemQuantityList);
  // }

  return separateItemQuantityList;
}




clearCartNow(context)
{
  sharedPreferences!.setStringList("userCart", ['garbageValue']);
  List<String>? emptyList = sharedPreferences!.getStringList("userCart");

  FirebaseFirestore.instance
      .collection("users")
      .doc(firebaseAuth.currentUser!.uid)
      .update({"userCart": emptyList}).then((value)
  {
    sharedPreferences!.setStringList("userCart", emptyList!);
  });
}