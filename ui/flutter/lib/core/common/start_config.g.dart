// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartConfig _$StartConfigFromJson(Map<String, dynamic> json) => StartConfig()
  ..network = json['network'] as String
  ..address = json['address'] as String
  ..apiEnable = json['apiEnable'] as bool? ?? true
  ..storage = json['storage'] as String
  ..storageDir = json['storageDir'] as String
  ..refreshInterval = (json['refreshInterval'] as num).toInt()
  ..apiToken = json['apiToken'] as String;

Map<String, dynamic> _$StartConfigToJson(StartConfig instance) =>
    <String, dynamic>{
      'network': instance.network,
      'address': instance.address,
      'apiEnable': instance.apiEnable,
      'storage': instance.storage,
      'storageDir': instance.storageDir,
      'refreshInterval': instance.refreshInterval,
      'apiToken': instance.apiToken,
    };
