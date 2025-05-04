class UserAccount {
  final String name;
  final String email;
  final String phoneNumber;
  final String status;
  final String password;

  UserAccount( {required this.name, required this.email,required this.phoneNumber, required this.status, required this.password});

  factory UserAccount.fromDocument(Map<dynamic, dynamic> map) {
    return UserAccount(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber']??'',
      status: map['status']??'',
      password: map['password']??''
    );
  }
   Map<String,dynamic> toMap()
  {return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'status': status,
      'password':password
    };}
}