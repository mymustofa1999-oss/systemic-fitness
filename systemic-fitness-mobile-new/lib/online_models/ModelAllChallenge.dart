class ModelAllChallenge {
  Data? data;

  ModelAllChallenge({this.data});

  ModelAllChallenge.fromJson(Map<String, dynamic> json) {
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
  List<Challenges>? challenges;
  String? error;

  Data({this.success, this.challenges, this.error});

  Data.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['challenges'] != null) {
      challenges = [];
      json['challenges'].forEach((v) {
        challenges!.add(new Challenges.fromJson(v));
      });
    }
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.challenges != null) {
      data['challenges'] = this.challenges!.map((v) => v.toJson()).toList();
    }
    data['error'] = this.error;
    return data;
  }
}

class Challenges {
  String? challengesId;
  String? challengesName;
  String? image;
  String? description;
  int? totalweek;
  int? totaldays;
  int? totalDaysCompleted;

  Challenges(
      {this.challengesId,
      this.challengesName,
      this.totalDaysCompleted,
      this.image,
      this.description,
      this.totalweek,
      this.totaldays});

  Challenges.fromJson(Map<String, dynamic> json) {
    challengesId = json['challenges_id'];
    challengesName = json['challenges_name'];
    image = json['image'];
    description = json['description'];
    totalweek = json['totalweek'];
    totaldays = json['totaldays'];
    totalDaysCompleted = json['totaldayscompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['challenges_id'] = this.challengesId;
    data['challenges_name'] = this.challengesName;
    data['image'] = this.image;
    data['description'] = this.description;
    data['totalweek'] = this.totalweek;
    data['totaldays'] = this.totaldays;
    data['totaldayscompleted'] = this.totalDaysCompleted;
    return data;
  }
}
