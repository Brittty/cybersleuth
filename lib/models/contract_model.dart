class ContractModel {
  final String id;
  final String sender;
  final String time;
  final List<String> chats;

  ContractModel({
    required this.id,
    required this.sender,
    required this.time,
    required this.chats,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) => ContractModel(
        id: json['id'] ?? '',
        sender: json['sender'],
        time: json['time'],
        chats: json['chats'].cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'time': time,
        'chats': chats,
      };
}
