class chatuser{
  String? uid;
  String? email;
  String? createdAt;
  String ? imageurl;
  chatuser({this.uid,this.email,this.createdAt,this.imageurl});
  factory  chatuser.fromMap(Map<String,dynamic> map){
  return chatuser(   
    uid:map['id'],
    email:map['email' ],
    createdAt: map['createdAt'],
    imageurl: map['imageurl']
  );
  }
  Map<String,dynamic> toMap(){
    return{
      'id':uid,
      'email':email,
      'createdAt':createdAt,
      'imageurl':imageurl
    };
  }

 }