class Applicationmodel {
  String? id;
  String? seekerId;
  String? cv;
  int? jobId;

  Applicationmodel({this.id, this.seekerId, this.cv, this.jobId});

  Applicationmodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    seekerId = json['seeker_id'];
    cv = json['cv'];
    jobId = json['job_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seeker_id'] = seekerId;
    data['job_id'] = jobId;
    data['cv'] = cv;
    return data;
  }
}
