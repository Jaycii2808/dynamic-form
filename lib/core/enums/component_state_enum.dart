
enum ComponentStateEnum {
  base('base'),
  focused('focused'),
  error('error'),
  enabled('enabled');
  

  final String value; 
  const ComponentStateEnum(this.value); 

  
  static ComponentStateEnum fromString(String value) {
    return values.firstWhere(
          (state) => state.value == value,
      orElse: () => throw Exception('Unknown component state: $value'), 
    );
  }
}
