enum RequestTypeEnum {
  queEs,
  efectosSecundarios,
  advertencias,
  instrucciones
}

extension RequestTypeExtension on RequestTypeEnum {
  String get typeName {
    switch (this) {
      case RequestTypeEnum.queEs:
        return 'que_es';
      case RequestTypeEnum.efectosSecundarios:
        return 'efectos_secundarios';
      case RequestTypeEnum.instrucciones:
        return 'instrucciones';
      case RequestTypeEnum.advertencias:
        return 'advertencias';
      }
  }
}