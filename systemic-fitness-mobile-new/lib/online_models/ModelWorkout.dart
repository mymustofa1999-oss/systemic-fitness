class ModelWorkout {
  Data? data;

  ModelWorkout({this.data});

  ModelWorkout.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? success;
  List<Category>? category;
  String? error;

  Data({this.success, this.category, this.error});

  Data.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['category'] != null) {
      category = [];
      json['category'].forEach((v) {
        category!.add(new Category.fromJson(v));
      });
    }
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    data['error'] = this.error;
    return data;
  }
}

class Category {
  String? categoryId;
  String? category;
  String? image;
  String? description;

  Category({this.categoryId, this.category, this.image, this.description});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    category = json['category'];
    image = json['image'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category'] = this.category;
    data['image'] = this.image;
    data['description'] = this.description;
    return data;
  }
}
