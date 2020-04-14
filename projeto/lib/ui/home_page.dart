import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;

  int _offset = 0;
  
  //Usamos o future para retornar o dado no futuro
  Future<Map> _getGifs() async {
    //response recebera valores da api
    http.Response response;
    
    //Atribui a response api de busca estatica e busca por search
    if(_search == null)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=VjGrTF5xySSgDDs8CZ4wrXgsbA8PCYDr&limit=20&rating=G");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=VjGrTF5xySSgDDs8CZ4wrXgsbA8PCYDr&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");
  
    //response sendo convertido para json
    return json.decode(response.body);
  }

  @override
  void initState(){
    super.initState();

    _getGifs().then((map){
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              //Pega o valor do input de texto e passa para o _getGifs e  
              //pesquisa a imagem de acordo com o que foi digitado
              onSubmitted: (text){
                setState(() {
                  _search = text;
                });
              },
            ),
          ),

          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  //Simbolo de carregamento das gifs
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                    default:
                      //Caso retorne erro, container vem vazio
                      //Caso não retorne erro, entra no método que chamará os gifs
                      if(snapshot.hasError) return Container();
                      else return _createGifTable(context, snapshot);
                    
                }
              }
            )
          )
        ],
      ),
    );
  }

  int _getCount(List data){
    if(_search == null){
      return data.length;
    }else{
      return data.length + 1;
    }
  }

  //Método construtor da tabela de gifs
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),

      //Montará o grid sendo...
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //mostrar 2 colunas
        crossAxisCount: 2,
        //espaçamento entre 
        crossAxisSpacing: 10.0,
        //espaçamento
        mainAxisSpacing: 10.0
      ), 
      //de acordo com o tamanho pré selecionado, nesse caso 20
      itemCount: _getCount(snapshot.data["data"]),
      //Iniciando a contrução da GridView com os dados consumidos do JSON
      itemBuilder: (context, index){
        //Se pesquisa null ou último item 
        if(if(_search == null || _search.isEmpty) || index < snapshot.data["data"].length)
          //Dará clique ao gif
          return GestureDetector(
            //Será setado os gifs dentro do widget, passando o caminho para conseguir o mesmo
            child: FadeInImage.memoryNetwork(
              //Para as imagens aparecer mais suave na tela usamos um plugin chamado
              //transparent_image
              placeholder: kTransparentImage, 
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: (){
              //Chamando outra tela e enviando o index da gif para ser aberta em outra tela
              Navigator.push(context, 
                MaterialPageRoute(
                  //Maneira que usamos para enviar o index
                  builder: (context) => GifPage(snapshot.data["data"][index])
                ));
            },
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        else 
        //senão entra na pesquisa
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text("Carregar mais...", style: TextStyle(color: Colors.white, fontSize: 22.0),),
                ],
              ),
              onTap: (){
                //Quando clicar em mais, buscar mais imagens
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
        
      },

    );
  }
}