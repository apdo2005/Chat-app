class chatmessage {
  String? id;
  String? text;
  String? senderid;
  String? recieverid;
  String? time;
  
  chatmessage({this .id,this.text, this.senderid, this.recieverid, this.time, });
  factory chatmessage.fromMap(map) {
    return chatmessage(
      id: map['id'],
      text: map['message'],
      senderid: map['senderid'],
      recieverid: map['recieverid'],
      time: map['time'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': text,
      'senderid': senderid,
      'recieverid': recieverid,
      'time': time,
    };
  }
}