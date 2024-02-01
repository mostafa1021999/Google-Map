import 'package:flutter/cupertino.dart';

Widget Resturant(){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 100,
      child: Row(
        children: [
          Image(fit:BoxFit.fill,
      image: NetworkImage('https://media.istockphoto.com/id/96318973/photo/pyramids-egypt.jpg?s=2048x2048&w=is&k=20&c=Z_M8RYx9mdbRMQ5zKoGdD0aLrjx4xSpsjk-1cPVP1g4='))
        ],
      ),
    ),
  );
}