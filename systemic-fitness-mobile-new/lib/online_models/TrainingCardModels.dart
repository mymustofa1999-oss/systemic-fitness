class TrainingCardResponse {
  String? level;
  String? notes;
  List<ProgramCategory>? fullProgram;
  List<ProgramCategory>? dailyReset;
  bool? isPreview;

  TrainingCardResponse({this.level, this.notes, this.fullProgram, this.dailyReset, this.isPreview});

  factory TrainingCardResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCardResponse(
      level: json['level'],
      notes: json['notes'],
      isPreview: json['is_preview'],
      fullProgram: json['full_program'] != null
          ? (json['full_program'] as List)
              .map((v) => ProgramCategory.fromJson(v))
              .toList()
          : null,
      dailyReset: json['daily_reset'] != null
          ? (json['daily_reset'] as List)
              .map((v) => ProgramCategory.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'notes': notes,
      'full_program': fullProgram?.map((v) => v.toJson()).toList(),
      'daily_reset': dailyReset?.map((v) => v.toJson()).toList(),
    };
  }
}

class ProgramCategory {
  String? type;
  String? duration;
  List<TrainingSet>? sets;

  ProgramCategory({this.type, this.duration, this.sets});

  factory ProgramCategory.fromJson(Map<String, dynamic> json) {
    return ProgramCategory(
      type: json['type'],
      duration: json['duration'],
      sets: json['sets'] != null
          ? (json['sets'] as List).map((v) => TrainingSet.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration': duration,
      'sets': sets?.map((v) => v.toJson()).toList(),
    };
  }
}

class TrainingSet {
  String? setName;
  int? durationMins;
  String? bpmRange;
  String? equipmentUpper;
  String? equipmentLower;
  List<String>? tags;
  List<TrainingMovement>? movements;

  TrainingSet({
    this.setName,
    this.durationMins,
    this.bpmRange,
    this.equipmentUpper,
    this.equipmentLower,
    this.tags,
    this.movements,
  });

  factory TrainingSet.fromJson(Map<String, dynamic> json) {
    return TrainingSet(
      setName: json['set_name'],
      durationMins: json['duration_mins'],
      bpmRange: json['bpm_range'],
      equipmentUpper: json['equipment_upper'],
      equipmentLower: json['equipment_lower'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      movements: json['movements'] != null
          ? (json['movements'] as List)
              .map((v) => TrainingMovement.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_name': setName,
      'duration_mins': durationMins,
      'bpm_range': bpmRange,
      'equipment_upper': equipmentUpper,
      'equipment_lower': equipmentLower,
      'tags': tags,
      'movements': movements?.map((v) => v.toJson()).toList(),
    };
  }
}

class TrainingMovement {
  String? id;
  int? sequence;
  String? title;
  String? videoUrl;
  String? movementTag;
  List<String>? allowedTiers; // package tiers allowed to access; empty = all

  TrainingMovement({
    this.id,
    this.sequence,
    this.title,
    this.videoUrl,
    this.movementTag,
    this.allowedTiers,
  });

  factory TrainingMovement.fromJson(Map<String, dynamic> json) {
    return TrainingMovement(
      id: json['id'],
      sequence: json['sequence'],
      title: json['title'],
      videoUrl: json['video_url'],
      movementTag: json['movement_tag'],
      allowedTiers: (json['allowed_tiers'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sequence': sequence,
      'title': title,
      'video_url': videoUrl,
      'movement_tag': movementTag,
      'allowed_tiers': allowedTiers,
    };
  }
}
