
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  //Receberemos o indice
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Apartir daí é possivel receber o json
        title: Text(_gifData["title"]),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share), 
            onPressed: (){
              //Usando o plugin chamado share 0.5.2 para compartilhamento
              //Compartilhando o link do gif
              Share.share(_gifData["images"]["fixed_height"]["url"]);
            }
          ),
        ],
      ),

      backgroundColor: Colors.black,
      body: Center(
        //Recebendo a imagem clicada na outra tela
        child: Image.network(_gifData["images"]["fixed_height"]["url"]),
      ),
    );
  }
}