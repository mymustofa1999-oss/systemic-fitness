
class UserDetail {


  UserDetail({
    this.userId,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.password,
    this.mobile,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.image,
    this.address,
    this.city,
    this.country,
    this.intensively,
    this.timeInWeek,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.state,
  });

  String? userId;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? password;
  String? mobile;
  String? age;
  String? gender;
  String? height;
  String? weight;
  String? image;
  String? address;
  String? city;
  String? country;
  String? intensively;
  String? timeInWeek;
  String? createdAt;
  String? updatedAt;
  String? isActive;
  String? state;

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
    userId: json["user_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    username: json["username"],
    email: json["email"],
    password: json["password"],
    mobile: json["mobile"],
    age: json["age"],
    gender: json["gender"],
    height: json["height"],
    weight: json["weight"],
    image: json["image"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    intensively: json["intensively"],
    timeInWeek: json["timeinweek"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "first_name": firstName,
    "last_name": lastName,
    "username": username,
    "email": email,
    "password": password,
    "mobile": mobile,
    "age": age,
    "gender": gender,
    "height": height,
    "weight": weight,
    "image": image,
    "address": address,
    "city": city,
    "country": country,
    "intensively": intensively,
    "timeinweek": timeInWeek,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "is_active": isActive,
    "state": state,
  };

// String? userId;
// String? firstName;
// String? lastName;
// String? username;
// String? email;
// String? password;
// String? mobile;
// String? address;
// String? image;
// String? createdAt;
// String? updatedAt;
// String? isActive;
//
// UserDetail(
//     {this.userId,
//       this.firstName,
//       this.lastName,
//       this.username,
//       this.email,
//       this.password,
//       this.mobile,
//       this.address,
//       this.image,
//       this.createdAt,
//       this.updatedAt,
//       this.isActive});
//
// UserDetail.fromJson(Map<String, dynamic> json) {
//   userId = json['user_id'];
//   firstName = json['first_name'];
//   lastName = json['last_name'];
//   username = json['username'];
//   email = json['email'];
//   password = json['password'];
//   mobile = json['mobile'];
//   address = json['address'];
//   image = json['image'];
//   createdAt = json['created_at'];
//   updatedAt = json['updated_at'];
//   isActive = json['is_active'];
// }
//
// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   data['user_id'] = this.userId;
//   data['first_name'] = this.firstName;
//   data['last_name'] = this.lastName;
//   data['username'] = this.username;
//   data['email'] = this.email;
//   data['password'] = this.password;
//   data['mobile'] = this.mobile;
//   data['address'] = this.address;
//   data['image'] = this.image;
//   data['created_at'] = this.createdAt;
//   data['updated_at'] = this.updatedAt;
//   data['is_active'] = this.isActive;
//   return data;
// }
}

