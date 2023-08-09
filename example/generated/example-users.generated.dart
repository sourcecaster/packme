import 'dart:typed_data';
import 'package:packme/packme.dart';

final Map<int, PackMeMessage Function()> exampleUsersMessageFactory = <int, PackMeMessage Function()>{
	789877955: () => GetUsersRequest.$empty(),
287424096: () => GetUsersResponse.$empty(),
	1049086457: () => GetUserRequest.$empty(),
666547305: () => GetUserResponse.$empty(),
	503538391: () => DeleteUserRequest.$empty(),
940229715: () => DeleteUserResponse.$empty(),
};