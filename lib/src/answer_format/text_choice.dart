import 'package:json_annotation/json_annotation.dart';

part 'text_choice.g.dart';

@JsonSerializable()
class TextChoice {
  final String text;
  final String value;
  final String? characterName;
  const TextChoice({
    required this.text,
    required this.value,
    this.characterName,
  }) : super();

  factory TextChoice.fromJson(Map<String, dynamic> json) {
    return TextChoice(
      text: json['text'] as String,
      value: json['value'] as String,
      characterName: json['character_name'] as String?
      ,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'value': value,
        'character_name': characterName,
      };

  bool operator ==(o) => o is TextChoice && text == o.text && value == o.value;
  int get hashCode => text.hashCode ^ value.hashCode;
}
